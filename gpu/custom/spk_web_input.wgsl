// SPDX-License-Identifier: GPL-3.0-or-later
// Port of native/bridge.cpp input decode/matrix/gain adapter. Photographic values unchanged.
@group(0) @binding(0) var<storage,read> src:array<f32>;
@group(0) @binding(1) var<storage,read> p:array<f32>;
@group(0) @binding(2) var<storage,read> info:array<u32>;
@group(0) @binding(3) var<storage,read_write> dst:array<f32>;
fn decode(v:f32,mode:u32)->f32{
 if(mode==1u){if(v<0.03125){return v/16.0;}return pow(v,1.8);}
 if(mode==2u){return pow(v,563.0/256.0);}
 if(mode==3u){let a=1.099;let b=0.018;if(v<a*pow(b,0.45)-(a-1.0)){return v/4.5;}return sign((v+(a-1.0))/a)*pow(abs((v+(a-1.0))/a),1.0/0.45);}
 if(mode==0u){if(v<=0.040449936){return v/12.92;}return sign((v+0.055)/1.055)*pow(abs((v+0.055)/1.055),2.4);}return v;
}
@compute @workgroup_size(256) fn main(@builtin(global_invocation_id) id:vec3<u32>,@builtin(num_workgroups) groups:vec3<u32>){let i=id.y*groups.x*256u+id.x;if(i>=info[0]){return;}var v=vec3<f32>(src[3u*i],src[3u*i+1u],src[3u*i+2u]);if(info[2]!=0u){v=vec3<f32>(decode(v.x,info[1]),decode(v.y,info[1]),decode(v.z,info[1]));}for(var c=0u;c<3u;c++){dst[3u*i+c]=(p[c*3u]*v.x+p[c*3u+1u]*v.y+p[c*3u+2u]*v.z)*p[9u+c];}}
