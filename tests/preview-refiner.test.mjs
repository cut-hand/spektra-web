import test from 'node:test';import assert from 'node:assert/strict';
import {PreviewRefiner} from '../preview-refiner.js';
test('superseding a detail render terminates synchronous WASM work and rejects only the old job',async()=>{
 const OriginalWorker=globalThis.Worker,workers=[];
 globalThis.Worker=class{constructor(){workers.push(this);}postMessage(m){this.message=m;}terminate(){this.terminated=true;}};
 const refiner=new PreviewRefiner(),source={width:1,height:1,floatPixels:new Float32Array([.1,.2,.3])};
 try{
  const old=refiner.render(source,{}),oldCheck=assert.rejects(old,{name:'AbortError'});
  const current=refiner.render(source,{}),currentCheck=assert.rejects(current,{name:'AbortError'});
  await oldCheck;assert.equal(workers[0].terminated,true);assert.notEqual(workers[1].terminated,true);assert.equal(workers[1].message.type,'frame');
  refiner.cancel();await currentCheck;assert.equal(workers[1].terminated,true);assert.equal(refiner.job,null);
 }finally{refiner.cancel();globalThis.Worker=OriginalWorker;}
});
