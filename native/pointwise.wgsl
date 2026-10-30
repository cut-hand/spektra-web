// SPDX-License-Identifier: GPL-3.0-or-later
// WGSL transfer of SpektraLab 1.3.4 pointwise kernels; layout from bridge.cpp.
// Spatial/stochastic stages are deliberately outside this kernel.
@group(0) @binding(0) var<storage,read> d:array<f32>;
@group(0) @binding(1) var<storage,read> inputs:array<vec4<f32>>;
@group(0) @binding(2) var<storage,read_write> outputs:array<vec4<f32>>;
struct Dispatch { count:u32, size:u32, pad0:u32, pad1:u32 }
@group(0) @binding(3) var<uniform> job:Dispatch;
fn off(slot:u32)->u32{return u32(d[slot]);}
fn v3(at:u32)->vec3<f32>{return vec3(d[at],d[at+1u],d[at+2u]);}
fn matrix(slot:u32,v:vec3<f32>)->vec3<f32>{let o=off(slot);return vec3(dot(v3(o),v),dot(v3(o+3u),v),dot(v3(o+6u),v));}
fn logten(v:vec3<f32>)->vec3<f32>{return log(max(v,vec3(0.0))+vec3(1e-10))*.4342944819032518;}
fn ten(v:vec3<f32>)->vec3<f32>{return exp2(v*3.321928094887362);}
fn interp(slot:u32,count:u32,v:vec3<f32>)->vec3<f32>{
 let x=off(slot);let inv=off(slot+1u);let y=off(slot+2u);var out:vec3<f32>;
 for(var c=0u;c<3u;c++){
  if(v[c]<=d[x+c]){out[c]=d[y+c];continue;}
  if(v[c]>=d[x+(count-1u)*3u+c]){out[c]=d[y+(count-1u)*3u+c];continue;}
  var lo=0u;var hi=count;while(lo<hi){let mid=lo+((hi-lo)>>1u);if(d[x+mid*3u+c]<=v[c]){lo=mid+1u;}else{hi=mid;}}
  let at=(lo-1u)*3u+c;let t=(v[c]-d[x+at])*d[inv+at];out[c]=mix(d[y+at],d[y+at+3u],t);
 }return out;
}
fn spectral(slot:u32,v:vec3<f32>)->vec3<f32>{let o=off(slot);var sum=vec3(0.0);for(var l=0u;l<81u;l++){let density=dot(v,v3(o+l*3u))+d[o+243u+l];sum+=exp2(-density*3.321928094887362)*v3(o+324u+l*3u);}return sum;}
fn mitchell(t:f32)->f32{let x=abs(t);if(x<1.){return ((7.*x-12.)*x*x+5.333333333333333)/6.;}if(x<2.){return (((-2.333333333333333*x+12.)*x-20.)*x+10.666666666666667)/6.;}return 0.;}
fn mirror(index:i32,n:i32)->u32{if(index<0){return u32(-index);}if(index>=n){return u32(2*(n-1)-index);}return u32(index);}
fn upsample(rgb:vec3<f32>)->vec3<f32>{
 let xyz=matrix(17u,rgb);let b=xyz.x+xyz.y+xyz.z;let xy=xyz.xy/max(b,1e-10);let one=1.-xy.x;
 let tc=clamp(vec2(one*one,xy.y/max(one,1e-10)),vec2(0.),vec2(1.));let n=u32(d[0]);let pos=tc*f32(n-1u);
 let base=min(vec2<i32>(floor(pos)),vec2(i32(n)-2));let f=pos-vec2<f32>(base);
 var sum=vec3(0.);var weights=0.;let o=off(16u);
 for(var a=0;a<4;a++){for(var k=0;k<4;k++){let w=mitchell(f.x+1.-f32(a))*mitchell(f.y+1.-f32(k));let at=(mirror(base.x-1+a,i32(n))*n+mirror(base.y-1+k,i32(n)))*3u;sum+=w*v3(o+at);weights+=w;}}
 return sum/weights*b;
}
fn knee(v:f32,th:f32,lim:f32,p:f32)->f32{if(v<=th){return v;}let sc=lim-th;let x=(v-th)/sc;return th+sc*x/pow(1.+pow(x,p),1./p);}
fn cam16(rgb:vec3<f32>)->vec3<f32>{
 let o=off(35u);let FL=d[o];let Nbb=d[o+1u];let Ncb=d[o+2u];let n=d[o+3u];let z=d[o+4u];let Aw=d[o+5u];let c=d[o+6u];let Nc=d[o+7u];let D=v3(o+19u);
 let xyz=matrix(37u,rgb)*100.;let cones=vec3(dot(vec3(.401288,.650173,-.051461),xyz),dot(vec3(-.250268,1.204414,.045854),xyz),dot(vec3(-.002079,.048952,.953127),xyz))*D;
 let f=pow(vec3(FL)*abs(cones)/100.,vec3(.42));let ra=400.*sign(cones)*f/(vec3(27.13)+f)+vec3(.1);
 let a=ra.x-12.*ra.y/11.+ra.z/11.;let bb=(ra.x+ra.y-2.*ra.z)/9.;let h=atan2(bb,a);let et=.25*(cos(h+2.)+3.8);
 let ar=(2.*ra.x+ra.y+ra.z/20.-.305)*Nbb/Aw;let J=100.*sign(ar)*pow(abs(ar),c*z);
 let den=ra.x+ra.y+21.*ra.z/20.;var t=0.;if(den!=0.){t=(50000./13.*Nc*Ncb*et*length(vec2(a,bb)))/den;}
 let ec=pow(1.64-pow(.29,n),.73);let FL4=pow(FL,.25);var C=0.;if(t>0.){C=pow(t,.9)*sqrt(abs(J)/100.)*ec;}
 let Mp=log(1.+.0228*C*FL4)/.0228;var Jp=1.7*J/(1.+.007*J);
 Jp=knee(Jp/d[o+18u],d[o+15u],d[o+16u],d[o+17u])*d[o+18u];
 let Li=(clamp(Jp,d[o+8u],d[o+9u])-d[o+8u])/(d[o+9u]-d[o+8u])*63.;let l0=min(u32(floor(Li)),62u);let lf=Li-f32(l0);
 let hh=(h-d[o+10u])/d[o+11u];let hi=i32(floor(hh));let h0=u32(((hi%720)+720)%720);let h1=(h0+1u)%720u;let hf=hh-floor(hh);let cm=off(36u);
 let Cmax=max(mix(mix(d[cm+l0*720u+h0],d[cm+l0*720u+h1],hf),mix(d[cm+(l0+1u)*720u+h0],d[cm+(l0+1u)*720u+h1],hf),lf),1e-9);
 let newMp=knee(Mp/Cmax,d[o+12u],d[o+13u],d[o+14u])*Cmax;let newM=(exp(newMp*.0228)-1.)/.0228;let newJ=Jp/(1.7-.007*Jp);let newC=newM/FL4;
 let A=Aw*sign(newJ)*pow(abs(newJ)/100.,1./(c*z));let sq=sqrt(abs(newJ)/100.);var t2=0.;if(sq>0.&&newC>0.){t2=pow(newC/(sq*ec),1./.9);}
 let ca=cos(h);let sa=sin(h);let p2=A/Nbb+.305;let p3=21./20.;var a2=0.;var b2=0.;
 if(t2!=0.){let p1=(50000./13.*Nc*Ncb*et)/t2;if(abs(sa)>=abs(ca)){let p4=p1/sa;b2=(p2*(2.+p3)*(460./1403.))/(p4+(2.+p3)*(220./1403.)*(ca/sa)-(27./1403.)+p3*(6300./1403.));a2=b2*(ca/sa);}else{let p5=p1/ca;a2=(p2*(2.+p3)*(460./1403.))/(p5+(2.+p3)*(220./1403.)-((27./1403.)-p3*(6300./1403.))*(sa/ca));b2=a2*(sa/ca);}}
 let ra2=vec3(460.*p2+451.*a2+288.*b2,460.*p2-891.*a2-261.*b2,460.*p2-220.*a2-6300.*b2)/1403.;let vm=ra2-vec3(.1);let response=(100./FL)*sign(vm)*pow(27.13*abs(vm)/(vec3(400.)-abs(vm)),vec3(1./.42))/D;
 let outxyz=vec3(dot(vec3(1.86206786,-1.01125463,.14918677),response),dot(vec3(.38752654,.62144744,-.00897398),response),dot(vec3(-.01584150,-.03412294,1.04996444),response))/100.;return matrix(38u,outxyz);
}
fn pixel(rgb:vec3<f32>)->vec3<f32>{
 let rawlog=logten(upsample(rgb)*d[7]);var density=interp(18u,u32(d[1]),rawlog);
 if(d[6]!=0.){var corrected=density;if(d[3]!=0.){corrected=v3(off(25u))-density;}let mat=off(24u);let corr=vec3(corrected.x*d[mat]+corrected.y*d[mat+3u]+corrected.z*d[mat+6u],corrected.x*d[mat+1u]+corrected.y*d[mat+4u]+corrected.z*d[mat+7u],corrected.x*d[mat+2u]+corrected.y*d[mat+5u]+corrected.z*d[mat+8u]);density=interp(21u,u32(d[1]),rawlog-corr);}
 if(d[5]!=0.){let trans=logten(spectral(39u,density));let pos=(ten(interp(40u,u32(d[43]),trans))-vec3(d[46]))*ten(v3(off(45u)));let mat=off(44u);let lin=vec3(pos.x*d[mat]+pos.y*d[mat+3u]+pos.z*d[mat+6u],pos.x*d[mat+1u]+pos.y*d[mat+4u]+pos.z*d[mat+7u],pos.x*d[mat+2u]+pos.y*d[mat+5u]+pos.z*d[mat+8u]);let b=exp2(((95.-685.)/300.)*3.321928094887362);return clamp((vec3(685.)+300.*log(max(lin,vec3(0.))*(1.-b)+vec3(b))*.4342944819032518)/1023.,vec3(0.),vec3(1.));}
 if(d[4]==0.){var exposed=max(spectral(29u,density)*v3(off(30u))+v3(off(31u)),vec3(0.))+vec3(1e-10);exposed=exposed*d[8]*d[9];density=interp(26u,u32(d[2]),logten(exposed));}
 var xyz=max(spectral(32u,density),vec3(0.))+vec3(1e-10);if(d[10]!=0.){xyz*=clamp(d[11]*xyz.y+d[12],0.,1.)/(xyz.y+1e-10);}
 var lin=cam16(matrix(33u,xyz));
 if(d[13]!=0.){let y=max(dot(lin,v3(off(53u))),0.);var mapped=y;if(y>0.&&(y<d[51]||y>d[52])){let n=u32(d[48]);let u=clamp((log2(y)-d[49])/(d[50]-d[49]),0.,1.)*f32(n-1u);let i=min(u32(floor(u)),n-2u);let o=off(47u);mapped=exp2(mix(d[o+i],d[o+i+1u],u-f32(i)));}lin*=mapped/(y+1e-10);}
 lin=matrix(34u,lin);return select(1.055*pow(max(lin,vec3(0.)),vec3(1./2.4))-vec3(.055),lin*12.92,lin<=vec3(.0031308));
}
@compute @workgroup_size(64) fn main(@builtin(global_invocation_id) id:vec3<u32>){
 let i=id.x;if(i>=job.count){return;}var rgb:vec3<f32>;
 if(job.size==0u){rgb=inputs[i].rgb;}else{let s=job.size;rgb=vec3<f32>(f32(i%s),f32((i/s)%s),f32(i/(s*s)));rgb=(exp2(rgb/f32(s-1u)*log2(257.))-vec3(1.))/16.;}
 outputs[i]=vec4(pixel(rgb),1.);
}
