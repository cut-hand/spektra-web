import test from 'node:test';import assert from 'node:assert/strict';
import {clipboardGroups,clipboardSubset} from '../clipboard-groups.js';
test('clipboard preserves target framing, date, film edge and post grade while copying independently selected groups',()=>{
 const source={film:'kodak_gold_200',paper:'kodak_portra_endura',cameraExposure:1,metering:'center',cameraTemperature:4200,cameraTint:12,yFilter:4,mFilter:-3,sceneHighlights:2,grain:50,cropZoom:3,rotation:1,border:true,edgeFormat:'120_6x6',dateOn:true,dateText:'2026-10-30',exposure:1,curveMid:30};
 assert.equal(clipboardGroups.length,6);
 assert.deepEqual(clipboardSubset(source,['whiteBalance']),{cameraTemperature:4200,cameraTint:12,yFilter:4,mFilter:-3});
 const all=clipboardSubset(source,clipboardGroups.map(([id])=>id));
 for(const key of ['cropZoom','rotation','border','edgeFormat','dateOn','dateText','exposure','curveMid'])assert.ok(!(key in all),key+' must remain with the target photo');
 assert.equal(all.cameraExposure,1);assert.equal(all.grain,50);assert.deepEqual(clipboardSubset(source,[]),{});
});
