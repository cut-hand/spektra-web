/* SPDX-License-Identifier: GPL-3.0-or-later */
import {sampleLUT,decode} from './engine.js';
import {preEffects} from './effects.js';
const luminance=rgb=>.2126*decode(rgb[0])+.7152*decode(rgb[1])+.0722*decode(rgb[2]);

// This is the browser model's own usable tone range, not native-engine latitude.
export function latitudeWindow(lut){
 const values=Array.from({length:113},(_,i)=>{const ev=-8+i/8,v=.184*2**ev;return luminance(lut.neutral?Array.from(lut.neutral.subarray(i*3,i*3+3)):sampleLUT(lut,[v,v,v]));});
 const slopes=values.slice(1).map((v,i)=>Math.max(0,v-values[i]));
 const peak=Math.max(...slopes),range=fraction=>{const ids=slopes.map((v,i)=>v>=peak*fraction&&v>1e-8?i:-1).filter(i=>i>=0);return ids.length?[-8+ids[0]/8,-8+(ids.at(-1)+1)/8]:[-8,6];};
 return {usable:range(.05),full:range(.25)};
}

export function mountLatitudeView(container){
 const root=document.createElement('div');root.className='latitude-view';root.innerHTML='<canvas id="latitudeHistogram" width="640" height="170" aria-label="场景曝光档位直方图，浏览器模型近似"></canvas><div class="latitude-ramp"></div><div class="latitude-axis">'+[-8,-6,-4,-2,0,2,4,6,8].map(n=>'<span>'+(n>0?'+':'')+n+'</span>').join('')+'</div><div class="latitude-coverage"><span>低于 <b id="latitudeLow">—</b></span><span>范围内 <b id="latitudeInside">—</b></span><span>高于 <b id="latitudeHigh">—</b></span></div><div id="latitudeLimits" class="latitude-limits">显影后即可按当前胶片与相纸测量。</div>';
 container.append(root);const canvas=root.querySelector('canvas'),ctx=canvas.getContext('2d');let previousLUT=null,window=null,previousSource=null,previousExposureKey='';
 const stops=x=>(x>=0?'+':'')+x.toFixed(2);
 return {update(source,lut,params){
  if(!lut)return;const exposureKey=JSON.stringify(['cameraTemperature','cameraTint','cameraExposure','meterEV','headroom','sceneHighlights','sceneShadows'].map(k=>params[k]));if(source===previousSource&&lut===previousLUT&&exposureKey===previousExposureKey)return;previousSource=source;previousExposureKey=exposureKey;if(lut!==previousLUT){window=latitudeWindow(lut);previousLUT=lut;}
  const small=document.createElement('canvas');small.width=160;small.height=Math.max(1,Math.round(160*source.height/source.width));const c=small.getContext('2d',{willReadFrequently:true});c.drawImage(source,0,0,small.width,small.height);const data=c.getImageData(0,0,small.width,small.height).data,bins=new Uint32Array(161);let below=0,above=0,total=0;
  for(let i=0;i<data.length;i+=4){const lin=preEffects([data[i]/255,data[i+1]/255,data[i+2]/255],params),y=Math.max(1e-8,.2126*lin[0]+.7152*lin[1]+.0722*lin[2]),ev=Math.log2(y/.184);bins[Math.max(0,Math.min(160,Math.floor((ev+8)*10)))]++;if(ev<window.usable[0])below++;else if(ev>window.usable[1])above++;total++;}
  const w=canvas.width,h=canvas.height,max=Math.max(1,...bins),x=ev=>(ev+8)/16*w;ctx.clearRect(0,0,w,h);ctx.fillStyle='#1e1f1d';ctx.fillRect(0,0,w,h);ctx.fillStyle='#ffffff08';ctx.fillRect(x(window.usable[0]),0,x(window.usable[1])-x(window.usable[0]),h);
  ctx.strokeStyle='#343532';ctx.lineWidth=1;for(let ev=-8;ev<=8;ev+=2){ctx.beginPath();ctx.moveTo(x(ev),0);ctx.lineTo(x(ev),h);ctx.stroke();}
  ctx.beginPath();ctx.moveTo(0,h);for(let i=0;i<bins.length;i++){const xx=i/(bins.length-1)*w,yy=h-8-bins[i]/max*(h-18);ctx.lineTo(xx,yy);ctx.lineTo(xx+w/(bins.length-1),yy);}ctx.lineTo(w,h);ctx.closePath();ctx.fillStyle='#a6a6a6aa';ctx.fill();
  for(let i=0;i<bins.length-1;i++){const ev=-8+i/10;ctx.strokeStyle=ev<window.usable[0]||ev>window.usable[1]?'#dea74f':'#d8d8d3';ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(i/160*w,h-8-bins[i]/max*(h-18));ctx.lineTo((i+1)/160*w,h-8-bins[i+1]/max*(h-18));ctx.stroke();}
  ctx.setLineDash([4,4]);ctx.strokeStyle='#ddd';ctx.lineWidth=1.3;for(const ev of window.usable){ctx.beginPath();ctx.moveTo(x(ev),0);ctx.lineTo(x(ev),h);ctx.stroke();}ctx.setLineDash([]);ctx.fillStyle='#ddd';ctx.font='bold 23px -apple-system, sans-serif';ctx.textBaseline='top';for(const [i,ev] of window.usable.entries()){const xx=Math.max(5,Math.min(w-88,x(ev)+(i===0?-84:7)));ctx.fillText(stops(ev),xx,5);}
  const percent=n=>(n/Math.max(1,total)*100).toFixed(1)+' %';root.querySelector('#latitudeLow').textContent=percent(below);root.querySelector('#latitudeHigh').textContent=percent(above);root.querySelector('#latitudeInside').textContent=percent(total-below-above);root.querySelector('#latitudeLimits').innerHTML=(window.usable[1]-window.usable[0]).toFixed(2)+' 档保留 · '+stops(window.usable[0])+' — '+stops(window.usable[1])+'<br><span>完整层次 '+stops(window.full[0])+' — '+stops(window.full[1])+' · 浏览器近似</span>';
 }};
}
