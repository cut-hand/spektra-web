/* SPDX-License-Identifier: GPL-3.0-or-later */
// Matrix from the pinned native colour blob (checked against WASM in tests).
export const PROPHOTO_TO_XYZ_D50=[[.7977,.1352,.0313],[.288,.7119,.0001],[0,0,.8249]];
export function inverse3(m){const [a,b,c,d,e,f,g,h,i]=m.flat(),det=a*(e*i-f*h)-b*(d*i-f*g)+c*(d*h-e*g);return [[e*i-f*h,c*h-b*i,b*f-c*e],[f*g-d*i,a*i-c*g,c*d-a*f],[d*h-e*g,b*g-a*h,a*e-b*d]].map(r=>r.map(x=>x/det));}
export const XYZ_D50_TO_PROPHOTO=inverse3(PROPHOTO_TO_XYZ_D50);
