/* SPDX-License-Identifier: GPL-3.0-or-later */
// Device buffers persist across the original C++ pipeline's dispatches.
// CPU reads are explicit, asynchronous staging transfers, never a shader fallback.
export class WebGPURuntime{
 static async create(){
  if(!navigator.gpu)throw Error('此浏览器不支持 WebGPU');
  const adapter=await navigator.gpu.requestAdapter({powerPreference:'high-performance'});if(!adapter)throw Error('没有可用的 WebGPU 适配器');
  const device=await adapter.requestDevice({requiredLimits:{maxStorageBuffersPerShaderStage:Math.min(10,adapter.limits.maxStorageBuffersPerShaderStage),maxStorageBufferBindingSize:Math.min(268435456,adapter.limits.maxStorageBufferBindingSize),maxBufferSize:Math.min(536870912,adapter.limits.maxBufferSize)}});
  const runtime=new WebGPURuntime(device);runtime.adapter=adapter;
  device.addEventListener('uncapturederror',e=>{runtime.error??=e.error.message;});device.lost.then(info=>{runtime.error='WebGPU 设备丢失：'+info.message;runtime.lost=true;});
  const manifest=await fetch(new URL('./shaders/manifest.json',import.meta.url)).then(r=>r.json());runtime.manifest=manifest;
  await Promise.all(Object.entries(manifest.kernels).map(async([name,meta])=>{
   const code=await fetch(new URL('./shaders/'+name+'.wgsl',import.meta.url)).then(r=>r.text()),module=device.createShaderModule({label:name,code});
   const info=await module.getCompilationInfo();const errors=info.messages.filter(x=>x.type==='error');if(errors.length)throw Error(name+': '+errors.map(x=>x.message).join('; '));
   const layout=device.createBindGroupLayout({entries:meta.bindings.map(b=>({binding:b.binding,visibility:GPUShaderStage.COMPUTE,buffer:{type:b.access==='read'?'read-only-storage':'storage'}}))});
   const pipeline=await device.createComputePipelineAsync({label:name,layout:device.createPipelineLayout({bindGroupLayouts:[layout]}),compute:{module,entryPoint:'main'}});runtime.kernels.set(name,{pipeline,layout,meta});
  }));return runtime;
 }
 constructor(device){this.device=device;this.buffers=new Map();this.next=1;this.kernels=new Map();this.encoder=null;this.pass=null;this.garbage=[];this.error=null;this.stats={dispatches:0,submissions:0,readbacks:0,uploadedBytes:0,readbackBytes:0,kernels:{}};}
 check(){if(this.error)throw Error(this.error);}
 create(bytes){this.check();const id=this.next++,size=Math.max(4,Math.ceil(bytes/4)*4);this.buffers.set(id,this.device.createBuffer({size,usage:GPUBufferUsage.STORAGE|GPUBufferUsage.COPY_SRC|GPUBufferUsage.COPY_DST}));return id;}
 destroy(id){const b=this.buffers.get(id);if(!b)return;this.buffers.delete(id);if(this.encoder)this.garbage.push(b);else b.destroy();}
 write(id,bytes){this.check();if(!bytes.byteLength)return;this.endPass();const staging=this.device.createBuffer({size:Math.ceil(bytes.byteLength/4)*4,usage:GPUBufferUsage.COPY_SRC,mappedAtCreation:true});new Uint8Array(staging.getMappedRange()).set(bytes);staging.unmap();this.commands().copyBufferToBuffer(staging,0,this.buffers.get(id),0,bytes.byteLength);this.garbage.push(staging);this.stats.uploadedBytes+=bytes.byteLength;}
 commands(){if(!this.encoder)this.encoder=this.device.createCommandEncoder();return this.encoder;}
 endPass(){if(this.pass){this.pass.end();this.pass=null;}}
 dispatch(name,ids,n){this.check();const k=this.kernels.get(name);if(!k)throw Error('WebGPU 内核未实现：'+name);
  this.endPass();const writes=new Set(k.meta.bindings.filter(b=>b.access==='read_write').map(b=>ids[b.binding]));
  const entries=k.meta.bindings.map(b=>{let buffer=this.buffers.get(ids[b.binding]);if(b.access==='read'&&writes.has(ids[b.binding])){const copy=this.device.createBuffer({size:buffer.size,usage:GPUBufferUsage.STORAGE|GPUBufferUsage.COPY_DST});this.commands().copyBufferToBuffer(buffer,0,copy,0,buffer.size);buffer=copy;this.garbage.push(copy);this.stats.aliasCopies=(this.stats.aliasCopies||0)+1;}return {binding:b.binding,resource:{buffer}};});
  const bind=this.device.createBindGroup({layout:k.layout,entries});if(!this.pass)this.pass=this.commands().beginComputePass();this.pass.setPipeline(k.pipeline);this.pass.setBindGroup(0,bind);
  const groups=Math.ceil(n/256),x=Math.min(groups,65535),y=Math.ceil(groups/x);this.pass.dispatchWorkgroups(x,y);
  this.stats.dispatches++;this.stats.kernels[name]=(this.stats.kernels[name]||0)+1;
 }
 copy(dst,dstOffset,src,srcOffset,bytes){this.check();this.endPass();this.commands().copyBufferToBuffer(this.buffers.get(src),srcOffset,this.buffers.get(dst),dstOffset,bytes);}
 submit(){if(!this.encoder)return;this.endPass();this.device.queue.submit([this.encoder.finish()]);this.encoder=null;for(const b of this.garbage)b.destroy();this.garbage=[];this.stats.submissions++;}
 async read(id,offset,bytes){this.check();this.endPass();const staging=this.device.createBuffer({size:Math.max(4,bytes),usage:GPUBufferUsage.COPY_DST|GPUBufferUsage.MAP_READ});this.commands().copyBufferToBuffer(this.buffers.get(id),offset,staging,0,bytes);this.submit();try{await staging.mapAsync(GPUMapMode.READ);this.check();const result=new Uint8Array(staging.getMappedRange()).slice();this.stats.readbacks++;this.stats.readbackBytes+=bytes;return result;}finally{staging.destroy();}}
 async complete(){this.submit();await this.device.queue.onSubmittedWorkDone();this.check();}
 dispose(){this.submit();for(const b of this.buffers.values())b.destroy();this.buffers.clear();this.device.destroy();}
}
