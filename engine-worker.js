/* SPDX-License-Identifier: GPL-3.0-or-later */
import {buildLUT} from './engine.js';
import {decodeTIFF} from './tiff-import.js';
import {neutralPrint} from './neutral-print.js';
import {cubeText} from './export-formats.js';
import {renderCPU} from './cpu-render.js';
const profiles=new Map(),luts=new Map();
async function profile(id,seen=new Set()){if(!/^[a-z0-9_]+$/.test(id))throw Error('无效材料配置');if(seen.has(id))throw Error('材料别名存在循环');if(!profiles.has(id)){const r=await fetch(new URL('./profiles/'+id+'.json',import.meta.url));if(!r.ok)throw Error('材料数据加载失败：'+id);const p=await r.json();if(p.derived_from){seen.add(id);const base=await profile(p.derived_from,seen);profiles.set(id,{...base,info:{...base.info,...p.info,stock:id},metadata:{base:base.metadata,alias:p.metadata},data:base.data});}else profiles.set(id,p);}return profiles.get(id);}
self.onmessage=async({data:m})=>{try{if(m.type==='lut'){const key=JSON.stringify([m.film,m.paper,m.options||{}]);if(!luts.has(key)){const [f,p]=await Promise.all([profile(m.film),['none','di'].includes(m.paper)?null:profile(m.paper)]);luts.set(key,buildLUT(f,p,33,m.options||{},true));if(luts.size>12)luts.delete(luts.keys().next().value);}const data=luts.get(key).slice();postMessage({id:m.id,type:'lut',data},[data.buffer]);}
  else if(m.type==='tiff'){const image=await decodeTIFF(m.file);postMessage({id:m.id,type:'tiff',...image},[image.rgb16.buffer,image.rgba.buffer]);}
  else if(m.type==='neutral'){const [film,paper]=await Promise.all([profile(m.film),['none','di'].includes(m.paper)?null:profile(m.paper)]);postMessage({id:m.id,type:'neutral',params:neutralPrint(film,paper,m.options,m.rgb)});}
  else if(m.type==='cube'){postMessage({id:m.id,type:'cube',text:cubeText(m.lut,m.params)});}
  else if(m.type==='cpu'){const out=renderCPU(m);postMessage({id:m.id,type:'cpu',pixels:out.buffer,width:m.width,height:m.height},[out.buffer]);}
}catch(e){postMessage({id:m.id,error:e.message||String(e)});}};
