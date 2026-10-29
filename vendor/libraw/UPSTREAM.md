# Vendored LibRaw-Wasm runtime

- Package: libraw-wasm 1.6.0 (ISC declaration in package.json).
- Authors: ybouane, BeseBarni, lexluthor0304, gwennlbh, hrueger and contributors.
- Source and build: https://github.com/ybouane/LibRaw-Wasm/tree/v1.6.0
- Tarball: https://registry.npmjs.org/libraw-wasm/-/libraw-wasm-1.6.0.tgz
- SHA-512: VfvWq2XGGkc07wexymRLn1H82j6smmC1LAbVl41vnW2Z5RrEPLN+YHi1Hmga2TbxxrY4rOjmTwHwSyTZmypE1g==
- Verified complete tarball size: 673510 bytes; WebAssembly.validate succeeds.
- Runtime JS, WASM, source maps, package metadata and readme are unmodified.
- Additional UPSTREAM.md and any source archives are project documentation.
- Original compileLibraw.sh pins LibRaw 0.22.1 and Little CMS lcms2.19.1, built with Emscripten 5.0.7.
- LibRaw corresponding source: https://github.com/LibRaw/LibRaw/tree/0.22.1 (LGPL-2.1 selected; full text in ../../licenses/LibRaw-LGPL.txt).
- Little CMS corresponding source: https://github.com/mm2/Little-CMS/tree/lcms2.19.1 (MIT).
- WebAssembly remains a replaceable external file. Rebuild using upstream compileLibraw.sh and build.js; replace dist/libraw.wasm and generated JS together.
- Shared memory requires cross-origin isolation. No remote CDN calls are made at runtime.

ISC notice for package-authored bindings (as declared by npm package; upstream npm tarball does not include a separate license file):

Copyright (c) ybouane and contributors.

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

Corresponding wrapper source and build entry points are included in source/: libraw_wrapper.cpp, compileLibraw.sh and build.js (unmodified v1.6.0). The pinned LibRaw and Little CMS source releases can be obtained using the original build script or links above.
