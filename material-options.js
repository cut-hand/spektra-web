/* SPDX-License-Identifier: GPL-3.0-or-later */
export const materialDefaults={filmExposure:0,filmGamma:1,paperGamma:1,printExposure:0,yFilter:0,mFilter:0,preflash:0,paperGrade:'2',illuminant:'3200',cameraFilter:'none',couplers:0,printEffects:true,edr:false};
export function materialOptions(p){return Object.fromEntries(Object.entries(materialDefaults).map(([k,v])=>[k,p[k]??v]));}
export function materialKey(p){return JSON.stringify([p.film,p.paper,materialOptions(p)]);}
