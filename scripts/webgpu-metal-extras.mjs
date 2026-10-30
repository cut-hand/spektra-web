/* SPDX-License-Identifier: GPL-3.0-or-later */
import {readFileSync} from 'node:fs';
function block(s,start){let i=s.indexOf('{',start),depth=1,j=i+1;for(;depth;j++){if(s[j]==='{')depth++;if(s[j]==='}')depth--;}return s.slice(i+1,j-1);}
function ccasts(s){const re=/\((float|uint|int)\)\s*/;for(let m;(m=re.exec(s));){let a=m.index+m[0].length,b=a;if(s[a]==='('){let d=1;b++;while(d){if(s[b]==='(')d++;if(s[b]===')')d--;b++;}}else{while(/[\w.]/.test(s[b]||'')&&b<s.length)b++;if(s[b]==='('){let d=1;b++;while(d){if(s[b]==='(')d++;if(s[b]===')')d--;b++;}}}s=s.slice(0,m.index)+m[1]+'('+s.slice(a,b)+')'+s.slice(b);}return s;}
export function metalExtras(){const files={nodes:readFileSync('vendor/spektralab/shaders/nodes.metal','utf8'),scene_latitude:readFileSync('vendor/spektralab/shaders/scene_latitude.metal','utf8'),contrast_mask:readFileSync('vendor/spektralab/shaders/contrast_mask.metal','utf8')},result={};
 for(const [name,file] of [['spk_di_encode','nodes'],['spk_highlight_headroom','nodes'],['spk_scene_latitude','scene_latitude'],['spk_mask_reduce','contrast_mask'],['spk_mask_epilogue','contrast_mask']]){
 const src=files[file],match=new RegExp('kernel void '+name+'\\(([\\s\\S]*?)\\)\\s*\\{').exec(src),args=[...match[1].matchAll(/device\s+(const\s+)?(float|uint)\*\s*(\w+)\s*\[\[buffer\((\d+)\)\]\]/g)];let text='#version 450\nlayout(local_size_x=256) in;\n';
 for(const [,ro,type,v,b] of args)text+=`layout(set=0,binding=${b},std430) ${ro?'readonly ':''}buffer B${b}{${type} ${v}[];};\n`;
 let helpers='';
 if(file==='nodes'&&name==='spk_highlight_headroom')helpers='float spk_smoothstep01(float t){'+block(src,src.indexOf('static inline float spk_smoothstep01'))+'}\n';
 if(file==='scene_latitude')helpers='float slm_departure(float D,float H,float m){'+block(src,src.indexOf('inline float slm_departure'))+'}\n';
 if(file==='contrast_mask'){
 helpers='const float kMaskLog2Floor=-20.0;\nvec3 mask_image_exposure(uint i,uint nl){'+block(src,src.indexOf('inline float3 mask_image_exposure'))+'}\nfloat mask_x(vec3 a){'+block(src,src.indexOf('inline float mask_x'))+'}\nfloat mask_g(float d,float h){'+block(src,src.indexOf('inline float mask_g'))+'}\nfloat mask_delta(float b){'+block(src,src.indexOf('inline float mask_delta'))+'}\n';
 }
 text+=helpers+'\nvoid main(){'+block(src,match.index)+'}\n';
 text=text.replace(/thread_position_in_grid.x/g,'(gl_GlobalInvocationID.y*(gl_NumWorkGroups.x*256u)+gl_GlobalInvocationID.x)').replace(/mask_image_exposure\(cmy,\s*([^,]+),\s*chd,\s*base,\s*ixs,\s*nl,\s*p\)/g,'mask_image_exposure($1,nl)').replace(/mask_x\(a, p\)/g,'mask_x(a)').replace('mask_x(mask_image_exposure(y * W + x,nl), p)','mask_x(mask_image_exposure(y * W + x,nl))').replace(/mask_delta\(b, p\)/g,'mask_delta(b)');
 text=ccasts(text).replace(/\bfloat3\b/g,'vec3').replace(/\bfloat2\b/g,'vec2').replace(/\bout\b/g,'dst').replace(/\batan2\(/g,'atan(').replace(/\blog10\(/g,'spk_log10(').replace(/\bfmod\(/g,'spk_fmod(').replace(/\bisfinite\(/g,'spk_isfinite(').replace(/\bpow\(/g,'spk_pow(').replace(/\brsqrt\(/g,'inversesqrt(').replace(/(\d(?:[.eE+-]\d+)?|\.)f\b/g,'$1');
 const compat='float spk_pow(float x,float y){return pow(x,y);}\nvec3 spk_pow(vec3 x,float y){return pow(x,vec3(y));}\nfloat spk_log10(float x){return log(x)*0.4342944819032518;}\nvec3 spk_log10(vec3 x){return log(x)*0.4342944819032518;}\nfloat spk_fmod(float x,float y){return x-y*trunc(x/y);}\nbool spk_isfinite(float x){return (floatBitsToUint(x)&0x7fffffffu)<0x7f800000u;}\n';
 text=text.replace('#version 450','#version 450\n'+compat);result[name+'.comp']=text;
 }
 return result;
}
