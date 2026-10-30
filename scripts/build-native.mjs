/* SPDX-License-Identifier: GPL-3.0-or-later */
import {spawnSync} from 'node:child_process';
import {mkdirSync,existsSync,copyFileSync,readFileSync,writeFileSync} from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {preparePipeline} from './prepare-native-pipeline.mjs';
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
let pipeline=preparePipeline();
if(process.argv.includes('--metal-oracle')){
 const ref=process.env.SPK_ORACLE_SOURCE;if(!ref)throw Error('Set SPK_ORACLE_SOURCE to the pinned upstream checkout');
 pipeline=pipeline.filter(p=>p!=='native/cpu-backend.cpp');pipeline.push('native/metal-oracle.cpp',ref+'/engine/src/gpu/metal_gpu.cpp',ref+'/engine/src/gpu/metal_impl.cpp','-I'+ref+'/engine/third_party/metal-cpp','-framework','Metal','-framework','Foundation','-framework','QuartzCore');
}
const common=['-std=c++20','-O3','-fexceptions','-fno-fast-math','-ffp-contract=off','-DSPK_WASM=1','-Inative','-Itest-output/native/generated','-Ivendor/spektralab','-Ivendor/spektralab/core','-Ivendor/spektralab/pipeline','native/bridge.cpp',...core,...pipeline];
function run(cmd,args){const r=spawnSync(cmd,args,{stdio:'inherit'});if(r.error)throw r.error;if(r.status!==0)process.exit(r.status||1);}
if(process.argv.includes('--native')){mkdirSync('test-output/native',{recursive:true});run(process.env.CXX||'clang++',[...common,process.argv.includes('--frame-probe')?'native/frame-probe.cpp':'native/probe.cpp','-o',process.argv.includes('--metal-oracle')?'test-output/native/metal-oracle':process.argv.includes('--frame-probe')?'test-output/native/frame-probe':'test-output/native/probe']);}
else {const version=spawnSync(wasmCommand[0],[...wasmCommand.slice(1),'--version'],{encoding:'utf8'});if(version.status!==0||!version.stdout.includes('4.0.23'))throw Error('Build requires pinned Emscripten 4.0.23');run(wasmCommand[0],[...wasmCommand.slice(1),...common,'--no-entry','-sMODULARIZE=1','-sEXPORT_ES6=1','-sENVIRONMENT=web,worker,node','-sALLOW_MEMORY_GROWTH=1','-sMAXIMUM_MEMORY=1073741824','-sSTACK_SIZE=1048576','-sEXPORTED_FUNCTIONS=["_spk_grain_probe","_spk_prophoto_matrix","_spk_convert","_spk_frame","_spk_frame_cache_hit","_spk_meter_ev","_spk_init","_spk_prepare","_spk_error","_spk_pixels","_spk_lut","_malloc","_free"]','-sEXPORTED_RUNTIME_METHODS=["FS","ccall","UTF8ToString","HEAPF32","HEAPF64"]','-sASSERTIONS=1','-o',out+'/core.mjs']);}
copyFileSync('vendor/spektralab/resources/spektrafilm_constants.bin',out+'/spektrafilm_constants.bin');
if(!process.argv.includes('--native')){
 const digest=name=>createHash('sha256').update(readFileSync(name)).digest('hex');
 writeFileSync(out+'/BUILD.json',JSON.stringify({upstream_commit:upstream,emscripten:'4.0.23',adapter_sha256:digest('native/bridge.cpp'),backend:'C++ CPU / WASM (no graphics API)',kernel_adapter_sha256:digest('native/cpu-backend.cpp'),generator_sha256:digest('scripts/prepare-native-pipeline.mjs'),files:Object.fromEntries(['core.mjs','core.wasm','spektrafilm_constants.bin'].map(name=>[name,digest(out+'/'+name)]))},null,2)+'\n');
}
console.log('Native core build complete; upstream '+upstream);
