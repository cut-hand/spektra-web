import {parentPort} from 'node:worker_threads';import fs from 'node:fs/promises';
const webFetch=globalThis.fetch;globalThis.fetch=async(url,options)=>{const u=new URL(url);if(u.protocol!=='file:')return webFetch(url,options);try{return new Response(await fs.readFile(u));}catch{return new Response('',{status:404});}};
globalThis.self=globalThis;globalThis.postMessage=(message,transfers)=>parentPort.postMessage(message,transfers);await import('../engine-worker.js');parentPort.on('message',data=>self.onmessage({data}));
