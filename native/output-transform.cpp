/* SPDX-License-Identifier: GPL-3.0-or-later */
#include "output-transform.hpp"
#include "metal-compat.hpp"
#include <vector>
#include <stdexcept>
namespace output_kernels {
#include "kernels.inc"
}
namespace spk {
void encode_display(float*rgb,uint32_t w,uint32_t h,const Cam16Setup&c,
                    const GamutCompressSpec&og,uint32_t mode,double vignette){
 float m2x[9],m2r[9];double m[9];c.m_to_xyz.to_row_major(m);for(int i=0;i<9;i++)m2x[i]=float(m[i]);c.m_to_rgb.to_row_major(m);for(int i=0;i<9;i++)m2r[i]=float(m[i]);
 const double setup[]={c.F_L,c.N_bb,c.N_cb,c.n,c.z,c.A_w,c.c,c.N_c,c.l_grid.front(),c.l_grid.back(),c.h_grid.front(),c.h_grid[1]-c.h_grid[0],og.knee[0],og.knee[1],og.knee[2],og.lightness_compression[0],og.lightness_compression[1],og.lightness_compression[2],c.white_Jp,c.D_rgb[0],c.D_rgb[1],c.D_rgb[2]};
 float k[22];for(int i=0;i<22;i++)k[i]=float(setup[i]);std::vector<float> table(c.c_max_table.begin(),c.c_max_table.end());
 const uint32_t meta[]={w*h,uint32_t(c.l_grid.size()),uint32_t(c.h_grid.size()),og.lightness_compression_active?1u:0u};
 for(uint32_t i=0;i<w*h;i++){
  float result[3];output_kernels::spk_cam16ucs_compress(rgb+3*i,m2x,m2r,table.data(),k,meta,result,make_uint3(0,0,0));
  double vig=1.;if(vignette!=0){const double x=(double(i%w)+.5)/w-.5,y=(double(i/w)+.5)/h-.5;vig-=vignette*std::clamp((x*x+y*y)*1.5,0.,1.);}
  for(int j=0;j<3;j++){const float v=output_kernels::cctf_encode_mode(float(result[j]*vig),mode);if(!std::isfinite(v))throw std::runtime_error("Non-finite native output");rgb[i*3+j]=v;}
 }
}
}
