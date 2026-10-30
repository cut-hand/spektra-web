/* SPDX-License-Identifier: GPL-3.0-or-later */
#include <cstdio>
#include <fstream>
#include <iterator>
#include <vector>
extern "C" {int spk_init(const char*);int spk_prepare(const char*,const char*,const char*,const char*);int spk_frame(const float*,float*,int,int,const char*);int spk_grain_probe(float*,int,float,float);const char*spk_error();}
int main(int argc,char**argv){if(argc==6&&std::string(argv[1])=="grain"){if(!spk_init(argv[2]))return 1;std::vector<float>out(65536*3);if(!spk_grain_probe(out.data(),65536,std::stof(argv[3]),std::stof(argv[4])))return 1;std::ofstream f(argv[5],std::ios::binary);f.write(reinterpret_cast<char*>(out.data()),out.size()*4);return 0;}if(argc!=9)return 2;std::ifstream opts(argv[4]);std::string text((std::istreambuf_iterator<char>(opts)),{});if(!spk_init(argv[1])||!spk_prepare(argv[1],argv[2],argv[3],text.c_str())){std::fprintf(stderr,"%s\n",spk_error());return 1;}int w=std::stoi(argv[7]),h=std::stoi(argv[8]);std::vector<float>in(size_t(w)*h*3),out(in.size());std::ifstream f(argv[5],std::ios::binary);f.read(reinterpret_cast<char*>(in.data()),in.size()*4);if(!f||!spk_frame(in.data(),out.data(),w,h,text.c_str())){std::fprintf(stderr,"%s\n",spk_error());return 1;}std::ofstream o(argv[6],std::ios::binary);o.write(reinterpret_cast<char*>(out.data()),out.size()*4);}
