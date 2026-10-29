/* SPDX-License-Identifier: GPL-3.0-or-later */
// Geometry, date/edge settings and the post-development grade belong to the target photo.
export const clipboardGroups=[
 ['filmAndPaper','胶片&相纸',['film','paper','edr']],
 ['exposure','曝光',['filmExposure','cameraExposure','cameraExposureAsShot','metering','printExposure']],
 ['whiteBalance','白平衡',['cameraTemperature','cameraTint','cameraTemperatureAsShot','cameraTintAsShot','yFilter','mFilter']],
 ['filmEffects','胶片效果',['filmGamma','couplers','cameraFilter','grain','grainActive','halationActive','glareActive','filmScaleEdge','grainSize','grainChroma','halation','halationRadius','antihalationRemoved','headroom','filmLongMm','format','lensBlur','diffusion','vignette','glare']],
 ['printEffects','相纸效果',['printEffects','preflash','paperGamma','paperGrade','illuminant','sharpen']],
 ['scenePlacement','场景置位',['sceneHighlights','sceneShadows']]
];
export function clipboardSubset(params,groups){const allowed=new Set(clipboardGroups.filter(([id])=>groups.includes(id)).flatMap(([, ,keys])=>keys));return Object.fromEntries(Object.entries(params).filter(([key])=>allowed.has(key)));}
