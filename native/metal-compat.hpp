/* SPDX-License-Identifier: GPL-3.0-or-later
 * Host/WASM vocabulary for the pinned Metal kernel bodies. No GPU API.
 * Clang vectors retain Metal's component arithmetic and swizzles. */
#pragma once
#include <algorithm>
#include <cmath>
#include <cstdint>
using uint=uint32_t;
using ushort=uint16_t;
using float2=float __attribute__((ext_vector_type(2)));
using float3=float __attribute__((ext_vector_type(3)));
using uint2=uint __attribute__((ext_vector_type(2)));
using uint3=uint __attribute__((ext_vector_type(3)));
using uint4=uint __attribute__((ext_vector_type(4)));
inline float2 make_float2(float a,float b){return {a,b};}
inline float3 make_float3(float a){return {a,a,a};}
inline float3 make_float3(float a,float b,float c){return {a,b,c};}
inline uint2 make_uint2(uint a,uint b){return {a,b};}
inline uint3 make_uint3(uint a,uint b,uint c){return {a,b,c};}
inline uint4 make_uint4(uint a,uint b,uint c,uint d){return {a,b,c,d};}
using std::min;using std::max;using std::clamp;
inline float3 max(float3 a,float b){return {max(a.x,b),max(a.y,b),max(a.z,b)};}
inline float3 log10(float3 a){return {std::log10(a.x),std::log10(a.y),std::log10(a.z)};}
inline float3 pow(float3 a,float b){return {std::pow(a.x,b),std::pow(a.y,b),std::pow(a.z,b)};}
inline float3 clamp(float3 a,float lo,float hi){return {std::clamp(a.x,lo,hi),std::clamp(a.y,lo,hi),std::clamp(a.z,lo,hi)};}
template<class T> inline T mix(T a,T b,float t){return a+(b-a)*t;}
inline float rsqrt(float a){return 1.0f/std::sqrt(a);}
inline uint mulhi(uint a,uint b){return uint((uint64_t(a)*b)>>32);}
inline float sign(float a){return (a>0)-(a<0);}
