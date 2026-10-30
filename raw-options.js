/* SPDX-License-Identifier: GPL-3.0-or-later */
export function rawOptions(full=false){
 // libraw-wasm 1.6.0's actual binding accepts gamm only at length SIX.
 // A two-element [1,1] is silently ignored, leaving the default display TRC.
 // Film input must be scene-linear, without LibRaw's automatic brightening.
 return {useCameraWb:true,useAutoWb:false,useCameraMatrix:1,outputColor:4,outputBps:16,halfSize:!full,userQual:3,highlight:0,gamm:[1,1,0,0,0,0],noAutoBright:true,noAutoScale:false,adjustMaximumThr:0,bright:1,expCorrec:false,threshold:0,medPasses:0};
}
