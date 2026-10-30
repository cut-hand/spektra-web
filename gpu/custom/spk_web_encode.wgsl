// SPDX-License-Identifier: GPL-3.0-or-later
@group(0) @binding(0) var<storage,read> src:array<f32>;
@group(0) @binding(1) var<storage,read> p:array<f32>;
@group(0) @binding(2) var<storage,read> info:array<u32>;
@group(0) @binding(3) var<storage,read_write> dst:array<f32>;
fn encode(v:f32,mode:u32)->f32{if(mode==1u){if(v<0.001953125){return v*16.0;}return pow(v,1.0/1.8);}if(mode==2u){return pow(v,256.0/563.0);}if(mode==3u){let a=1.099;let b=0.018;if(v<b){return v*4.5;}return a*sign(v)*pow(abs(v),0.45)-(a-1.0);}if(mode==0u){if(v<=0.0031308){return 12.92*v;}return 1.055*sign(v)*pow(abs(v),1.0/2.4)-0.055;}return v;}
@compute @workgroup_size(256) fn main(@builtin(global_invocation_id) id:vec3<u32>,@builtin(num_workgroups) groups:vec3<u32>){let i=id.y*groups.x*256u+id.x;if(i>=info[0]){return;}let x=(f32(i%info[1])+0.5)/f32(info[1])-0.5;let y=(f32(i/info[1])+0.5)/f32(info[2])-0.5;let vig=1.0-p[0]*clamp((x*x+y*y)*1.5,0.0,1.0);for(var c=0u;c<3u;c++){let v=src[3u*i+c];if(info[4]!=0u){dst[3u*i+c]=v;}else{dst[3u*i+c]=encode(v*vig,info[3]);}}}
