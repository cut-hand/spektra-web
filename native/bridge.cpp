/* SPDX-License-Identifier: GPL-3.0-or-later
 * Browser adapter over unmodified SpektraLab 1.3.4 core.
 * This pointwise reference excludes spatial diffusion / grain / halation.
 * Native and WASM builds share this adapter to isolate compiler differences.
 */
#include <algorithm>
#include <array>
#include <cmath>
#include <fstream>
#include <memory>
#include <sstream>
#include "blob.hpp"
#include "colour.hpp"
#include "curves.hpp"
#include "hanatos.hpp"
#include "printing.hpp"
#include "cam16.hpp"
#include "digital_intermediate.hpp"
#include "setup_cache.hpp"
using namespace spk;
namespace {
std::string error;
Blob blob;
Colour colour;
SetupCache cache;
bool initialized=false;
double clamp(double x,double a=0,double b=1){return std::min(b,std::max(a,x));}
void curves(const InterpTables& t,const double in[3],double out[3]){
 for(size_t c=0;c<3;c++){
  if(in[c]<=t.x[c]){out[c]=t.y[c];continue;}
  if(in[c]>=t.x[(t.k-1)*3+c]){out[c]=t.y[(t.k-1)*3+c];continue;}
  const size_t lo=searchsorted_right(t.x.data()+c,3,t.k,in[c])-1;
  const double f=(in[c]-t.x[lo*3+c])*t.inv[lo*3+c];
  out[c]=t.y[lo*3+c]+f*(t.y[(lo+1)*3+c]-t.y[lo*3+c]);
 }
}
void spectral(const SpectralConstants& s,const double d[3],double out[3]){
 std::fill(out,out+3,0.0);
 for(size_t l=0;l<81;l++){
  double den=s.base_density[l];for(size_t c=0;c<3;c++)den+=d[c]*s.channel_density[3*l+c];
  double t=std::exp2(-den*3.321928094887362);
  for(size_t c=0;c<3;c++)out[c]+=t*s.illum_x_sens[l*3+c];
 }
}
struct Model{
 Params p; Vec tc;size_t side=0;Mat3 toXYZ,scanRGB,outputMatrix;
 InterpTables filmCurve,couplerCurve,paperCurve;PrintConstants print;SpectralConstants scanner;
 Cam16Setup cam;DiConstants di;double dir[9]={};bool isDI=false;
 double yblack=0,ywhite=1,bwgain=1;bool bw=false;
 double option(const Json& j,const char* k,double fallback){return j.at(k).as_double(fallback);}
 bool setup(const std::string& root,const std::string& film,const std::string& paper,const Json& o){
  Json filters;{std::ifstream f(root+"/neutral_print_filters.json");std::stringstream s;s<<f.rdbuf();if(!Json::parse(s.str(),filters,error))return false;}
  const bool direct=paper=="none"||paper=="di";
  if(!init_params(root,film,direct?"kodak_portra_endura":paper,filters,p,error))return false;
  if(!direct&&(p.film.info.channel_model=="bw")!=(p.print.info.channel_model=="bw")){error="Incompatible film and paper";return false;}
  p.io.input_color_space="sRGB";p.io.output_color_space="sRGB";
  p.io.scan_film=p.film.info.is_positive()||paper=="none";isDI=paper=="di"&&!p.io.scan_film;
  p.camera.exposure_compensation_ev=option(o,"filmExposure",0);
  p.film_render.density_curve_gamma=option(o,"filmGamma",1);
  p.film_render.dir_couplers.amount=option(o,"couplers",0);
  p.film_render.dir_couplers.active=p.film_render.dir_couplers.amount>0;
  p.camera.filter=o.at("cameraFilter").is_string()?o.at("cameraFilter").as_string():"none";
  if(p.camera.filter=="none")p.camera.filter.clear();
  else {const std::map<std::string,std::string> names={{"yellow","w8"},{"orange","w21"},{"red","w25"},{"green","w58"},{"blue","w47"}};auto it=names.find(p.camera.filter);if(it!=names.end())p.camera.filter=it->second;}
  // Preserve the native calibrated TH-KG3 default for the old 3200 K choice.
  const auto lamp=o.at("illuminant").as_string();
  if(!lamp.empty()&&lamp!="3200"){p.enlarger.illuminant=lamp=="2856"?"A":"BB"+lamp;if(!digest(p,filters,error))return false;}
  p.enlarger.y_filter_shift=option(o,"yFilter",0);p.enlarger.m_filter_shift=option(o,"mFilter",0);
  p.enlarger.print_exposure=std::exp2(option(o,"printExposure",0));
  p.enlarger.preflash_exposure=o.at("printEffects").as_bool(true)?option(o,"preflash",0):0;
  p.print_render.edr_enabled=o.at("edr").as_bool(false)&&o.at("printEffects").as_bool(true);
  // Paper gamma remains an explicit browser control; native curve morph is
  // used first, then this factor scales its exposure axis. It is not a native wire field.
  Vec sensitivity;if(!film_sensitivity(colour,blob,p.film,p.camera,sensitivity,error))return false;
  const Vec* stored=nullptr;if(!cache.tc_lut(colour,blob,p.film,p.settings,p.io.input_gamut_compress,sensitivity,stored,side,error))return false;tc=*stored;
  if(!tc_b_matrix(colour,blob,"sRGB",p.film.info.reference_illuminant,toXYZ,error))return false;
  double gamma[3];std::fill(gamma,gamma+3,p.film_render.density_curve_gamma);
  build_interp_tables(p.film.data.log_exposure,gamma,p.film.normalized_curves,filmCurve);
  if(p.film_render.dir_couplers.active){Vec before;dir_couplers_matrix(p.film_render.dir_couplers,dir);density_curves_before_dir_couplers(p.film.normalized_curves,p.film.data.log_exposure,dir,p.film.info.is_positive(),before);build_interp_tables(p.film.data.log_exposure,gamma,before,couplerCurve);}
  if(isDI){if(!di_constants(colour,blob,p,tc,side,toXYZ,sensitivity,di,error))return false;}
  if(!p.io.scan_film&&!isDI){
   // The native variable-contrast paper grade is implemented as its native
   // filter pack, rather than substituting a different paper profile.
   if((p.film.info.channel_model=="bw")){
    const int grade=std::clamp(int((o.at("paperGrade").is_string()?std::stod(o.at("paperGrade").as_string()):option(o,"paperGrade",2))),0,5);
    const double y[6]={137.9,99.8,68,34.1,0,0},m[6]={0,0,0,0,39.1,151.7};
    p.enlarger.y_filter_neutral=o.at("paperGrade").as_string()=="00"?199:y[grade];p.enlarger.m_filter_neutral=m[grade];
   }
   if(!print_constants(colour,blob,p,tc,side,print,error))return false;
   Vec morphed;if(!print_curves_morph(p.print.data.log_exposure,p.print.data.model,p.print_render.density_curves_morph,p.print.info.is_positive(),morphed,error))return false;
   const double pg=option(o,"paperGamma",1);double g[3]={pg,pg,pg};build_interp_tables(p.print.data.log_exposure,g,morphed,paperCurve);
  }
  const auto& scanned=p.io.scan_film?p.film:p.print;
  Vec light;if(!standard_illuminant(colour,blob,scanned.info.viewing_illuminant,light,error))return false;
  const auto& cmfs=colour.cmfs_1931_2deg();double norm=0,white[3]={};
  for(size_t l=0;l<81;l++){norm+=light[l]*cmfs[l*3+1];for(int c=0;c<3;c++)white[c]+=light[l]*cmfs[l*3+c];}
  prepare_spectral_constants(scanned.data.channel_density,scanned.data.base_density,light,cmfs,norm,scanner);
  double xy[2];Colour::XYZ_to_xy(white,xy);
  if(!colour.matrix_XYZ_to_RGB("sRGB",xy,"CAT02",scanRGB,error))return false;
  if(!colour.matrix_RGB_to_RGB("sRGB","sRGB","",outputMatrix,error))return false;
  const Cam16Setup* cached;if(!cache.cam16(colour,"sRGB",cached,error))return false;cam=*cached;
  bw=(p.scanner.black_correction||p.scanner.white_correction)&&!p.io.scan_film&&!isDI&&!p.print.info.is_positive();
  if(bw){double black[3],white0[3],xyz[3];
   auto reference=[&](double* raw){double dens[3];for(int c=0;c<3;c++){Vec x(p.print.data.n_exposure),y(x.size());for(size_t k=0;k<x.size();k++){x[k]=p.print.data.log_exposure[k];y[k]=p.print.data.density_curves[k*3+c];}dens[c]=interp(raw[c],x.data(),y.data(),x.size());}spectral(scanner,dens,xyz);return std::max(xyz[1],0.0)+1e-10;};
   std::copy(print.log_raw_black,print.log_raw_black+3,black);std::copy(print.log_raw_white,print.log_raw_white+3,white0);yblack=reference(black);ywhite=reference(white0);
   bwgain=print_exposure_bw_gain(p,yblack,ywhite,colour.cctf_decode(p.scanner.black_level,"sRGB"),colour.cctf_decode(p.scanner.white_level,"sRGB"));
  }
  return true;
 }
 void density(const double rgb[3],double out[3])const{
  double xyz[3],coord[2],raw[3],lograw[3];toXYZ.apply(rgb,xyz);const double b=xyz[0]+xyz[1]+xyz[2];
  double xy[2]={xyz[0]/std::max(1e-10,b),xyz[1]/std::max(1e-10,b)};tri2quad(xy,coord);for(double&v:coord)v=clamp(v);
  lut2d_cubic_host(tc,side,coord,raw);
  for(int c=0;c<3;c++)lograw[c]=std::log10(std::max(raw[c]*b*std::exp2(p.camera.exposure_compensation_ev),0.0)+1e-10);
  curves(filmCurve,lograw,out);
  if(p.film_render.dir_couplers.active){double correction[3]={},x[3];for(int c=0;c<3;c++)for(int d=0;d<3;d++)correction[c]+=(p.film.info.is_positive()?p.film.density_max[d]-out[d]:out[d])*dir[d*3+c];for(int c=0;c<3;c++)x[c]=lograw[c]-correction[c];curves(couplerCurve,x,out);}
 }
 void compress(double rgb[3])const{
  double xyz[3],jab[3],out[3];cam.m_to_xyz.apply(rgb,xyz);xyz_to_cam16ucs(cam,xyz,jab);
  double angle=std::atan2(jab[2],jab[1]),chroma=std::hypot(jab[1],jab[2]);
  const auto& og=p.io.output_gamut_compress;
  if(og.lightness_compression_active)jab[0]=reinhard_knee(jab[0]/cam.white_Jp,og.lightness_compression[0],og.lightness_compression[1],og.lightness_compression[2])*cam.white_Jp;
  double li=clamp(jab[0],cam.l_grid.front(),cam.l_grid.back());li=(li-cam.l_grid.front())/(cam.l_grid.back()-cam.l_grid.front())*(cam.l_grid.size()-1);
  size_t l0=std::min(cam.l_grid.size()-2,size_t(std::floor(li)));double lf=li-l0;
  double hi=(angle-cam.h_grid.front())/(cam.h_grid[1]-cam.h_grid[0]);int h0=int(std::floor(hi)),nh=int(cam.h_grid.size());double hf=hi-h0;h0=(h0%nh+nh)%nh;int h1=(h0+1)%nh;
  auto at=[&](size_t l,int h){return cam.c_max_table[l*nh+h];};
  double cm=(1-lf)*((1-hf)*at(l0,h0)+hf*at(l0,h1))+lf*((1-hf)*at(l0+1,h0)+hf*at(l0+1,h1));cm=std::max(cm,1e-9);
  double newc=reinhard_knee(chroma/cm,og.knee[0],og.knee[1],og.knee[2])*cm;
  jab[1]=newc*std::cos(angle);jab[2]=newc*std::sin(angle);cam16ucs_to_xyz(cam,jab,out);cam.m_to_rgb.apply(out,rgb);
 }
 void pixel(const double rgb[3],double out[3])const{
  double d[3],raw[3],xyz[3],lin[3],tmp[3];density(rgb,d);
  if(isDI){SpectralConstants sc;sc.channel_density=di.chd;sc.base_density.assign(81,0);sc.illum_x_sens=di.ixs;spectral(sc,d,raw);for(int c=0;c<3;c++)raw[c]=std::log10(std::max(raw[c],0.0)+1e-10);curves(di.curve,raw,tmp);double live[3];di_live_offsets(p,live);for(int c=0;c<3;c++)tmp[c]=(std::pow(10.,tmp[c])-di.positive_floor)*std::pow(10.,live[c]);for(int c=0;c<3;c++){lin[c]=0;for(int k=0;k<3;k++)lin[c]+=tmp[k]*di.matrix[k*3+c];const double black=std::pow(10.,(95.-685.)/300.);out[c]=clamp((685.+300.*std::log10(std::max(lin[c],0.0)*(1.-black)+black))/1023.);}return;}
  if(!p.io.scan_film){spectral(print.spectral,d,raw);for(int c=0;c<3;c++){double light=std::max(raw[c]*print.gain[c]+print.offset[c],0.0)+1e-10;light=std::max(light*p.enlarger.print_exposure*bwgain,0.0)+1e-10;raw[c]=std::log10(light);}curves(paperCurve,raw,d);}
  spectral(scanner,d,xyz);for(double&v:xyz)v=std::max(v,0.0)+1e-10;
  if(bw){double black=colour.cctf_decode(p.scanner.black_level,"sRGB"),white=colour.cctf_decode(p.scanner.white_level,"sRGB");if(p.scanner.black_correction&&!p.scanner.white_correction)white=ywhite;if(p.scanner.white_correction&&!p.scanner.black_correction)black=yblack;double m=(white-black)/(ywhite-yblack+1e-10),q=black-m*yblack,s=clamp(m*xyz[1]+q)/(xyz[1]+1e-10);for(double&v:xyz)v*=s;}
  scanRGB.apply(xyz,lin);compress(lin);
  if(p.print_render.edr_enabled&&!p.io.scan_film&&p.print.data.edr_tone_map.available()){
   const auto&e=p.print.data.edr_tone_map;Mat3 toY;std::string ignored;colour.matrix_RGB_to_XYZ("sRGB",nullptr,"CAT02",toY,ignored);double yy[3];toY.apply(lin,yy);double y=std::max(yy[1],1e-10),ev=std::log2(y);Vec axis(e.target_log2_y.size());for(size_t i=0;i<axis.size();i++)axis[i]=e.domain_log2_y[0]+(e.domain_log2_y[1]-e.domain_log2_y[0])*i/(axis.size()-1);double target=(y<e.toe_y||y>e.shoulder_y)?std::exp2(interp(ev,axis.data(),e.target_log2_y.data(),axis.size())):y;for(double&v:lin)v*=target/(y+1e-10);
  }
  outputMatrix.apply(lin,tmp);for(int c=0;c<3;c++)out[c]=colour.cctf_encode(tmp[c],"sRGB");
 }
};
std::unique_ptr<Model> model;
std::vector<float> packed;
void pack_model(){
 const auto&m=*model;packed.assign(64,0);auto add=[&](int slot,const double*p,size_t n){packed[slot]=float(packed.size());for(size_t i=0;i<n;i++)packed.push_back(float(p[i]));};auto vec=[&](int slot,const Vec&v){add(slot,v.data(),v.size());};auto mat=[&](int slot,const Mat3&v){double row[9];v.to_row_major(row);add(slot,row,9);};auto spec=[&](int slot,const SpectralConstants&sc){packed[slot]=float(packed.size());for(const auto*v:{&sc.channel_density,&sc.base_density,&sc.illum_x_sens})for(double x:*v)packed.push_back(float(x));};auto table=[&](int slot,const InterpTables&t){vec(slot,t.x);vec(slot+1,t.inv);vec(slot+2,t.y);};
 packed[0]=float(m.side);packed[1]=float(m.filmCurve.k);packed[2]=float(m.paperCurve.k);packed[3]=m.p.film.info.is_positive();packed[4]=m.p.io.scan_film;packed[5]=m.isDI;packed[6]=m.p.film_render.dir_couplers.active;packed[7]=float(std::exp2(m.p.camera.exposure_compensation_ev));packed[8]=float(m.p.enlarger.print_exposure);packed[9]=float(m.bwgain);packed[10]=m.bw;
 if(m.bw){double black=colour.cctf_decode(m.p.scanner.black_level,"sRGB"),white=colour.cctf_decode(m.p.scanner.white_level,"sRGB");if(m.p.scanner.black_correction&&!m.p.scanner.white_correction)white=m.ywhite;if(m.p.scanner.white_correction&&!m.p.scanner.black_correction)black=m.yblack;packed[11]=float((white-black)/(m.ywhite-m.yblack+1e-10));packed[12]=float(black-packed[11]*m.yblack);}
 packed[13]=m.p.print_render.edr_enabled&&!m.p.io.scan_film&&m.p.print.data.edr_tone_map.available();
 vec(16,m.tc);mat(17,m.toXYZ);table(18,m.filmCurve);table(21,m.couplerCurve);add(24,m.dir,9);add(25,m.p.film.density_max,3);table(26,m.paperCurve);spec(29,m.print.spectral);add(30,m.print.gain,3);add(31,m.print.offset,3);spec(32,m.scanner);mat(33,m.scanRGB);mat(34,m.outputMatrix);
 const auto&c=m.cam;const auto&og=m.p.io.output_gamut_compress;double k[22]={c.F_L,c.N_bb,c.N_cb,c.n,c.z,c.A_w,c.c,c.N_c,c.l_grid.front(),c.l_grid.back(),c.h_grid.front(),c.h_grid[1]-c.h_grid[0],og.knee[0],og.knee[1],og.knee[2],og.lightness_compression_active?og.lightness_compression[0]:1e10,og.lightness_compression[1],og.lightness_compression[2],c.white_Jp,c.D_rgb[0],c.D_rgb[1],c.D_rgb[2]};add(35,k,22);vec(36,c.c_max_table);mat(37,c.m_to_xyz);mat(38,c.m_to_rgb);
 if(m.isDI){SpectralConstants sc;sc.channel_density=m.di.chd;sc.base_density.assign(81,0);sc.illum_x_sens=m.di.ixs;spec(39,sc);table(40,m.di.curve);packed[43]=float(m.di.curve.k);add(44,m.di.matrix,9);double live[3];di_live_offsets(m.p,live);add(45,live,3);packed[46]=float(m.di.positive_floor);}
 if(packed[13]){const auto&e=m.p.print.data.edr_tone_map;vec(47,e.target_log2_y);packed[48]=float(e.target_log2_y.size());packed[49]=float(e.domain_log2_y[0]);packed[50]=float(e.domain_log2_y[1]);packed[51]=float(e.toe_y);packed[52]=float(e.shoulder_y);Mat3 yy;std::string ignored;colour.matrix_RGB_to_XYZ("sRGB",nullptr,"CAT02",yy,ignored);add(53,yy.m[1],3);}
}

}
extern "C" {
const char* spk_error(){return error.c_str();}
int spk_init(const char* root){if(initialized)return 1;error.clear();if(!blob.open(std::string(root)+"/spektrafilm_constants.bin",error)||!colour.init(blob,error))return 0;initialized=true;return 1;}
int spk_prepare(const char* root,const char* film,const char* paper,const char* options){try{error.clear();Json o;if(!Json::parse(options,o,error))return 0;auto next=std::make_unique<Model>();if(!next->setup(root,film,paper,o))return 0;model=std::move(next);return 1;}catch(const std::exception&e){error=e.what();return 0;}}
const float* spk_gpu_data(){if(!model)return nullptr;pack_model();return packed.data();}
int spk_gpu_size(){return int(packed.size());}
void spk_pixels(const double* input,double* output,int n){if(!model)return;for(int i=0;i<n;i++)model->pixel(input+i*3,output+i*3);}
int spk_lut(float* output,int size){if(!model||size<2||size>65)return 0;size_t o=0;for(int b=0;b<size;b++)for(int g=0;g<size;g++)for(int r=0;r<size;r++){double in[3],out[3];int q[3]={r,g,b};for(int c=0;c<3;c++)in[c]=(std::exp2(double(q[c])/(size-1)*std::log2(257.))-1.)/16.;model->pixel(in,out);for(double v:out){if(!std::isfinite(v)){error="Non-finite native pointwise result";return 0;}output[o++]=float(v);}output[o++]=1;}return 1;}
}
