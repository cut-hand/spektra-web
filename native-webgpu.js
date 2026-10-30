/* SPDX-License-Identifier: GPL-3.0-or-later */
export class NativeWebGPU {
 static async create(){
  if(!globalThis.navigator?.gpu)return null;const adapter=await navigator.gpu.requestAdapter();if(!adapter)return null;
  const device=await adapter.requestDevice();const response=await fetch(new URL('./native/pointwise.wgsl',import.meta.url));if(!response.ok)throw Error('WebGPU 原生计算程序加载失败');
  const shader=device.createShaderModule({code:await response.text(),label:'Spektra native pointwise'}),info=await shader.getCompilationInfo();const errors=info.messages.filter(x=>x.type==='error');if(errors.length)throw Error(errors.map(x=>`${x.lineNum}: ${x.message}`).join('\n'));
  const pipeline=await device.createComputePipelineAsync({layout:'auto',compute:{module:shader,entryPoint:'main'}});return new NativeWebGPU(device,pipeline);
 }
 constructor(device,pipeline){this.device=device;this.pipeline=pipeline;this.lost=null;device.lost.then(info=>this.lost=info.message||'WebGPU 设备已重置');}
 async run(data,{size=0,input}={}){
  if(this.lost)throw Error(this.lost);const count=size?size**3:input.length/3;if(!Number.isInteger(count)||count<1)throw Error('无效 WebGPU 输入');
  const d=this.device,buffers=[],make=(bytes,usage)=>{const b=d.createBuffer({size:Math.max(16,bytes),usage});buffers.push(b);return b;};
  d.pushErrorScope('validation');let scope=true;
  try{
   const constants=make(data.byteLength,GPUBufferUsage.STORAGE|GPUBufferUsage.COPY_DST);d.queue.writeBuffer(constants,0,data);
   const pixels=new Float32Array(size?4:count*4);if(!size)for(let i=0;i<count;i++)for(let c=0;c<3;c++)pixels[i*4+c]=input[i*3+c];
   const src=make(pixels.byteLength,GPUBufferUsage.STORAGE|GPUBufferUsage.COPY_DST);d.queue.writeBuffer(src,0,pixels);
   const out=make(count*16,GPUBufferUsage.STORAGE|GPUBufferUsage.COPY_SRC),read=make(count*16,GPUBufferUsage.MAP_READ|GPUBufferUsage.COPY_DST),meta=make(16,GPUBufferUsage.UNIFORM|GPUBufferUsage.COPY_DST);d.queue.writeBuffer(meta,0,new Uint32Array([count,size,0,0]));
   const group=d.createBindGroup({layout:this.pipeline.getBindGroupLayout(0),entries:[constants,src,out,meta].map((buffer,binding)=>({binding,resource:{buffer}}))});
   const encoder=d.createCommandEncoder(),pass=encoder.beginComputePass();pass.setPipeline(this.pipeline);pass.setBindGroup(0,group);pass.dispatchWorkgroups(Math.ceil(count/64));pass.end();encoder.copyBufferToBuffer(out,0,read,0,count*16);d.queue.submit([encoder.finish()]);
   const validation=await d.popErrorScope();scope=false;if(validation)throw Error(validation.message);await read.mapAsync(GPUMapMode.READ);const result=new Float32Array(read.getMappedRange().slice(0));read.unmap();if(!result.every(Number.isFinite))throw Error('WebGPU 原生颜色计算产生无效数值');return result;
  }finally{if(scope)await d.popErrorScope();for(const b of buffers)b.destroy();}
 }
}
let loading;
export function loadNativeWebGPU(){return loading ||= NativeWebGPU.create();}
