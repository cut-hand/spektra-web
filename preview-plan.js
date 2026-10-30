/* SPDX-License-Identifier: GPL-3.0-or-later */
// Zoom refers to source pixels per screen pixel, independent of draft resolution.
export function previewPlan({width,height,frameWidth=width,frameHeight=height,availableWidth,availableHeight,dpr=1,zoom=0,maxPixels=6000000,maxEdge=4096}){
 dpr=Math.max(1,dpr||1);
 const fit=Math.min(availableWidth/frameWidth,availableHeight/frameHeight),cssScale=zoom===0?fit:zoom/dpr;
 const density=Math.min(1,cssScale*dpr,maxEdge/Math.max(width,height),Math.sqrt(maxPixels/(width*height)));
 return {cssWidth:Math.max(1,Math.round(frameWidth*cssScale)),cssHeight:Math.max(1,Math.round(frameHeight*cssScale)),zoom:cssScale*dpr,width:Math.max(1,Math.floor(width*density)),height:Math.max(1,Math.floor(height*density)),edge:Math.max(1,Math.ceil(Math.max(width,height)*density)),limited:density+1e-6<Math.min(1,cssScale*dpr)};
}
export function previewSignature(p){const {compare,split,meterEV,...photo}=p;return JSON.stringify(photo);}
export function photoInformation({width,height,sourceSpace='sRGB',raw=false,fullRaw=false,demo=false,previewWidth,previewHeight,refining=false,limited=false}){
 const state=refining?' · 正在精化预览':limited?' · 预览尺寸受限':'';
 return {text:`${Math.round(width)} × ${Math.round(height)} · 工作：ProPhoto RGB${raw?' · RAW 16 位':''}${demo?' · AI 示例':''}${state}`,
 title:`输入：${sourceSpace}${raw?(fullRaw?'（RAW 完整解码）':'（RAW 半尺寸解码）'):''}\n工作空间：ProPhoto RGB\n屏幕显示：sRGB\n当前预览：${previewWidth} × ${previewHeight}${limited?'（受预览内存上限限制）':''}\n导出：TIFF 为 ProPhoto RGB；JPEG / PNG 为 sRGB`};
}
