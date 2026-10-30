/* SPDX-License-Identifier: GPL-3.0-or-later */
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iterator>
#include <vector>
extern "C" {int spk_init(const char*);int spk_prepare(const char*,const char*,const char*,const char*);const char* spk_error();void spk_pixels(const double*,double*,int);}
int main(int argc,char**argv){if(argc!=7){std::fprintf(stderr,"usage: probe resources film paper options.json input.f64 output.f64\n");return 2;}std::ifstream opts(argv[4]);std::string text((std::istreambuf_iterator<char>(opts)),{});if(!spk_init(argv[1])||!spk_prepare(argv[1],argv[2],argv[3],text.c_str())){std::fprintf(stderr,"%s\n",spk_error());return 1;}std::ifstream f(argv[5],std::ios::binary|std::ios::ate);auto bytes=f.tellg();f.seekg(0);if(bytes<0||bytes%(3*sizeof(double)))return 3;std::vector<double>in(size_t(bytes)/sizeof(double)),out(in.size());f.read(reinterpret_cast<char*>(in.data()),bytes);spk_pixels(in.data(),out.data(),int(in.size()/3));std::ofstream o(argv[6],std::ios::binary);o.write(reinterpret_cast<char*>(out.data()),bytes);}
