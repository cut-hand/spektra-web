// SPDX-License-Identifier: GPL-3.0-or-later
// Same post-development grading order as the C++ WASM reference.
@group(0) @binding(0) var<storage,read> src:array<f32>;
@group(0) @binding(1) var<storage,read> p:array<f32>;
@group(0) @binding(2) var<storage,read> info:array<u32>;
@group(0) @binding(3) var<storage,read_write> dst:array<f32>;
fn dec(v:f32)->f32{if(v<0.03125){return v/16.0;}return pow(v,1.8);}
fn enc(v:f32)->f32{if(v<0.001953125){return v*16.0;}return pow(v,1.0/1.8);}
@compute @workgroup_size(256) fn main(@builtin(global_invocation_id) id:vec3<u32>,@builtin(num_workgroups) groups:vec3<u32>){let i=id.y*groups.x*256u+id.x;if(i>=info[0]){return;}if(info[3]!=0u){for(var c=0u;c<3u;c++){dst[3u*i+c]=src[3u*i+c];}return;}
 var lin=vec3<f32>(dec(src[3u*i]),dec(src[3u*i+1u]),dec(src[3u*i+2u]))*vec3<f32>(p[0],p[1],p[2]);
 if(p[6]!=0.0){let e=vec3<f32>(enc(lin.x),enc(lin.y),enc(lin.z));let y=e.x*0.28804+e.y*0.71187+e.z*0.00009;let cy=clamp(y,0.0,1.0);let low=(1.0-cy)*(1.0-cy);let high=cy*cy;
 for(var c=0u;c<3u;c++){var v=(e[c]-0.5)*p[3]+0.5;v=y+(v-y)*p[4];if(p[5]!=0.0){let t=v;let d0=(t-0.2)/0.18;let d1=(t-0.5)/0.2;let d2=(t-0.8)/0.18;v+=4.0*t*(1.0-t)*(p[7]*exp(-d0*d0)+p[8]*exp(-d1*d1)+p[9]*exp(-d2*d2))*0.004;}v+=(p[10u+c]+p[13u+c]*low+p[16u+c]*high)*0.003;lin[c]=dec(v);}}
 for(var c=0u;c<3u;c++){dst[3u*i+c]=p[19u+c*3u]*lin.x+p[20u+c*3u]*lin.y+p[21u+c*3u]*lin.z;}}
