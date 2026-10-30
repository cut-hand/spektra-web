/* SPDX-License-Identifier: GPL-3.0-or-later
 * LOCAL TEST ONLY. Runs the installed original 1.3.4 Metal library, not
 * shipped, linked or used by the browser/WASM runtime.
 */
#include "cpu-backend.hpp"
#include <stdexcept>
#include <cstdlib>
namespace spk::gpu {
Gpu* create_cpu(){const char*path=std::getenv("SPK_ORACLE_METALLIB");if(!path)throw std::runtime_error("Set SPK_ORACLE_METALLIB for the local native oracle");std::string error;auto*g=Gpu::create_metal(nullptr,path,error);if(!g)throw std::runtime_error(error);std::string detail;if(!g->check_math_mode(detail)){delete g;throw std::runtime_error(detail);}return g;}
}
