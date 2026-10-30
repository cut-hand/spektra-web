/* SPDX-License-Identifier: GPL-3.0-or-later */
let detected;
export function displayColour(){
 if(detected)return detected;
 if(typeof document!=='undefined')try{
  const c=document.createElement('canvas'),ctx=c.getContext('2d',{colorSpace:'display-p3'}),data=new ImageData(1,1,{colorSpace:'display-p3'});
  if(ctx?.getContextAttributes?.().colorSpace==='display-p3'&&data.colorSpace==='display-p3')return detected={canvas:'display-p3',native:'Display P3'};
 }catch{}
 return detected={canvas:'srgb',native:'sRGB'};
}
export function canvasColour(canvas){return canvas?.getContext('2d')?.getContextAttributes?.().colorSpace||'srgb';}
