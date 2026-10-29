/* SPDX-License-Identifier: GPL-3.0-or-later */
const DB='spektra-darkroom',STORE='workspace';
function database(){return new Promise((resolve,reject)=>{const r=indexedDB.open(DB,1);r.onupgradeneeded=()=>r.result.createObjectStore(STORE);r.onerror=()=>reject(r.error);r.onsuccess=()=>resolve(r.result);});}
async function transaction(mode,action){const db=await database();try{return await new Promise((resolve,reject)=>{const tx=db.transaction(STORE,mode),r=action(tx.objectStore(STORE));let value;r.onsuccess=()=>value=r.result;r.onerror=()=>reject(r.error);tx.oncomplete=()=>resolve(value);tx.onerror=()=>reject(tx.error);tx.onabort=()=>reject(tx.error||Error('本地存储事务中断'));});}finally{db.close();}}
export const readSession=()=>transaction('readonly',store=>store.get('current'));
export async function writeSession(entries,currentId){const saved=entries.map(({id,name,file,raw,demo,params,history,index,thumb,pairIds,pairSources,metadata})=>({id,name,file,raw,demo,params,history,index,thumb,pairIds,pairSources,metadata}));await transaction('readwrite',store=>store.put({version:2,savedAt:Date.now(),currentId,entries:saved},'current'));}
export async function sessionQuota(){return navigator.storage?.estimate?await navigator.storage.estimate():{};}
