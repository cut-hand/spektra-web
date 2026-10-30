/* SPDX-License-Identifier: GPL-3.0-or-later */
import {clipboardGroups} from './clipboard-groups.js';
export function mountLibraryUI(actions){
 const clip=document.createElement('details');clip.id='clipboardPanel';clip.className='rail-section';clip.innerHTML='<summary>设置剪贴板</summary><div class="rail-body clipboard-body">'+clipboardGroups.map(([id,label])=>'<label class="clipboard-group">'+label+'<input type="checkbox" data-clipboard-group="'+id+'" checked></label>').join('')+'<p id="clipboardStatus" class="subtle">剪贴板为空。</p><div class="clipboard-buttons"><button id="copySettings">复制</button><button id="pasteSettings" disabled>粘贴</button><button id="syncSettings">同步</button></div></div>';
 document.querySelector('.left-panel .panel-heading').after(clip);
 const groups=()=>[...clip.querySelectorAll('[data-clipboard-group]:checked')].map(el=>el.dataset.clipboardGroup);
 for(const [id,key] of Object.entries({copySettings:'copy',pasteSettings:'paste',syncSettings:'sync'}))clip.querySelector('#'+id).onclick=()=>actions[key]?.(groups());
 return {update({count,clipboard}){clip.querySelector('#pasteSettings').disabled=!clipboard;clip.querySelector('#syncSettings').disabled=count<2;clip.querySelector('#clipboardStatus').textContent=clipboard?'已复制 '+clipboard.groups.length+' 组 · '+clipboard.name:'剪贴板为空。';}};
}
