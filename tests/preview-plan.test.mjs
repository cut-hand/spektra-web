import test from 'node:test';import assert from 'node:assert/strict';
import {previewPlan,previewSignature,photoInformation} from '../preview-plan.js';
test('retina fit resolves actual screen pixels instead of enlarging a fixed 900px draft',()=>{
 const p=previewPlan({width:3514,height:2344,availableWidth:1250,availableHeight:780,dpr:2});
 assert.equal(p.height,1560);assert.ok(p.width>2300);assert.equal(p.cssHeight,780);assert.ok(p.width>=p.cssWidth*2-1);assert.equal(p.limited,false);
 const one=previewPlan({width:2400,height:1600,availableWidth:700,availableHeight:500,dpr:2,zoom:1});assert.equal(one.cssWidth,1200);assert.equal(one.width,2400);assert.equal(one.zoom,1);
 const small=previewPlan({width:640,height:480,availableWidth:1200,availableHeight:900,dpr:2});assert.equal(small.width,640);assert.equal(small.height,480);
 const capped=previewPlan({width:10000,height:8000,availableWidth:5000,availableHeight:4000,dpr:2});assert.ok(capped.width*capped.height<=6000000);assert.ok(capped.edge<=4096);assert.equal(capped.limited,true);
});
test('comparison and measured meter EV do not invalidate a clear photographic frame',()=>{
 const p={film:'kodak_portra_400',cameraExposure:0};assert.equal(previewSignature({...p,compare:0,split:.5}),previewSignature({...p,compare:1,split:.7,meterEV:2}));assert.notEqual(previewSignature(p),previewSignature({...p,cameraExposure:1}));
});
test('photo header identifies one working space and explains input/display separately',()=>{
 const info=photoInformation({width:1536,height:1024,sourceSpace:'sRGB',previewWidth:1536,previewHeight:1024});assert.equal(info.text,'1536 × 1024 · 工作：ProPhoto RGB');assert.ok(!info.text.includes('sRGB'));assert.match(info.title,/输入：sRGB/);assert.match(info.title,/屏幕显示：sRGB/);assert.match(info.title,/当前预览：1536 × 1024/);
 const raw=photoInformation({width:3514,height:2344,raw:true,sourceSpace:'ProPhoto RGB',previewWidth:900,previewHeight:600,refining:true});assert.match(raw.title,/RAW 半尺寸解码/);assert.match(raw.text,/正在精化预览/);assert.equal(raw.text.split('ProPhoto RGB').length-1,1);
});
