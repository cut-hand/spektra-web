/* SPDX-License-Identifier: GPL-3.0-or-later */
import {readFileSync,writeFileSync,mkdirSync,readdirSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {metalExtras} from './webgpu-metal-extras.mjs';
import {createHash} from 'node:crypto';
const naga=process.env.NAGA_BIN||process.env.NAGA||'naga',base='vendor/spektralab/vulkan',tmp='test-output/webgpu/glsl';mkdirSync(tmp,{recursive:true});mkdirSync('gpu/shaders',{recursive:true});
const version=spawnSync(naga,['--version'],{encoding:'utf8'});if(version.status!==0||!version.stdout.includes('30.0.1'))throw Error('NAGA_BIN must point to naga-cli30.0.1');
const manifest={upstream_commit:'fd891c6bc5eb350387602deb5c1ef9b6dcdab948',translator:'naga-cli 30.0.1',sources:{},kernels:{}};
const upstream=JSON.parse(readFileSync(base+'/UPSTREAM.json'));for(const [name,hash]of Object.entries(upstream.files))if(createHash('sha256').update(readFileSync(base+'/'+name)).digest('hex')!==hash)throw Error('Changed upstream shader '+name);
const rng=readFileSync(base+'/spk_rng.glsl','utf8');manifest.sources['spk_rng.glsl']=upstream.files['spk_rng.glsl'];
const sources={...Object.fromEntries(readdirSync(base).filter(f=>f.endsWith('.comp')).map(f=>[f,readFileSync(base+'/'+f,'utf8')])),...metalExtras()};
for(const [file,source] of Object.entries(sources)){
 let text=source;manifest.sources[file]=createHash('sha256').update(text).digest('hex');
 text=text.replace('#extension GL_GOOGLE_include_directive : require','').replace('#include "spk_rng.glsl"',rng).replace(/\bprecise\s+/g,'').replace(/\bwriteonly\s+/g,'');
 text=text.replaceAll('uintBitsToFloat(0x7fc00000u)','uintBitsToFloat(0x7fc00000u | (floatBitsToUint(value) & 0x003fffffu))').replaceAll('uintBitsToFloat(0xff800000u)','uintBitsToFloat(0xff800000u | (gl_GlobalInvocationID.x & 0u))').replaceAll('gl_WorkGroupSize.x','256u').replaceAll('umulExtended(', 'spk_umul_extended(').replaceAll('isnan(', 'spk_isnan(');
 const compat=`
 bool spk_isnan(float x){return (floatBitsToUint(x)&0x7fffffffu)>0x7f800000u;}
 void spk_umul_extended(uint a,uint b,out uint hi,out uint lo){
 uint a0=a&65535u,a1=a>>16u,b0=b&65535u,b1=b>>16u;
 uint w0=a0*b0,t=a1*b0+(w0>>16u),w1=t&65535u,w2=t>>16u;
 w1+=a0*b1;hi=a1*b1+w2+(w1>>16u);lo=a*b;
 }
`;
 text=text.replace('#version 450','#version 450\n'+compat);
 if(file.startsWith('spk_cctf_'))text=text.replace(/switch \(mode\) \{([\s\S]*?)\n    \}/,(_,body)=>body.replace(/case (\d+u):/g,'if(mode==$1)').replace('default:',''));
 const name=file.slice(0,-5),input=tmp+'/'+file,output='gpu/shaders/'+name+'.wgsl';writeFileSync(input,text);
 const result=spawnSync(naga,['--input-kind','glsl','--shader-stage','compute',input,output],{encoding:'utf8'});if(result.status){throw Error(file+': '+(result.stderr||result.stdout));}
 if(name==='spk_reduce_max')writeFileSync(output,readFileSync(output,'utf8').replace(/\s*(storageBarrier|subgroupBarrier|textureBarrier)\(\);/g,''));
 const bindings=[...text.matchAll(/layout\([^)]*binding\s*=\s*(\d+)[^)]*\)\s*(readonly|writeonly)?\s*buffer/g)].map(m=>({binding:Number(m[1]),access:m[2]==='readonly'?'read':'read_write'}));
 manifest.kernels[name]={bindings,sha256:createHash('sha256').update(readFileSync(output)).digest('hex')};
}
for(const file of readdirSync('gpu/custom').filter(f=>f.endsWith('.wgsl'))){const name=file.slice(0,-5),source=readFileSync('gpu/custom/'+file,'utf8');const out='gpu/shaders/'+file;const result=spawnSync(naga,['gpu/custom/'+file],{encoding:'utf8'});if(result.status)throw Error(result.stderr);writeFileSync(out,source);manifest.kernels[name]={bindings:[...source.matchAll(/@binding\((\d+)\) var<storage,(read|read_write)>/g)].map(m=>({binding:Number(m[1]),access:m[2]})),sha256:createHash('sha256').update(source).digest('hex')};}
const originals=[...new Set(['nodes','blur','grain','gamut','util','scene_latitude','contrast_mask'].flatMap(n=>[...readFileSync('vendor/spektralab/shaders/'+n+'.metal','utf8').matchAll(/kernel void (spk_\w+)/g)].map(m=>m[1])))];for(const name of originals)if(!manifest.kernels[name])throw Error('Missing original kernel '+name);
writeFileSync('gpu/shaders/manifest.json' ,JSON.stringify(manifest,null,2)+'\n');console.log('Converted '+Object.keys(manifest.kernels).length+' kernels');
