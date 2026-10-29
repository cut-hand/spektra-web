// Node adapter for the browser pixel worker; no browser UI automation.
import {parentPort} from 'node:worker_threads';
globalThis.self={};globalThis.postMessage=(value,transfer)=>parentPort.postMessage(value,transfer);
await import('../engine-worker.js');
parentPort.on('message',data=>self.onmessage({data}));
