/* SPDX-License-Identifier: GPL-3.0-or-later */
import {loadNativeWebGPU} from './native-webgpu.js';
import createCore from './vendor/spektralab/dist/core.mjs';
export const nativeCoreVersion='SpektraLab 1.3.4 / C++ WASM pointwise';
export class NativeCore {
 constructor(module){this.module=module;this.root='/resources';this.key=null;}
 static async load({wasmBinary,readResource,readProfile}={}){
  const m=await createCore(wasmBinary?{wasmBinary}:{});
  const bytes=readResource|| (async name=>{const r=await fetch(new URL('./vendor/spektralab/'+(name.endsWith('.bin')?'dist/':'resources/')+name,import.meta.url));if(!r.ok)throw Error('原生核心资源加载失败：'+name);return new Uint8Array(await r.arrayBuffer());});
  m.FS.mkdir('/resources');m.FS.mkdir('/resources/profiles');
  m.FS.writeFile('/resources/spektrafilm_constants.bin',await bytes('spektrafilm_constants.bin'));
  m.FS.writeFile('/resources/neutral_print_filters.json',await bytes('neutral_print_filters.json'));
  const core=new NativeCore(m);core.readProfile=readProfile|| (async id=>{const r=await fetch(new URL('./profiles/'+id+'.json',import.meta.url));if(!r.ok)throw Error('材料读取失败：'+id);return r.json();});core.loaded=new Set();
  if(!m.ccall('spk_init','number',['string'],[core.root]))throw Error(core.error());return core;
 }
 error(){return this.module.UTF8ToString(this.module._spk_error());}
 async profile(id){
  if(!/^[a-z0-9_]+$/.test(id))throw Error('无效原生材料配置');if(this.loaded.has(id))return;
  const p=await this.readProfile(id);if(p.derived_from)await this.profile(p.derived_from);
  this.module.FS.writeFile(this.root+'/profiles/'+id+'.json',JSON.stringify(p));this.loaded.add(id);
  if(p.info?.target_print)await this.profile(p.info.target_print);
 }
 async prepare(film,paper,options={}){
  const key=JSON.stringify([film,paper,options]);if(this.key===key)return;
  await this.profile(film);await this.profile(['none','di'].includes(paper)?'kodak_portra_endura':paper);
  const ok=this.module.ccall('spk_prepare','number',['string','string','string','string'],[this.root,film,paper,JSON.stringify(options)]);
  if(!ok)throw Error(this.error());this.key=key;
 }
 gpuData(){const m=this.module,ptr=m._spk_gpu_data(),n=m._spk_gpu_size();return m.HEAPF32.slice(ptr/4,ptr/4+n);}
 lut(size=33){const m=this.module,n=size**3*4,ptr=m._malloc(n*4);if(!ptr)throw Error('原生 LUT 内存不足');try{if(!m._spk_lut(ptr,size))throw Error(this.error());return m.HEAPF32.slice(ptr/4,ptr/4+n);}finally{m._free(ptr);}}
 pixels(input){if(input.length%3)throw Error('RGB 输入长度错误');const m=this.module,n=input.length,p=m._malloc(n*8),q=m._malloc(n*8);if(!p||!q){if(p)m._free(p);if(q)m._free(q);throw Error('原生探针内存不足');}try{m.HEAPF64.set(input,p/8);m._spk_pixels(p,q,n/3);return m.HEAPF64.slice(q/8,q/8+n);}finally{m._free(p);m._free(q);}}
}
let loading;
export function loadNativeCore(){return loading ||= NativeCore.load();}
let gpuDisabled=false,gpuChecked=false;
export async function buildNativeLUT(film,paper,options={},size=33){
 const core=await loadNativeCore();await core.prepare(film,paper,options);
 let warning=null;
 if(!gpuDisabled)try{
  const gpu=await loadNativeWebGPU();if(gpu){
   const data=core.gpuData();
   if(!gpuChecked){const probe=new Float32Array([0,0,0,.184,.184,.184,1,0,0,0,1,0,0,0,1,16,16,16,.42,.19,.065]),expected=core.pixels(probe),actual=await gpu.run(data,{input:probe});let max=0;for(let i=0;i<expected.length;i++)max=Math.max(max,Math.abs(expected[i]-actual[Math.floor(i/3)*4+i%3]));if(max>3e-5)throw Error('WebGPU 数值自检超出允许误差：'+max);gpuChecked=true;}
   return {data:await gpu.run(data,{size}),engine:'C++ WASM setup + WebGPU pointwise',warning:null};
  }
 }catch(e){gpuDisabled=true;warning=e.message;console.warn('WebGPU native pointwise unavailable; using the same C++ WASM adapter:',warning);}
 return {data:core.lut(size),engine:'C++ WASM pointwise',warning};
}
