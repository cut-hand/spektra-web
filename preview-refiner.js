/* SPDX-License-Identifier: GPL-3.0-or-later */
import {Renderer} from './renderer.js';
// A disposable second CPU Worker keeps slow detail work off the interaction
// queue. Terminating it cancels stale synchronous WASM and releases its heap.
export class PreviewRefiner{
 constructor(){this.job=null;}
 cancel(){if(!this.job)return;const job=this.job;this.job=null;clearTimeout(job.timer);job.worker.terminate();job.reject(new DOMException('Preview superseded','AbortError'));}
 async render(source,params){
  this.cancel();const worker=new Worker(new URL('./engine-worker.js',import.meta.url),{type:'module'});
  let job;
  const request=(m,transfer)=>new Promise((resolve,reject)=>{
   job={worker,reject,timer:setTimeout(()=>reject(Error('清晰预览计算超时，请缩小查看比例')),120000)};this.job=job;
   worker.onmessage=({data:r})=>r.error?reject(Error(r.error)):resolve(r);
   worker.onerror=e=>reject(Error(e.message||'清晰预览线程发生错误'));
   worker.postMessage({...m,id:1},transfer);
  });
  const renderer=new Renderer(request);
  try{const canvas=await renderer.render(source,{...params,compare:0});return {canvas,meterEV:renderer.meterEV};}
  finally{if(job)clearTimeout(job.timer);worker.terminate();if(this.job===job)this.job=null;}
 }
}
