/* SPDX-License-Identifier: GPL-3.0-or-later */
import {sampleLUT,decode,clamp} from './engine.js';
import {preEffects,postEffects} from './effects.js';
export function renderCPU({pixels,originalPixels,width,height,params:p,lut,floating=false,floatPixels}){
 const src=new Uint8ClampedArray(pixels),original=originalPixels?new Uint8ClampedArray(originalPixels):src,out=floating?new Float32Array(src.length):new Uint8ClampedArray(src.length);
 const sample=(x,y)=>{const j=(clamp(Math.round(y),0,height-1)*width+clamp(Math.round(x),0,width-1))*4;return floatPixels?[floatPixels[j/4*3],floatPixels[j/4*3+1],floatPixels[j/4*3+2]]:[src[j]/255,src[j+1]/255,src[j+2]/255];};
 const hash=(x,y)=>{let a=Math.imul(x^7321,374761393)^Math.imul(y^1987,668265263);a=Math.imul(a^(a>>>13),1274126177);return ((a^(a>>>16))>>>0)/4294967295;};
 const mm=p.filmLongMm||35,dirs=Array.from({length:8},(_,i)=>[Math.cos(i*Math.PI/4),Math.sin(i*Math.PI/4)]);
 for(let i=0;i<src.length;i+=4){const x=(i/4)%width,y=Math.floor(i/4/width),u=x/width,v=y/height,org=[original[i]/255,original[i+1]/255,original[i+2]/255];let encoded=sample(x,y),lin;
 if(p.lensBlur>0){const r=width*p.lensBlur/(mm*1000),sum=encoded.map(decode).map(c=>c*2);for(const [dx,dy] of dirs){const s=sample(x+dx*r,y+dy*r);for(let k=0;k<3;k++)sum[k]+=decode(s[k]);}encoded=sum.map(c=>{const q=c/10;return q<=.0031308?q*12.92:1.055*q**(1/2.4)-.055;});}
 lin=preEffects(encoded,p);if(p.halation>0||p.diffusion>0){const r=width*.00185*Math.sqrt(p.halationRadius||1)*35/mm*(p.antihalationRemoved?2.5:1),glow=[0,0,0];for(const [dx,dy] of dirs){const s=sample(x+dx*r,y+dy*r);for(let k=0;k<3;k++)glow[k]+=Math.max(0,decode(s[k])-.45)/8;}lin=lin.map((c,k)=>c+glow[k]*([.65,.12,.01][k]*(p.halation||0)/100*(p.antihalationRemoved?4:1)+(p.diffusion||0)/100*.45));}
 let rgb=sampleLUT(lut,lin);if(p.sharpen>0){const avg=[0,0,0];for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]){const s=sampleLUT(lut,preEffects(sample(x+dx,y+dy),p));for(let k=0;k<3;k++)avg[k]+=s[k]/4;}rgb=rgb.map((c,k)=>c+(c-avg[k])*p.sharpen/100*1.5);}
 let maskEV=0;if(p.contrastMaskHighlights>0||p.contrastMaskShadows>0){let base=0;for(const [dx,dy] of dirs){const s=sample(x+dx*width*.03,y+dy*width*.03);base+=(s[0]*.2126+s[1]*.7152+s[2]*.0722)/8;}maskEV=(p.contrastMaskShadows||0)*Math.max(0,.4-base)*1.5-(p.contrastMaskHighlights||0)*Math.max(0,base-.6)*1.5;}
 rgb=postEffects(rgb,{...p,exposure:(p.exposure||0)+maskEV});const cell=3200/(p.format==='120'?1:1.8)/(p.grainSize||1)*35/mm,nx=Math.floor(u*cell),ny=Math.floor(v*cell*height/width),noise=hash(nx,ny)-.5,chroma=(p.grainChroma||0)/100,ns=[noise,noise*(1-chroma)+(hash(nx+97,ny+53)-.5)*chroma,noise*(1-chroma)+(hash(nx+31,ny+17)-.5)*chroma],vig=1-(p.vignette||0)/100*clamp(((u-.5)**2+(v-.5)**2)*1.5);rgb=rgb.map((c,k)=>(c+ns[k]*(p.grain||0)/100*.09)*vig);
 if(p.compare===2||(p.compare===1&&u<p.split))rgb=org;for(let k=0;k<3;k++)out[i+k]=floating?clamp(rgb[k]):Math.round(clamp(rgb[k])*255);out[i+3]=floating?1:255;
 }return out;
}
