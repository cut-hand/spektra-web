/* SPDX-License-Identifier: GPL-3.0-or-later */
#pragma once
#include "gpu/gpu.hpp"
#include "image.hpp"
#include "colour.hpp"
#include "setup_cache.hpp"
#include "json.hpp"
namespace spk {
bool webgpu_input(gpu::Gpu*,const float*,Image&,const Mat3&,const double*,bool,uint32_t,std::string&);
bool webgpu_output(gpu::Gpu*,const Image&,float*,const Json&,Colour&,SetupCache&,bool,std::string&);
}
