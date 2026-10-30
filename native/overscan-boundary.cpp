/* SPDX-License-Identifier: GPL-3.0-or-later
 * Native CoreText/Accelerate film-edge/date generation remains a separate
 * port. Existing browser presentation is applied after the native image.
 */
#include "pipeline.hpp"
namespace spk {
bool Pipeline::overscan_wanted()const{return false;}
double Pipeline::overscan_gate_long_mm()const{return params_.camera.film_format_mm;}
void Pipeline::overscan_frame(uint32_t&w,uint32_t&h)const{w=h=0;}
bool Pipeline::set_overscan_frame(uint32_t,uint32_t,std::string&e){if(params_.film_render.overscan.active){e="Native film edges not ported to WASM";return false;}return true;}
std::string Pipeline::overscan_geometry_json()const{return "{\"valid\":false}";}
bool Pipeline::node_overscan(const Image&i,Image&o,std::string&e){if(params_.film_render.overscan.active||params_.film_render.date_imprint.active){e="Native film edge/date service not ported to WASM";return false;}o=i;return true;}
bool Pipeline::node_overscan_film_present(const Image&i,Image&o,std::string&e){return node_overscan(i,o,e);}
bool Pipeline::node_overscan_light(const Image&i,Image&o,std::string&e){return node_overscan(i,o,e);}
}
