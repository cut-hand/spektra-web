/* SPDX-License-Identifier: GPL-3.0-or-later */
// Only an explicitly selected, successfully initialized GPU receives frames.
// Keep one transferable backup so a device failure can retry the same pixels in WASM.
export class BackendRouter{
 constructor(cpu,onChange=()=>{}){this.cpu=cpu;this.onChange=onChange;this.active='wasm';this.pending=new Map();this.next=0;this.worker=null;this.stats=null;}
 get mode(){return this.active==='webgpu'?'WebGPU':'C++ WASM';}
 async select(mode){if(mode==='wasm'){this.active='wasm';this.onChange();return;}if(mode!=='webgpu')throw Error('Unknown backend');if(!this.worker){this.worker=new Worker(new URL('./worker.js',import.meta.url),{type:'module'});this.worker.onmessage=({data})=>{const job=this.pending.get(data.id);if(!job)return;clearTimeout(job.timer);this.pending.delete(data.id);data.error?job.reject(Error(data.error)):job.resolve(data);};this.worker.onerror=e=>this.fail(Error(e.message||'WebGPU 线程错误'));}try{await this.gpu({type:'init'});this.active='webgpu';this.onChange();}catch(e){this.fail(e);throw e;}}
 gpu(message,transfer=[]){return new Promise((resolve,reject)=>{const id=++this.next,timer=setTimeout(()=>{this.pending.delete(id);reject(Error('WebGPU 处理超时'));},120000);this.pending.set(id,{resolve,reject,timer});this.worker.postMessage({...message,id},transfer);});}
 fail(e){this.active='wasm';this.worker?.terminate();this.worker=null;for(const job of this.pending.values()){clearTimeout(job.timer);job.reject(e);}this.pending.clear();this.onChange(e);}
 async request(message,transfer=[]){if(message.type!=='frame'||this.active!=='webgpu')return this.cpu(message,transfer);const backup=structuredClone(message);try{const result=await this.gpu(message,transfer);this.stats=result.stats;return result;}catch(e){this.fail(e);const fallback=[backup.pixels,...(backup.overlay?[backup.overlay.indices.buffer,backup.overlay.pixels.buffer]:[])];return this.cpu(backup,fallback);}}
 dispose(){this.fail(Error('Backend disposed'));}
}
