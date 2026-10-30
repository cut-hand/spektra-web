/* SPDX-License-Identifier: GPL-3.0-or-later */
#include "cpu-backend.hpp"
#include <emscripten.h>
#include <unordered_set>
#include <vector>
#include <algorithm>
#include <stdexcept>
EM_JS(int,wgpu_create,(size_t n),{try{return Module.spkGPU.create(n);}catch(e){Module.spkGPU.error=Module.spkGPU.error||e.message;return 0;}});
EM_JS(void,wgpu_destroy,(int id),{Module.spkGPU.destroy(id);});
EM_JS(int,wgpu_write,(int id,const void* data,size_t bytes),{try{Module.spkGPU.write(id,HEAPU8.subarray(data,data+bytes));return 1;}catch(e){Module.spkGPU.error=Module.spkGPU.error||e.message;return 0;}});
EM_JS(int,wgpu_dispatch,(const char* name,const uint32_t* ids,size_t count,size_t n),{try{Module.spkGPU.dispatch(UTF8ToString(name),Array.from(HEAPU32.subarray(ids/4,ids/4+count)),n);return 1;}catch(e){Module.spkGPU.error=Module.spkGPU.error||e.message;return 0;}});
EM_JS(int,wgpu_submit,(),{try{Module.spkGPU.submit();return 1;}catch(e){Module.spkGPU.error=Module.spkGPU.error||e.message;return 0;}});
EM_JS(int,wgpu_copy,(int dst,size_t d,int src,size_t s,size_t n),{try{Module.spkGPU.copy(dst,d,src,s,n);return 1;}catch(e){Module.spkGPU.error=Module.spkGPU.error||e.message;return 0;}});
EM_ASYNC_JS(int,wgpu_read,(int id,size_t offset,void* dst,size_t n),{try{const result=await Module.spkGPU.read(id,offset,n);HEAPU8.set(result,dst);return 1;}catch(e){Module.spkGPU.error=Module.spkGPU.error||e.message;return 0;}});
namespace spk::gpu {
struct Buffer{int id;size_t bytes;unsigned refs=1;bool persistent=false,hostDirty=false,gpuDirty=false;std::vector<unsigned char>shadow;};
class WebGpu final:public Gpu{
 std::unordered_set<Buffer*>buffers;
 BufferRef take(size_t bytes,bool persistent,std::string&e){Buffer*best=nullptr;if(!persistent)for(auto*b:buffers)if(!b->persistent&&!b->refs&&b->bytes>=bytes&&b->bytes<=std::max(bytes*2,bytes+65536)&&(!best||b->bytes<best->bytes))best=b;if(best){best->refs=1;best->hostDirty=false;best->gpuDirty=false;best->shadow.clear();return {this,best};}int id=wgpu_create(bytes);if(!id){e="WebGPU buffer allocation failed";return{};}auto*b=new Buffer{id,bytes,1,persistent};buffers.insert(b);return {this,b};}
 bool upload_dirty(Buffer*b,std::string&e){if(b->hostDirty){if(!wgpu_write(b->id,b->shadow.data(),b->bytes)){e="WebGPU buffer upload failed";return false;}b->hostDirty=false;}return true;}
 BufferRef put(const void*p,size_t n,bool persist,std::string&e){auto b=take(n,persist,e);if(b&&!wgpu_write(b.get()->id,p,n)){e="WebGPU upload failed";return{};}return b;}
 BufferRef floats(const double*p,size_t n,bool persist,std::string&e){std::vector<float>v(p,p+n);return put(v.data(),n*4,persist,e);}
public:
 ~WebGpu(){for(auto*b:buffers){wgpu_destroy(b->id);delete b;}}
 std::string device_name()const override{return "WebGPU compute";}
 bool check_math_mode(std::string&d)override{d="WGSL f32; original spectral and spatial pipeline";return true;}
 void begin_frame()override{}void end_frame()override{}
 BufferRef alloc(size_t n,std::string&e)override{return take(n,false,e);}
 BufferRef alloc_zeroed(size_t n,std::string&e)override{auto b=alloc(n,e);if(b){b.get()->shadow.resize(b.get()->bytes,0);b.get()->hostDirty=true;}return b;}
 BufferRef upload(const void*p,size_t n,std::string&e)override{return put(p,n,false,e);}
 BufferRef upload_f32(const double*p,size_t n,std::string&e)override{return floats(p,n,false,e);}
 BufferRef upload_u32(const uint32_t*p,size_t n,std::string&e)override{return put(p,n*4,false,e);}
 BufferRef alloc_persistent(size_t n,std::string&e)override{return take(n,true,e);}
 BufferRef upload_persistent(const void*p,size_t n,std::string&e)override{return put(p,n,true,e);}
 BufferRef upload_persistent_f32(const double*p,size_t n,std::string&e)override{return floats(p,n,true,e);}
 BufferRef upload_persistent_u32(const uint32_t*p,size_t n,std::string&e)override{return put(p,n*4,true,e);}
 BufferRef alloc_file_backed(size_t n,std::string&e)override{return take(n,true,e);}
 BufferRef upload_file_backed(const void*p,size_t n,std::string&e)override{return put(p,n,true,e);}
 BufferRef borrow(void*,size_t,std::string&e)override{e="External native buffers unavailable";return{};}
 void retain(Buffer*b)override{++b->refs;}
 void release(Buffer*b)override{if(--b->refs==0&&b->persistent){buffers.erase(b);wgpu_destroy(b->id);delete b;}}
 void*contents(Buffer*b)override{if(!b)return nullptr;b->shadow.resize(b->bytes);if(b->gpuDirty){if(!wgpu_read(b->id,0,b->shadow.data(),b->bytes))throw std::runtime_error("WebGPU mapping failed");b->gpuDirty=false;}b->hostDirty=true;return b->shadow.data();}
 size_t size_bytes(Buffer*b)const override{return b?b->bytes:0;}
 bool copy(Buffer*dst,size_t d,Buffer*src,size_t s,size_t n,std::string&e)override{if(!validate_copy(dst,d,src,s,n,e))return false;if(!n||(src==dst&&d==s))return true;if(!upload_dirty(src,e))return false;if(!wgpu_copy(dst->id,d,src->id,s,n)){e="WebGPU copy failed";return false;}dst->hostDirty=false;dst->gpuDirty=true;return true;}
 bool read(Buffer*b,size_t offset,void* dst,size_t n,std::string&e)override{if(!validate_read(b,offset,dst,n,e))return false;if(!n)return true;if(!upload_dirty(b,e))return false;if(!wgpu_read(b->id,offset,dst,n)){e="WebGPU read failed";return false;}return true;}
 bool dispatch(const char* name,const std::vector<Arg>&args,size_t n,std::string&e)override{std::vector<uint32_t>ids;std::vector<BufferRef>inlineBuffers;for(const auto&a:args){if(a.buffer){if(!upload_dirty(a.buffer,e))return false;ids.push_back(a.buffer->id);}else{auto b=put(a.bytes,a.size,false,e);if(!b)return false;ids.push_back(b.get()->id);inlineBuffers.push_back(std::move(b));}}if(!wgpu_dispatch(name,ids.data(),ids.size(),n)){e=std::string("WebGPU dispatch failed: ")+name;return false;}for(const auto&a:args)if(a.buffer){a.buffer->gpuDirty=true;a.buffer->hostDirty=false;}return true;}
 bool flush(std::string&e)override{if(!wgpu_submit()){e="WebGPU submit failed";return false;}return true;}
 void*texture(Buffer*,uint32_t,uint32_t,uint32_t,std::string&e)override{e="Canvas uses tagged pixel readback";return nullptr;}
 void release_texture(void*)override{}
 uint32_t texture_row_alignment_px()const override{return 1;}
 uint32_t max_texture_dimension_2d()const override{return 16384;}
 PoolStats pool_stats()const override{PoolStats s;for(auto*b:buffers)if(b->persistent){s.persistent_bytes+=b->bytes;s.persistent_buffers++;}else{s.total_bytes+=b->bytes;s.buffers++;if(b->refs){s.live_bytes+=b->bytes;s.live_buffers++;}else{s.free_bytes+=b->bytes;s.free_buffers++;}}return s;}
 size_t trim_pool(size_t keep)override{size_t freed=0;auto s=pool_stats();for(auto it=buffers.begin();it!=buffers.end();){auto*b=*it;if(!b->persistent&&!b->refs&&s.total_bytes-freed>keep){freed+=b->bytes;wgpu_destroy(b->id);delete b;it=buffers.erase(it);}else++it;}return freed;}
 bool take_critical_pressure()override{return false;}
};
Gpu*create_cpu(){return new WebGpu;}
}
