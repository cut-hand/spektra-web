// SPDX-License-Identifier: GPL-3.0-or-later
// Read-only: report upstream changes without replacing local code or materials.
import fs from 'node:fs/promises';
import {pathToFileURL} from 'node:url';

const repository='JamesQiu2005/SpektraLab';
const materialPath=path=>/^engine\/resources(?:_product)?\/profiles\/[^/]+\.json$/.test(path);

export function compareTree(baseline,tree){
 const byPath=new Map(tree.filter(x=>x.type==='blob').map(x=>[x.path,x.sha]));
 const expected=new Set(baseline.files.map(x=>x.upstream_path));
 const changes=[];
 for(const file of [...baseline.files,...(baseline.notices||[])]){
  const current=byPath.get(file.upstream_path);
  if(current!==file.upstream_blob_sha)changes.push({path:file.upstream_path,status:current?'changed':'removed',baseline_sha:file.upstream_blob_sha,current_sha:current||null});
 }
 for(const [path,sha] of byPath)if(materialPath(path)&&!expected.has(path))changes.push({path,status:'added',current_sha:sha});
 return changes;
}

export function compareNativeTree(manifest,tree){
 const current=new Map(tree.filter(x=>x.type==='blob').map(x=>[x.path,x.sha]));
 const expected={...(manifest.source_blobs||{}),...(manifest.reference_blobs||{})};
 const changes=[];
 for(const [path,sha] of Object.entries(expected)){const now=current.get(path);if(now!==sha)changes.push({path,status:now?'changed':'removed',baseline_sha:sha,current_sha:now||null});}
 for(const [path,sha] of current)if(/^engine\/src\/(?:core|pipeline|gpu|shaders)\/[^/]+\.(cpp|hpp|h|metal)$/.test(path)&&!Object.hasOwn(expected,path))changes.push({path,status:'added',current_sha:sha});
 return changes;
}

export function compareVulkanTree(manifest,tree){
 const expected=manifest.source_blobs||{},current=new Map(tree.filter(x=>x.type==='blob'&&/^engine\/src\/shaders\/vulkan\/[^/]+\.(comp|glsl)$/.test(x.path)).map(x=>[x.path,x.sha]));
 const changes=[];for(const [path,sha]of Object.entries(expected)){const now=current.get(path);if(now!==sha)changes.push({path,status:now?'changed':'removed',baseline_sha:sha,current_sha:now||null});}
 for(const [path,sha]of current)if(!Object.hasOwn(expected,path))changes.push({path,status:'added',current_sha:sha});return changes;
}

async function api(path){
 let last;
 for(let attempt=0;attempt<3;attempt++){
  try{
   const response=await fetch(`https://api.github.com/repos/${repository}/${path}`,{headers:{Accept:'application/vnd.github+json','User-Agent':'spektra-browser-upstream-check'},signal:AbortSignal.timeout(20000)});
   if(!response.ok)throw Error(`GitHub HTTP ${response.status} for ${path}`);
   return await response.json();
  }catch(error){last=error;if(attempt<2)await new Promise(resolve=>setTimeout(resolve,1000*(attempt+1)));}
 }
 throw last;
}

export async function checkUpstream(ref){
 const baseline=JSON.parse(await fs.readFile(new URL('../upstream-version.json',import.meta.url),'utf8'));
 const release=ref?null:await api('releases/latest');
 const target=ref||release.tag_name;
 const commit=await api('commits/'+encodeURIComponent(target));
 const result=await api('git/trees/'+encodeURIComponent(commit.sha)+'?recursive=1');
 if(result.truncated||!Array.isArray(result.tree))throw Error('Incomplete upstream tree; refusing a partial comparison');
 const changes=compareTree(baseline,result.tree);
 const nativeManifest=JSON.parse(await fs.readFile(new URL('../vendor/spektralab/UPSTREAM.json',import.meta.url),'utf8'));
 const vulkanManifest=JSON.parse(await fs.readFile(new URL('../vendor/spektralab/vulkan/UPSTREAM.json',import.meta.url),'utf8'));
 const nativeChanges=[...compareNativeTree(nativeManifest,result.tree),...compareVulkanTree(vulkanManifest,result.tree)];
 return {
  checked_at:new Date().toISOString(),browser_version:baseline.browser_version,
  baseline_release:baseline.upstream_release,baseline_commit:baseline.upstream_commit,
  target_ref:target,target_commit:commit.sha,
  target_url:`https://github.com/${repository}/tree/${commit.sha}`,
  new_upstream_commit:commit.sha!==baseline.upstream_commit,
  material_or_notice_changes:changes,
  native_core_or_kernel_changes:nativeChanges,
  native_changes_url:`https://github.com/${repository}/compare/${baseline.upstream_commit}...${commit.sha}`,
  next_step:changes.length||nativeChanges.length?'Review source, attribution and compatibility before importing; see UPDATING.md.':commit.sha!==baseline.upstream_commit?'Material, notice and tracked native source blobs unchanged. Review native code and release notes; do not assume engine parity.':'Pinned baseline is current for the selected ref.',
  modified_local_files:false
 };
}

if(process.argv[1]&&import.meta.url===pathToFileURL(process.argv[1]).href){
 const args=process.argv.slice(2);
 if(args.length&&!(args.length===2&&args[0]==='--ref')){
  console.error('Usage: node scripts/check-upstream.mjs [--ref TAG_OR_COMMIT]');process.exitCode=2;
 }else{
  try{console.log(JSON.stringify(await checkUpstream(args[1]),null,2));}
  catch(error){console.error('Upstream check failed: '+error.message);process.exitCode=1;}
 }
}
