/* SPDX-License-Identifier: GPL-3.0-or-later */
import {cameraGains} from './effects.js';
import {displayColour,canvasColour} from './display-colour.js';
// The selected WASM or WebGPU Worker runs the photographic pipeline.
// Canvas2D presents tagged sRGB / Display P3 output pixels.
export class Renderer{
 constructor(request){this.request=request;this.gl=null;this.mode='C++ WASM';this.maxSize=8192;this.floatOutput=true;this.processed=null;this.nativeCalls=0;this.display=displayColour();}
 setLUT(lut){this.lut=lut;}
 async render(source,p,{floating=false,display=true}={}){
  const {width,height}=source,n=width*height;
  if(!floating&&p.compare===2)return source.originalCanvas||source;
  const key=JSON.stringify([{...p,compare:0,split:0},display]);
  if(!floating&&this.processed?.source===source&&this.processed.key===key){this.meterEV=this.processed.meterEV;return this.compose(this.processed.canvas,source,p);}
  ++this.nativeCalls;
  let input;if(source.floatPixels)input=source.floatPixels.slice();else{const bytes=source.getContext('2d').getImageData(0,0,width,height).data;input=new Float32Array(n*3);for(let i=0;i<n;i++)for(let c=0;c<3;c++)input[i*3+c]=bytes[i*4+c]/255;}
  const params={...p,cameraGains:cameraGains(p),sourceColorSpace:source.sourceColorSpace||'sRGB',sourceEncoded:source.sourceEncoded!==false,sourceLongEdge:source.sourceLongEdge||Math.max(width,height),frameLongEdge:source.frameLongEdge||Math.max(width,height),targetColorSpace:floating?'ProPhoto RGB':display?this.display.native:'sRGB',displayOutput:display&&!floating};
  let overlay=null;if(source.overlayBefore){const after=source.getContext('2d').getImageData(0,0,width,height).data,indices=[],values=[];for(let i=0;i<n;i++)if([0,1,2].some(c=>after[i*4+c]!==source.overlayBefore[i*4+c])){indices.push(i);for(let c=0;c<3;c++)values.push(after[i*4+c]/255);}overlay={indices:new Uint32Array(indices),pixels:new Float32Array(values)};}
  const r=await this.request({type:'frame',pixels:input.buffer,width,height,params,overlay},[input.buffer,...(overlay?[overlay.indices.buffer,overlay.pixels.buffer]:[])]);this.meterEV=r.meterEV;
  const rgb=new Float32Array(r.pixels),data=floating?new Float32Array(n*4):new Uint8ClampedArray(n*4);
  for(let i=0;i<n;i++){for(let c=0;c<3;c++)data[i*4+c]=floating?rgb[i*3+c]:Math.round(Math.max(0,Math.min(1,rgb[i*3+c]))*255);data[i*4+3]=floating?1:255;}
  if(floating)return {width,height,data,colorSpace:'ProPhoto RGB'};
  const space=display?this.display.canvas:'srgb',canvas=document.createElement('canvas');canvas.width=width;canvas.height=height;canvas.getContext('2d',{colorSpace:space}).putImageData(new ImageData(data,width,height,{colorSpace:space}),0,0);this.processed={source,key,canvas,meterEV:this.meterEV};return this.compose(canvas,source,p);
 }
 compose(processed,source,p){if(p.compare!==1)return processed;const canvas=document.createElement('canvas');canvas.width=processed.width;canvas.height=processed.height;const ctx=canvas.getContext('2d',{colorSpace:canvasColour(processed)});ctx.drawImage(processed,0,0);ctx.save();ctx.beginPath();ctx.rect(0,0,canvas.width*p.split,canvas.height);ctx.clip();ctx.drawImage(source.originalCanvas||source,0,0);ctx.restore();return canvas;}
}
