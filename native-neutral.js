/* SPDX-License-Identifier: GPL-3.0-or-later */
import {loadNativeCore} from './native-core.js';
import {clamp,encode} from './engine.js';
function solve(a,b){const m=a.map((r,i)=>[...r,b[i]]);for(let i=0;i<3;i++){let k=i;for(let j=i+1;j<3;j++)if(Math.abs(m[j][i])>Math.abs(m[k][i]))k=j;[m[k],m[i]]=[m[i],m[k]];if(Math.abs(m[i][i])<1e-10)return null;const d=m[i][i];m[i]=m[i].map(v=>v/d);for(let j=0;j<3;j++)if(j!==i){const q=m[j][i];m[j]=m[j].map((v,k)=>v-q*m[i][k]);}}return m.map(r=>r[3]);}
export async function nativeNeutral(film,paper,options,rgb){
 if(['none','di'].includes(paper))throw Error('直接扫描与数字中间片不使用放大机配光');
 const core=await loadNativeCore(),o={...options},target=encode(.184),keys=['printExposure','yFilter','mFilter'],steps=[.02,.2,.2];
 const pixel=async opts=>{await core.prepare(film,paper,opts);return core.pixels(rgb);};
 if((await core.readProfile(film)).info?.channel_model==='bw'){let lo=-3,hi=3;for(let i=0;i<20;i++){const mid=(lo+hi)/2,v=(await pixel({...o,printExposure:mid}))[1];if(v>target)lo=mid;else hi=mid;}return{printExposure:Math.round((lo+hi)/2*10)/10};}
 for(let i=0;i<12;i++){const current=await pixel(o),err=Array.from(current,v=>target-v);if(Math.max(...err.map(Math.abs))<.001)break;const columns=[];for(let k=0;k<3;k++){const v=await pixel({...o,[keys[k]]:o[keys[k]]+steps[k]});columns.push(Array.from(v,(c,j)=>(c-current[j])/steps[k]));}const delta=solve(columns[0].map((_,r)=>columns.map(c=>c[r])),err);if(!delta)break;for(let k=0;k<3;k++){const limit=k?40:3;o[keys[k]]=clamp(o[keys[k]]+clamp(delta[k],k?-8:-.5,k?8:.5),-limit,limit);}}
 return {printExposure:Math.round(o.printExposure*10)/10,yFilter:Math.round(o.yFilter),mFilter:Math.round(o.mFilter)};
}
