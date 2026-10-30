import test from 'node:test';import assert from 'node:assert/strict';import fs from 'node:fs';
import load from '../vendor/libraw/dist/libraw.js';import {rawOptions} from '../raw-options.js';import {makeDNG} from './dng-fixture.mjs';
test('shipped LibRaw WASM really produces linear 4:1 scene patches, unlike the ignored two-item gamma setting',async()=>{
 const m=await load({wasmBinary:fs.readFileSync(new URL('../vendor/libraw/dist/libraw.wasm',import.meta.url))});
 const ratios=[];
 for(const gamm of [[1,1],rawOptions().gamm]){const raw=new m.LibRaw();try{raw.open(makeDNG(),{...rawOptions(),gamm});const im=raw.imageData(),mean=x=>{let sum=0;for(let y=10;y<im.height-10;y++)sum+=im.data[(y*im.width+x)*im.colors+1];return sum/(im.height-20);};const low=mean(Math.floor(im.width*.2)),high=mean(Math.floor(im.width*.8));ratios.push(high/low);assert.ok(high<65535*.5,'automatic brightening must be disabled');}finally{raw.delete();}}
 console.log('Actual LibRaw WASM patch ratios (old/fixed):',ratios);assert.ok(Math.abs(ratios[1]-4)<.02);assert.ok(Math.abs(ratios[0]-4)>.5);
});
