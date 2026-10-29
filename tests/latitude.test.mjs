import test from 'node:test';import assert from 'node:assert/strict';import fs from 'node:fs/promises';
import {buildLUT} from '../engine.js';import {latitudeWindow} from '../latitude-view.js';globalThis.fetch=async url=>({ok:true,json:async()=>JSON.parse(await fs.readFile(url))});
const {validateRecipe,defaults}=await import('../settings.js');
test('exposure-latitude readout stays finite and nests full tones inside the usable range for real materials',async()=>{
 const profile=async name=>JSON.parse(await fs.readFile(new URL('../profiles/'+name+'.json',import.meta.url)));
 for(const [film,paper] of [['kodak_portra_400','kodak_portra_endura'],['kodak_tri_x_400','ilford_multigrade_iv_rc']]){
  const lut=buildLUT(await profile(film),await profile(paper),33,{},true),range=latitudeWindow(lut);
  for(const values of [range.usable,range.full])assert.ok(values.every(Number.isFinite)&&values[0]<values[1]&&values[0]>=-8&&values[1]<=6);
  assert.ok(range.usable[0]<=range.full[0]&&range.full[1]<=range.usable[1]);
 }
});
test('recipes preserve per-effect switches, as-shot flags and the chosen physical reference edge',()=>{
 const p=validateRecipe({...defaults,grainActive:false,halationActive:false,glareActive:false,cameraTemperatureAsShot:false,cameraTintAsShot:false,filmScaleEdge:'long'});
 assert.equal(p.grainActive,false);assert.equal(p.cameraTemperatureAsShot,false);assert.equal(p.filmScaleEdge,'long');
 assert.throws(()=>validateRecipe({...defaults,grainActive:'off'}));assert.throws(()=>validateRecipe({...defaults,filmScaleEdge:'invalid'}));
});
