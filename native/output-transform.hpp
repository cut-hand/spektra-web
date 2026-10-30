/* SPDX-License-Identifier: GPL-3.0-or-later */
#pragma once
#include "cam16.hpp"
#include "params.hpp"
namespace spk {
// Original float32 kernel for the final display conversion, rather than
// re-evaluating its host-side double reference on every preview pixel.
void encode_display(float*rgb,uint32_t w,uint32_t h,const Cam16Setup&cam,
                    const GamutCompressSpec&spec,uint32_t mode,double vignette);
}
