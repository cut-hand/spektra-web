/* SPDX-License-Identifier: GPL-3.0-or-later */
import createCore from './vendor/spektralab/dist/core.mjs';
export const nativeCoreVersion='SpektraLab 1.3.4 / C++ WASM full frame / ProPhoto RGB';
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

 lut(size=33){const m=this.module,n=size**3*4,ptr=m._malloc(n*4);if(!ptr)throw Error('原生 LUT 内存不足');try{if(!m._spk_lut(ptr,size))throw Error(this.error());return m.HEAPF32.slice(ptr/4,ptr/4+n);}finally{m._free(ptr);}}
 pixels(input){if(input.length%3)throw Error('RGB 输入长度错误');const m=this.module,n=input.length,p=m._malloc(n*8),q=m._malloc(n*8);if(!p||!q){if(p)m._free(p);if(q)m._free(q);throw Error('原生探针内存不足');}try{m.HEAPF64.set(input,p/8);m._spk_pixels(p,q,n/3);return m.HEAPF64.slice(q/8,q/8+n);}finally{m._free(p);m._free(q);}}
 convert(input,src,dst,encoded=true){const m=this.module,n=input.length,p=m._malloc(n*4),q=m._malloc(n*4);if(!p||!q){if(p)m._free(p);if(q)m._free(q);throw Error('色彩转换内存不足');}try{m.HEAPF32.set(input,p/4);if(!m.ccall('spk_convert','number',['number','number','number','string','string','number'],[p,q,n/3,src,dst,+encoded]))throw Error(this.error());return m.HEAPF32.slice(q/4,q/4+n);}finally{m._free(p);m._free(q);}}

 frame(input,width,height,options={}){if(input.length!==width*height*3)throw Error('原生照片尺寸错误');const m=this.module,n=input.length,p=m._malloc(n*4),q=m._malloc(n*4);if(!p||!q){if(p)m._free(p);if(q)m._free(q);throw Error('WASM 内存不足，请降低输出尺寸');}try{m.HEAPF32.set(input,p/4);if(!m.ccall('spk_frame','number',['number','number','number','number','string'],[p,q,width,height,JSON.stringify(options)]))throw Error(this.error());return {data:m.HEAPF32.slice(q/4,q/4+n),meterEV:m._spk_meter_ev()};}finally{m._free(p);m._free(q);}}

}
let loading;
export function loadNativeCore(){return loading ||= NativeCore.load();}
export async function buildNativeLUT(film,paper,options={},size=33){
 const core=await loadNativeCore();await core.prepare(film,paper,options);
 return {data:core.lut(size),engine:'C++ WASM · ProPhoto RGB full frame',warning:null};
}
