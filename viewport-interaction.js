/* SPDX-License-Identifier: GPL-3.0-or-later */
export function mountViewportInteraction({viewport,shell,canInteract,getZoom,setZoom,fitToWindow,afterPan}){
 let pan=null,suppressClick=false;
 viewport.addEventListener('pointerdown',e=>{if(e.button!==1||!canInteract()||e.target.closest('button,input,select,textarea'))return;e.preventDefault();fitToWindow();afterPan();});
 viewport.addEventListener('auxclick',e=>{if(e.button===1){e.preventDefault();}});
 viewport.addEventListener('wheel',e=>{
  if(!canInteract()||e.target.closest('button,input,select,textarea'))return;
  e.preventDefault();const before=shell.getBoundingClientRect();if(!before.width||!before.height)return;
  const u=(e.clientX-before.left)/before.width,v=(e.clientY-before.top)/before.height;
  const delta=e.deltaY*(e.deltaMode===1?16:e.deltaMode===2?viewport.clientHeight:1);
  setZoom(Math.max(.05,Math.min(3,getZoom()*Math.exp(-Math.max(-300,Math.min(300,delta))*.002))));
  const after=shell.getBoundingClientRect();viewport.scrollLeft+=after.left+u*after.width-e.clientX;viewport.scrollTop+=after.top+v*after.height-e.clientY;afterPan();
 },{passive:false});
 viewport.addEventListener('pointerdown',e=>{
  suppressClick=false;if(e.button!==0||!canInteract()||!e.target.closest('#photoShell')||e.target.closest('#splitControl,button,input'))return;
  pan={id:e.pointerId,x:e.clientX,y:e.clientY,left:viewport.scrollLeft,top:viewport.scrollTop};viewport.setPointerCapture(e.pointerId);shell.classList.add('is-panning');e.preventDefault();
 });
 viewport.addEventListener('pointermove',e=>{if(!pan||pan.id!==e.pointerId)return;const dx=e.clientX-pan.x,dy=e.clientY-pan.y;suppressClick ||= Math.hypot(dx,dy)>3;viewport.scrollLeft=pan.left-dx;viewport.scrollTop=pan.top-dy;afterPan();});
 const finish=e=>{if(pan?.id!==e.pointerId)return;pan=null;shell.classList.remove('is-panning');if(viewport.hasPointerCapture(e.pointerId))viewport.releasePointerCapture(e.pointerId);};
 viewport.addEventListener('pointerup',finish);viewport.addEventListener('pointercancel',finish);viewport.addEventListener('lostpointercapture',()=>{pan=null;shell.classList.remove('is-panning');});
 viewport.addEventListener('click',e=>{if(suppressClick){suppressClick=false;e.preventDefault();e.stopPropagation();}},true);
}
