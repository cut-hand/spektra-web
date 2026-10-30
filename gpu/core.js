/* SPDX-License-Identifier: GPL-3.0-or-later */
import createCore from '../vendor/spektralab/dist/gpu-core.mjs';
import {NativeCore} from '../native-core.js';
import {WebGPURuntime} from './runtime.js';
export async function createWebGPUCore(){const runtime=await WebGPURuntime.create();const core=await NativeCore.load({moduleFactory:createCore});core.module.spkGPU=runtime;
 core.frame=async function(input,width,height,options={}){if(input.length!==width*height*3)throw Error('WebGPU frame dimensions');const m=this.module,n=input.length,p=m._malloc(n*4);if(!p)throw Error('WebGPU transfer memory unavailable');try{m.HEAPF32.set(input,p/4);const ok=await m.ccall('spk_frame','number',['number','number','number','number','string'],[p,p,width,height,JSON.stringify(options)],{async:true});if(!ok)throw Error(runtime.error||this.error());await runtime.complete();return {data:m.HEAPF32.slice(p/4,p/4+n),meterEV:m._spk_meter_ev(),stats:structuredClone(runtime.stats)};}finally{m._free(p);}};
 core.runtime=runtime;return core;
}
