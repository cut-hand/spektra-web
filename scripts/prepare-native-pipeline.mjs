/* SPDX-License-Identifier: GPL-3.0-or-later */
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
export function preparePipeline(){
 const base='vendor/spektralab/',out='test-output/native/generated';mkdirSync(out,{recursive:true});
 // Only platform glue changes. Original files are kept byte-for-byte and
 // checked by the build manifest; every scalar/vector formula is retained.
 let common=readFileSync(base+'shaders/spk_common.h','utf8').replace('#include <metal_stdlib>','#include "metal-compat.hpp"').replace('using namespace metal;','');
 const translate=s=>s.replace(/\bkernel void/g,'inline void').replace(/\b(device|thread|kernel)\s+/g,'').replace(/\bconstant\s+/g,'const ').replace(/\[\[.*?\]\]/g,'').replace(/\b(float2|float3|uint2|uint3|uint4)\(/g,'make_$1(');
 writeFileSync(out+'/spk_common.h',translate(common));
 const names=['nodes','blur','grain','gamut','util','scene_latitude','contrast_mask'];const calls=[];let source='';
 for(const name of names){let s=readFileSync(base+'shaders/'+name+'.metal','utf8');
  s=s.replace(/kernel void spk_reduce_max\([\s\S]*?\n\}/,''); // reduction is serial, mathematically identical max, below
  for(const m of s.matchAll(/kernel void (spk_\w+)\(([\s\S]*?)\)\s*\{/g)){
   const args=m[2].split(',').map(x=>x.trim()),invoke=[];
   for(const arg of args){const b=arg.match(/\[\[buffer\((\d+)\)\]\]/);if(b){const type=arg.replace(/\[\[.*?\]\]/g,'').replace(/\bdevice\s+/,'').replace(/\s+\w+\s*$/,'').trim();invoke.push(`reinterpret_cast<${type}>(ptr(args[${b[1]}]))`);}else if(arg.includes('thread_position_in_grid'))invoke.push('make_uint3(uint(i),0,0)');else throw Error('Unknown dispatch attribute: '+arg);}
   calls.push(`if(name=="${m[1]}"){if(args.size()!=${invoke.length-1}){error="Kernel argument count: "+name;return false;}for(size_t i=0;i<n;i++)${m[1]}(${invoke.join(',')});return true;}`);
  }
  source+='\n'+translate(s);
 }
 writeFileSync(out+'/kernels.inc',source);
 writeFileSync(out+'/dispatch.inc',calls.join('\n'));
 let pipeline=readFileSync(base+'pipeline/pipeline.cpp','utf8').replaceAll('#ifndef __APPLE__','#if !defined(__APPLE__) && !defined(SPK_WASM)');
 writeFileSync(out+'/pipeline.cpp',pipeline);
 let mask=readFileSync(base+'pipeline/contrast_mask.cpp','utf8').replace('#include <dispatch/dispatch.h>','').replace(/    struct Ctx \{ F\* fn; \} ctx\{&fn\};[\s\S]*?\n\}/,'    for(uint32_t line=0;line<lines;line++)fn(line);\n}');
 writeFileSync(out+'/contrast_mask.cpp',mask);
 return [out+'/pipeline.cpp',base+'pipeline/blur.cpp',base+'pipeline/scene_latitude.cpp',out+'/contrast_mask.cpp','native/cpu-backend.cpp','native/output-transform.cpp','native/overscan-boundary.cpp'];
}
