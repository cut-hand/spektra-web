import test from 'node:test';
import assert from 'node:assert/strict';
import {compareTree} from '../scripts/check-upstream.mjs';

test('upstream report distinguishes changed, removed, added profiles and licence changes',()=>{
 const baseline={files:[{upstream_path:'engine/resources/profiles/a.json',upstream_blob_sha:'a'},{upstream_path:'engine/resources_product/profiles/b.json',upstream_blob_sha:'b'},{upstream_path:'catalog.json',upstream_blob_sha:'c'}],notices:[{upstream_path:'LICENSE.txt',upstream_blob_sha:'l'}]};
 const tree=[{path:'engine/resources/profiles/a.json',type:'blob',sha:'new-a'},{path:'engine/resources/profiles/new.json',type:'blob',sha:'new'},{path:'catalog.json',type:'blob',sha:'c'},{path:'LICENSE.txt',type:'blob',sha:'new-l'},{path:'engine/code.cpp',type:'blob',sha:'code'}];
 assert.deepEqual(compareTree(baseline,tree).map(x=>[x.path,x.status]),[['engine/resources/profiles/a.json','changed'],['engine/resources_product/profiles/b.json','removed'],['LICENSE.txt','changed'],['engine/resources/profiles/new.json','added']]);
 assert.deepEqual(compareTree({files:[baseline.files[2]]},tree.filter(x=>x.path==='catalog.json')),[]);
});
