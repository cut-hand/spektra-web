/* SPDX-License-Identifier: GPL-3.0-or-later */
import {geometryFor} from './photography.js';
// Map output pixel centres through the same affine transform as Canvas2D.
// Resampling occurs before any 8-bit canvas quantisation.
export function resample16(bitmap,p,width,height){const source=bitmap.rgbFloat||bitmap.rgb16,divisor=bitmap.rgbFloat?1:65535;if(!source)return null;const g=geometryFor(bitmap,p),out=new Float32Array(width*height*3),cos=Math.cos(g.angle),sin=Math.sin(g.angle),rot=p.rotation%4,channels=bitmap.rgbChannels||3,w=bitmap.width,h=bitmap.height;
 for(let y=0;y<height;y++)for(let x=0;x<width;x++){let dx=((x+.5)/width-.5)*g.cw,dy=((y+.5)/height-.5)*g.ch;const rx=cos*dx+sin*dy,ry=-sin*dx+cos*dy;dx=rx*(p.flipH?-1:1)+g.cx-g.w/2;dy=ry*(p.flipV?-1:1)+g.cy-g.h/2;let sx,sy;if(rot===0){sx=dx;sy=dy;}else if(rot===1){sx=dy;sy=-dx;}else if(rot===2){sx=-dx;sy=-dy;}else{sx=-dy;sy=dx;}sx=Math.max(0,Math.min(w-1,sx+w/2-.5));sy=Math.max(0,Math.min(h-1,sy+h/2-.5));const x0=Math.floor(sx),y0=Math.floor(sy),x1=Math.min(w-1,x0+1),y1=Math.min(h-1,y0+1),tx=sx-x0,ty=sy-y0,a=(y0*w+x0)*channels,b=(y0*w+x1)*channels,c=(y1*w+x0)*channels,d=(y1*w+x1)*channels,j=(y*width+x)*3;for(let k=0;k<3;k++)out[j+k]=((source[a+k]*(1-tx)+source[b+k]*tx)*(1-ty)+(source[c+k]*(1-tx)+source[d+k]*tx)*ty)/divisor;}return out;
}
