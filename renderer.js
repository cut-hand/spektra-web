/* SPDX-License-Identifier: GPL-3.0-or-later */
import {cameraGains} from './effects.js';
// All photographic computation runs in the C++ Worker. Canvas2D presents
// already transformed sRGB pixels; no WebGPU or WebGL context is requested.
export class Renderer{
 constructor(request){this.request=request;this.gl=null;this.mode='C++ WASM';this.maxSize=8192;this.floatOutput=true;}
 setLUT(lut){this.lut=lut;}
 async render(source,p,{floating=false}={}){
  const {width,height}=source,n=width*height;
  let input;if(source.floatPixels)input=source.floatPixels.slice();else{const bytes=source.getContext('2d').getImageData(0,0,width,height).data;input=new Float32Array(n*3);for(let i=0;i<n;i++)for(let c=0;c<3;c++)input[i*3+c]=bytes[i*4+c]/255;}
  const params={...p,cameraGains:cameraGains(p),sourceColorSpace:source.sourceColorSpace||'sRGB',sourceEncoded:source.sourceEncoded!==false,sourceLongEdge:source.sourceLongEdge||Math.max(width,height),frameLongEdge:source.frameLongEdge||Math.max(width,height),targetColorSpace:floating?'ProPhoto RGB':'sRGB'};
  let overlay=null;if(source.overlayBefore){const after=source.getContext('2d').getImageData(0,0,width,height).data,indices=[],values=[];for(let i=0;i<n;i++)if([0,1,2].some(c=>after[i*4+c]!==source.overlayBefore[i*4+c])){indices.push(i);for(let c=0;c<3;c++)values.push(after[i*4+c]/255);}overlay={indices:new Uint32Array(indices),pixels:new Float32Array(values)};}
  const r=await this.request({type:'frame',pixels:input.buffer,width,height,params,overlay},[input.buffer,...(overlay?[overlay.indices.buffer,overlay.pixels.buffer]:[])]);this.meterEV=r.meterEV;
  const rgb=new Float32Array(r.pixels),data=floating?new Float32Array(n*4):new Uint8ClampedArray(n*4);
  const original=p.compare?source.originalCanvas||source:null,bytes=original?.getContext('2d').getImageData(0,0,width,height).data;
  for(let i=0;i<n;i++){const compare=p.compare===2||(p.compare===1&&(i%width)/width<p.split);for(let c=0;c<3;c++)data[i*4+c]=compare?bytes[i*4+c]:floating?rgb[i*3+c]:Math.round(Math.max(0,Math.min(1,rgb[i*3+c]))*255);data[i*4+3]=floating?1:255;}
  if(floating)return {width,height,data,colorSpace:'ProPhoto RGB'};
  const canvas=document.createElement('canvas');canvas.width=width;canvas.height=height;canvas.getContext('2d',{colorSpace:'srgb'}).putImageData(new ImageData(data,width,height),0,0);return canvas;
 }
}
