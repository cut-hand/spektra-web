/* SPDX-License-Identifier: GPL-3.0-or-later
 * Browser experimental implementation inspired by SpektraLab/spektrafilm.
 * 28 upstream profiles: unmodified CC BY-SA 4.0 by Andrea Volpato;
 * product additions: see licenses/PRODUCT-PROFILES-NOTICE.md.
 * This is NOT the native engine: RGB reconstruction uses three smooth bases,
 * scanner CMFs use analytic fits; no Hanatos, DIR, CAM16 or native parity claim.
 */
export const LUT_SIZE = 33;
export const SHAPER = Math.log2(257);
export const clamp = (x, a=0, b=1) => Math.min(b,Math.max(a,x));
export const decode = x => x<=0.04045 ? x/12.92 : ((x+0.055)/1.055)**2.4;
export const encode = x => x<=0.0031308 ? 12.92*x : 1.055*Math.max(0,x)**(1/2.4)-0.055;
const dot=(a,b)=>a.reduce((s,v,i)=>s+v*b[i],0);
const mv=(a,v)=>a.map(row=>dot(row,v));
const mm=(a,b)=>a.map(row=>b[0].map((_,c)=>row.reduce((s,v,i)=>s+v*b[i][c],0)));
function inverse(a) {
  const m=a.map((r,i)=>[...r,...[0,1,2].map(j=>i===j?1:0)]);
  for(let i=0;i<3;i++) { let p=i;for(let j=i+1;j<3;j++)if(Math.abs(m[j][i])>Math.abs(m[p][i]))p=j;
    [m[i],m[p]]=[m[p],m[i]];const d=m[i][i];if(Math.abs(d)<1e-12)throw Error('颜色矩阵不可逆');
    m[i]=m[i].map(v=>v/d);for(let j=0;j<3;j++)if(i!==j){const k=m[j][i];m[j]=m[j].map((v,c)=>v-k*m[i][c]);}
  }return m.map(r=>r.slice(3));
}
const RGB_XYZ=[[.4124564,.3575761,.1804375],[.2126729,.7151522,.0721750],[.0193339,.1191920,.9503041]];
const XYZ_RGB=inverse(RGB_XYZ);
const B=[[.8951,.2664,-.1614],[-.7502,1.7135,.0367],[.0389,-.0685,1.0296]];
function adaptation(from,to) {const s=mv(B,from),t=mv(B,to);return mm(inverse(B),B.map((row,i)=>row.map(v=>v*t[i]/s[i])));}
const gaussian=(x,mu,sigma)=>Math.exp(-.5*((x-mu)/sigma)**2);
// Wyman et al. analytic approximation to CIE 1931 2° matching functions.
function cmf(w){const g=(mu,l,r)=>Math.exp(-.5*((w-mu)*(w<mu?l:r))**2);return [1.056*g(599.8,.0264,.0323)+.362*g(442,.0624,.0374)-.065*g(501.1,.049,.0382),.821*g(568.8,.0213,.0247)+.286*g(530.9,.0613,.0322),1.217*g(437,.0845,.0278)+.681*g(459,.0385,.0725)];}
function illuminant(w,t){const m=w*1e-9;return 1/(m**5*Math.expm1(.01438776877/(m*t)));}
function finite(v){return typeof v==='number'&&Number.isFinite(v)?v:0;}
export function curve(profile,x,c){const d=profile.data,axis=d.log_exposure,n=axis.length;const f=clamp((x-axis[0])/(axis[n-1]-axis[0]),0,1)*(n-1),i=Math.min(n-2,Math.floor(f));return Math.max(0,finite(d.density_curves[i][c])*(1-(f-i))+finite(d.density_curves[i+1][c])*(f-i));}
function spectralData(profile){const d=profile.data;return d.wavelengths.map((w,i)=>({w,valid:d.channel_density[i].every(Number.isFinite)&&Number.isFinite(d.base_density[i]),d:d.channel_density[i].map(finite),base:finite(d.base_density[i]),s:d.log_sensitivity[i].map(x=>Number.isFinite(x)?10**x:0)}));}

export function createModel(film,paper,options={}){
  const o={filmExposure:0,filmGamma:1,paperGamma:1,printExposure:0,yFilter:0,mFilter:0,preflash:0,paperGrade:'2',illuminant:'3200',cameraFilter:'none',couplers:0,printEffects:true,edr:false,...options};
  const positive=film.info.type==='positive',mono=film.info.channel_model==='bw';
  if(!positive&&paper&&mono!==(paper.info.channel_model==='bw'))throw Error('黑白胶片须使用黑白相纸，彩色胶片须使用彩色印相材料');
  const f=spectralData(film),p=paper?spectralData(paper):f,n=f.length;if(n!==81||p.length!==81)throw Error('材料必须包含 81 个波段');
  const c=f.map(v=>cmf(v.w)),light=f.map(v=>illuminant(v.w,5000));const norm=dot(light,c.map(v=>v[1]));for(let i=0;i<n;i++)light[i]/=norm;
  const white=[0,1,2].map(k=>light.reduce((sum,v,i)=>sum+v*c[i][k],0)),scanM=mm(XYZ_RGB,adaptation(white,[.95047,1,1.08883])),scanWeights=c.map((v,i)=>mv(scanM,v.map(x=>x*light[i])));
  const bases=f.map(v=>[gaussian(v.w,610,40),gaussian(v.w,545,33),gaussian(v.w,450,26)]),basisXYZ=[0,1,2].map(k=>[0,1,2].map(j=>bases.reduce((sum,v,i)=>sum+v[j]*light[i]*c[i][k],0))),reconstruct=mm(inverse(basisXYZ),mm(adaptation([.95047,1,1.08883],white),RGB_XYZ));
  const filter=w=>o.cameraFilter==='yellow'?(.02+.98/(1+Math.exp(-(w-490)/15))):o.cameraFilter==='orange'?(.02+.98/(1+Math.exp(-(w-545)/18))):o.cameraFilter==='red'?(.01+.99/(1+Math.exp(-(w-590)/15))):o.cameraFilter==='green'?(.02+.98*gaussian(w,540,40)):o.cameraFilter==='blue'?(.02+.98*gaussian(w,450,35)):1;
  const sensitivity=[0,1,2].map(k=>[0,1,2].map(j=>f.reduce((sum,v,i)=>sum+v.s[k]*bases[i][j]*light[i],0))),filtered=[0,1,2].map(k=>[0,1,2].map(j=>f.reduce((sum,v,i)=>sum+v.s[k]*filter(v.w)*bases[i][j]*light[i],0))),baseMatrix=mm(sensitivity,reconstruct),filteredMatrix=mm(filtered,reconstruct),factor=filteredMatrix[1].reduce((a,b)=>a+b,0)/baseMatrix[1].reduce((a,b)=>a+b,0),fm=filteredMatrix.map((row,i)=>{const sum=baseMatrix[i].reduce((a,b)=>a+b,0)*factor;return row.map(v=>v/sum);});
  function filmDensity(rgb,exp=o.filmExposure){const raw=mv(fm,rgb);let d=raw.map((v,k)=>curve(film,Math.log10(Math.max(1e-10,v*2**exp)/.184)*o.filmGamma,k));if(!mono&&o.couplers>0){const mean=(d[0]+d[1]+d[2])/3;d=d.map(v=>Math.max(0,v+(v-mean)*o.couplers*.22));}return d;}
  function scanDensity(material,channels){const data=material===film?f:p,acc=[0,0,0];for(let i=0;i<n;i++){if(!data[i].valid)continue;const t=10**(-dot(channels,data[i].d)-data[i].base);for(let k=0;k<3;k++)acc[k]+=t*scanWeights[i][k];}if(mono){const y=dot(acc,[.2126,.7152,.0722]);return [y,y,y];}return acc;}
  function gamut(lin){const y=clamp(dot(lin,[.2126,.7152,.0722]));let t=1;for(let k=0;k<3;k++){const d=lin[k]-y;if(d>0)t=Math.min(t,(1-y)/d);if(d<0)t=Math.min(t,-y/d);}return lin.map(v=>clamp(encode(y+(v-y)*clamp(t))));}
  if(positive){const gray=scanDensity(film,filmDensity([.184,.184,.184],0)),gain=gray.map(v=>.184/Math.max(v,1e-8));return {pixel:rgb=>gamut(scanDensity(film,filmDensity(rgb)).map((v,k)=>v*gain[k])),filmDensity,filmMatrix:fm,mode:'positive'};}
  if(!paper){return {pixel:rgb=>{const d=filmDensity(rgb);return d.map((v,k)=>{const axis=film.data.log_exposure;let lo=axis[0],hi=axis[axis.length-1];for(let it=0;it<15;it++){const mid=(lo+hi)/2;if(curve(film,mid,k)<v)lo=mid;else hi=mid;}return clamp(.410+(lo+hi)/2*Math.LOG2E*Math.LN10*.073);});},filmDensity,filmMatrix:fm,mode:'di'};}
  const temp=Number(o.illuminant)||3200,baseLamp=f.map(v=>illuminant(v.w,temp)),lm=Math.max(...baseLamp);for(let i=0;i<n;i++)baseLamp[i]/=lm;
  const gradeTable={'00':[0,199],'0':[0,137.9],'1':[0,99.8],'2':[0,68],'3':[0,34.1],'4':[39.1,0],'5':[151.7,0]},grade=gradeTable[o.paperGrade]||gradeTable['2'];
  function lampFor(y,m){return baseLamp.map((v,i)=>v*10**(-.01*y/(1+Math.exp((f[i].w-490)/16))-.01*m*gaussian(f[i].w,545,43)));}
  const neutralLamp=mono?lampFor(68,0):baseLamp,lamp=mono?lampFor(grade[1]+o.yFilter,grade[0]+o.mFilter):lampFor(o.yFilter,o.mFilter);
  function throughFilm(d,illum=lamp){const acc=[0,0,0];for(let i=0;i<n;i++){if(!f[i].valid)continue;const t=10**(-dot(d,f[i].d)-f[i].base)*illum[i];for(let k=0;k<3;k++)acc[k]+=t*p[i].s[k];}return acc;}
  function scan(log){const d=log.map((v,k)=>curve(paper,v*o.paperGamma,k));return scanDensity(paper,d);}
  const referenceDensity=filmDensity([.184,.184,.184]),anchor=throughFilm(referenceDensity,neutralLamp).map(v=>Math.log10(Math.max(v,1e-12)));
  let mid=[.1,.1,.1],monoMean=anchor.reduce((a,b)=>a+b)/3;
  if(mono){const reference=throughFilm(referenceDensity).map(v=>Math.log10(Math.max(v,1e-12))-monoMean);let lo=-4,hi=4;for(let it=0;it<50;it++){const t=(lo+hi)/2,y=scan(reference.map(v=>v+t))[1];if(y>.184)lo=t;else hi=t;}mid=[(lo+hi)/2,(lo+hi)/2,(lo+hi)/2];}
  else{for(let it=0;it<18;it++){const out=scan(mid),err=out.map(v=>.184-v);if(Math.max(...err.map(Math.abs))<1e-7)break;const jac=[0,1,2].map(k=>{const a=[...mid];a[k]+=.001;return scan(a).map((v,j)=>(v-out[j])/.001);});const step=mv(inverse(jac[0].map((_,i)=>jac.map(r=>r[i]))),err);mid=mid.map((v,i)=>clamp(v+clamp(step[i],-.3,.3),-.8,1.5));}}
  function pixel(rgb){const raw=throughFilm(filmDensity(rgb)),log=raw.map((v,k)=>{const a=Math.log10(Math.max(v,1e-12))-(mono?monoMean:anchor[k])+mid[k]+o.printExposure*Math.LOG10E*Math.LN2;return Math.log10(10**a+(o.printEffects?o.preflash:0)+1e-12);});let lin=scan(log);if(o.edr&&o.printEffects){const y=dot(lin,[.2126,.7152,.0722]);const mapped=y<.7?y:.7+.3*(1-Math.exp(-(y-.7)/.3));if(y>1e-8)lin=lin.map(v=>v*mapped/y);}return gamut(lin);}
  return {pixel,scan,mid,filmDensity,filmMatrix:fm,mode:mono?'bw':'print'};
}
export function buildLUT(film,paper,size=LUT_SIZE,options={},floating=false){const model=createModel(film,paper,options),out=floating?new Float32Array(size**3*4):new Uint8Array(size**3*4);let offset=0;const values=Array.from({length:size},(_,i)=>(2**(i/(size-1)*SHAPER)-1)/16),scale=floating?1:255;for(let b=0;b<size;b++)for(let g=0;g<size;g++)for(let r=0;r<size;r++){const rgb=model.pixel([values[r],values[g],values[b]]);for(let k=0;k<3;k++)out[offset++]=floating?rgb[k]:Math.round(rgb[k]*scale);out[offset++]=scale;}return out;}
export function sampleLUT(lut,rgb,size=LUT_SIZE){const q=rgb.map(v=>clamp(Math.log2(1+Math.max(0,v)*16)/SHAPER)*(size-1)),lo=q.map(v=>Math.min(size-2,Math.floor(v))),f=q.map((v,i)=>v-lo[i]),out=[0,0,0],scale=lut instanceof Float32Array?1:255;for(let z=0;z<2;z++)for(let y=0;y<2;y++)for(let x=0;x<2;x++){const w=(x?f[0]:1-f[0])*(y?f[1]:1-f[1])*(z?f[2]:1-f[2]),idx=(((lo[2]+z)*size+lo[1]+y)*size+lo[0]+x)*4;for(let k=0;k<3;k++)out[k]+=lut[idx+k]/scale*w;}return out;}
