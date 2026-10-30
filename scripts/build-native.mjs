/* SPDX-License-Identifier: GPL-3.0-or-later */
import {spawnSync} from 'node:child_process';
import {mkdirSync,existsSync,copyFileSync,readFileSync,writeFileSync} from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));process.chdir(root);
const upstream='fd891c6bc5eb350387602deb5c1ef9b6dcdab948';
const sdk=process.env.EMSDK;
const python=process.env.EMSDK_PYTHON||'python3';
const empp=process.env.EMXX||(sdk?path.join(sdk,'upstream/emscripten/em++.py'):'em++');
const wasmCommand=empp.endsWith('.py')?[python,empp]:[empp];
const out='vendor/spektralab/dist';mkdirSync(out,{recursive:true});
if(!existsSync('vendor/spektralab/resources/spektrafilm_constants.bin')){
 const r=await fetch(`https://raw.githubusercontent.com/JamesQiu2005/SpektraLab/${upstream}/engine/resources/spektrafilm_constants.bin`);if(!r.ok)throw Error('Cannot fetch pinned native constants');writeFileSync('vendor/spektralab/resources/spektrafilm_constants.bin',new Uint8Array(await r.arrayBuffer()));
}
const {createHash}=await import('node:crypto');
const manifest=JSON.parse(readFileSync('vendor/spektralab/UPSTREAM.json'));
for(const [name,hash] of Object.entries(manifest.files)){
 const file='vendor/spektralab/'+name;if(name.startsWith('resources/profiles/'))continue;
 if(createHash('sha256').update(readFileSync(file)).digest('hex')!==hash)throw Error('Upstream file differs: '+name);
}
const core=['blob','cam16','colour','curves','digital_intermediate','hanatos','json','latitude_fit','numeric','params','print_lut','printing','profile','setup_cache','spectral'].map(x=>'vendor/spektralab/core/'+x+'.cpp');
const common=['-std=c++20','-O2','-fexceptions','-fno-fast-math','-ffp-contract=off','-Ivendor/spektralab/core','native/bridge.cpp',...core];
function run(cmd,args){const r=spawnSync(cmd,args,{stdio:'inherit'});if(r.error)throw r.error;if(r.status!==0)process.exit(r.status||1);}
if(process.argv.includes('--native')){mkdirSync('test-output/native',{recursive:true});run(process.env.CXX||'clang++',[...common,'native/probe.cpp','-o','test-output/native/probe']);}
else {const version=spawnSync(wasmCommand[0],[...wasmCommand.slice(1),'--version'],{encoding:'utf8'});if(version.status!==0||!version.stdout.includes('4.0.23'))throw Error('Build requires pinned Emscripten 4.0.23');run(wasmCommand[0],[...wasmCommand.slice(1),...common,'--no-entry','-sMODULARIZE=1','-sEXPORT_ES6=1','-sENVIRONMENT=web,worker,node','-sALLOW_MEMORY_GROWTH=1','-sMAXIMUM_MEMORY=1073741824','-sSTACK_SIZE=1048576','-sEXPORTED_FUNCTIONS=["_spk_init","_spk_prepare","_spk_error","_spk_pixels","_spk_lut","_spk_gpu_data","_spk_gpu_size","_malloc","_free"]','-sEXPORTED_RUNTIME_METHODS=["FS","ccall","UTF8ToString","HEAPF32","HEAPF64"]','-sASSERTIONS=1','-o',out+'/core.mjs']);}
copyFileSync('vendor/spektralab/resources/spektrafilm_constants.bin',out+'/spektrafilm_constants.bin');
if(!process.argv.includes('--native')){
 const digest=name=>createHash('sha256').update(readFileSync(name)).digest('hex');
 writeFileSync(out+'/BUILD.json',JSON.stringify({upstream_commit:upstream,emscripten:'4.0.23',adapter_sha256:digest('native/bridge.cpp'),wgsl_sha256:digest('native/pointwise.wgsl'),files:Object.fromEntries(['core.mjs','core.wasm','spektrafilm_constants.bin'].map(name=>[name,digest(out+'/'+name)]))},null,2)+'\n');
}
console.log('Native core build complete; upstream '+upstream);
