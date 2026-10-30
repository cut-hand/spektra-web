/* SPDX-License-Identifier: GPL-3.0-or-later */
#include "cpu-backend.hpp"
#include <cstdlib>
#include <memory>
#include <unordered_set>
#include <algorithm>
#include <limits>
#include "metal-compat.hpp"
namespace kernels {
#include "kernels.inc"
}
namespace spk::gpu {
struct Buffer {void* data;size_t bytes;unsigned refs=1;bool persistent=false;};
class Cpu final:public Gpu {
 std::unordered_set<Buffer*> buffers;
 BufferRef take(size_t n,bool persistent,std::string& error){
  if(!persistent)for(auto*b:buffers)if(!b->persistent&&!b->refs&&b->bytes>=n){b->refs=1;return {this,b};}
  void* p=std::malloc(std::max(n,size_t(1)));if(!p){error="WASM render memory exhausted; reduce the output size";return {};}
  auto*b=new Buffer{p,n,1,persistent};buffers.insert(b);return {this,b};
 }
 BufferRef put(const void* p,size_t n,bool persist,std::string&e){auto b=take(n,persist,e);if(b&&n)std::memcpy(contents(b.get()),p,n);return b;}
 BufferRef floats(const double*p,size_t n,bool persist,std::string&e){auto b=take(n*4,persist,e);if(b){auto*q=static_cast<float*>(contents(b.get()));for(size_t i=0;i<n;i++)q[i]=float(p[i]);}return b;}
 static void* ptr(const Arg&a){return a.buffer?a.buffer->data:const_cast<void*>(a.bytes);}
public:
 ~Cpu(){for(auto*b:buffers){std::free(b->data);delete b;}}
 std::string device_name()const override{return "C++ CPU / WebAssembly";}
 bool check_math_mode(std::string&d)override{d="safe C++ float32; no fast-math";return true;}
 void begin_frame()override{}void end_frame()override{}
 BufferRef alloc(size_t n,std::string&e)override{return take(n,false,e);}
 BufferRef alloc_zeroed(size_t n,std::string&e)override{auto b=alloc(n,e);if(b)std::memset(contents(b.get()),0,n);return b;}
 BufferRef upload(const void*p,size_t n,std::string&e)override{return put(p,n,false,e);}
 void retain(Buffer*b)override{++b->refs;}
 void release(Buffer*b)override{if(--b->refs==0&&b->persistent){buffers.erase(b);std::free(b->data);delete b;}}
 BufferRef upload_f32(const double*p,size_t n,std::string&e)override{return floats(p,n,false,e);}
 BufferRef upload_u32(const uint32_t*p,size_t n,std::string&e)override{return put(p,n*4,false,e);}
 BufferRef alloc_persistent(size_t n,std::string&e)override{return take(n,true,e);}
 BufferRef upload_persistent(const void*p,size_t n,std::string&e)override{return put(p,n,true,e);}
 BufferRef upload_persistent_f32(const double*p,size_t n,std::string&e)override{return floats(p,n,true,e);}
 BufferRef upload_persistent_u32(const uint32_t*p,size_t n,std::string&e)override{return put(p,n*4,true,e);}
 BufferRef alloc_file_backed(size_t n,std::string&e)override{return take(n,true,e);}
 BufferRef upload_file_backed(const void*p,size_t n,std::string&e)override{return put(p,n,true,e);}
 BufferRef borrow(void*,size_t,std::string&e)override{e="Native device buffers unavailable in WASM";return {};}
 void* contents(Buffer*b)override{return b?b->data:nullptr;}
 size_t size_bytes(Buffer*b)const override{return b?b->bytes:0;}
 bool dispatch(const char* kernel,const std::vector<Arg>&args,size_t n,std::string&error)override{
  const std::string name=kernel;using namespace kernels;
  if(name=="spk_reduce_max"){
   const auto*x=static_cast<const float*>(ptr(args[0]));uint count=*static_cast<const uint*>(ptr(args[1]));auto*out=static_cast<float*>(ptr(args[2]));
   // Native dispatch produces ceil(n/256) partials. Mirror its strided
   // grid, avoiding any threadgroup-barrier emulation on the CPU.
   size_t groups=(n+255)/256,grid=groups*256;
   for(size_t g=0;g<groups;g++){float best=-INFINITY;for(size_t lid=0;lid<256;lid++)for(size_t i=g*256+lid;i<count;i+=grid)best=std::max(best,x[i]);out[g]=best;}return true;
  }
#include "dispatch.inc"
  error="Unported native kernel: "+name;return false;
 }
 bool flush(std::string&)override{return true;}
 void* texture(Buffer*,uint32_t,uint32_t,uint32_t,std::string&e)override{e="Canvas uses WASM pixel readback";return nullptr;}
 void release_texture(void*)override{}
 uint32_t texture_row_alignment_px()const override{return 1;}
 uint32_t max_texture_dimension_2d()const override{return 16384;}
 PoolStats pool_stats()const override{PoolStats s;for(auto*b:buffers){if(b->persistent){s.persistent_bytes+=b->bytes;s.persistent_buffers++;}else{s.total_bytes+=b->bytes;s.buffers++;if(b->refs){s.live_bytes+=b->bytes;s.live_buffers++;}else{s.free_bytes+=b->bytes;s.free_buffers++;}}}return s;}
 size_t trim_pool(size_t keep)override{size_t freed=0;auto s=pool_stats();for(auto it=buffers.begin();it!=buffers.end();){auto*b=*it;if(!b->persistent&&!b->refs&&s.total_bytes-freed>keep){freed+=b->bytes;std::free(b->data);delete b;it=buffers.erase(it);}else++it;}return freed;}
 bool take_critical_pressure()override{return false;}
};
Gpu* create_cpu(){return new Cpu;}
}
