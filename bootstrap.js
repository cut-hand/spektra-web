/* SPDX-License-Identifier: GPL-3.0-or-later
 * GitHub Pages does not supply configurable COOP/COEP headers. Register the
 * vendored MIT coi-serviceworker only within this project's own URL scope.
 * Start the editor after isolation setup to avoid losing imported photos to
 * a delayed first-load reload. No upload, third-party request or cache store.
 */
const marker='spektra-isolation:'+new URL('.',import.meta.url).pathname;
const message=document.getElementById('busyText'),overlay=document.getElementById('busyOverlay');
async function establishIsolation(){
 if(crossOriginIsolated){try{sessionStorage.removeItem(marker);}catch{}return true;}
 if(!isSecureContext||!('serviceWorker' in navigator))return false;
 overlay.hidden=false;message.textContent='正在准备本地 RAW 解码环境…';
 const registered=await navigator.serviceWorker.register(new URL('./coi-serviceworker.js',import.meta.url),{scope:new URL('./',import.meta.url).pathname});
 await Promise.race([navigator.serviceWorker.ready,new Promise((_,reject)=>setTimeout(()=>reject(Error('隔离环境准备超时')),12000))]);
 if(!navigator.serviceWorker.controller)await Promise.race([new Promise(resolve=>navigator.serviceWorker.addEventListener('controllerchange',resolve,{once:true})),new Promise((_,reject)=>setTimeout(()=>reject(Error('浏览器未启用隔离控制')),5000))]);
 if(!navigator.serviceWorker.controller||registered.scope!==new URL('./',import.meta.url).href)return false;
 let attempts=0;try{attempts=Number(sessionStorage.getItem(marker)||0);}catch{}
 if(attempts<1){try{sessionStorage.setItem(marker,'1');}catch{return false;}message.textContent='正在启用安全解码环境…';location.reload();return new Promise(()=>{});}
 return false;
}
let isolated=false;try{isolated=await establishIsolation();}catch(e){console.warn('Spektra RAW isolation:',e.message);}
await import('./app.js?v=0.6.0');
if(!isolated){const state=document.getElementById('renderStatus');state.title='当前浏览器未提供 RAW 所需的隔离环境，JPEG/PNG 仍可使用。';}
