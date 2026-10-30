# Spektra 浏览器胶片暗房

无需安装原生应用的本地照片暗房。静态 HTML、JavaScript、C++ WebAssembly、Canvas2D 与 LibRaw WebAssembly；照片不发送到服务器。可部署到 GitHub Pages 的仓库根目录或子路径。

这是基于 [SpektraLab](https://github.com/JamesQiu2005/SpektraLab) / [spektrafilm](https://github.com/andreavolpato/spektrafilm) 材料数据的独立浏览器移植。**功能和画质一致性是两件事：原版 C++ 全图及空间管线已移植到 WASM；颗粒和部分平台功能仍有明确差异。**

**版本基线：SpektraLab 1.3.4**（标签 `spektralab-v1.3.4`，提交 `fd891c6bc5eb350387602deb5c1ef9b6dcdab948`）；浏览器版 **0.5.5**。34 份材料和目录已逐份比对。对应范围和未实现部分见 [UPSTREAM.md](./UPSTREAM.md)。

在线使用：[GitHub Pages](https://cut-hand.github.io/spektra-web/) · [授权与来源](./NOTICE.html)

## 使用

1. 导入 JPEG、PNG、WebP、AVIF、BMP、TIFF 或相机 RAW。RAW 首次采用 16 位半尺寸传感器解码以控制内存；导出可选择重新完整解码。
2. 选择胶片及相容的印相材料。正片直接扫描；黑白胶片自动匹配 Ilford 银盐纸；彩色负片可选相纸、电影拷贝片和数字中间片。
3. 调整输入曝光、白平衡、胶片显影、放大机和扫描参数。日期后背在胶片处理之前叠加；片边在扫描之后合成。
4. 导出 JPEG、PNG、16 位 TIFF 或 33³ Cube。多张照片按各自设置依次显影，打包为 ZIP；可以取消。

按住空格查看原图，⌘/Ctrl+Z 撤销，⌘/Ctrl+Shift+Z 重做，左右箭头切换照片。缩略图复选框、Shift/⌘/Ctrl 点击用于多选。左侧设置剪贴板可独立勾选胶片&相纸、曝光、白平衡、胶片效果、相纸效果、场景置位六组。复制记录当时分组；粘贴使用复制时分组，同步使用当前勾选。裁切、片边、日期和显影后调整保留在目标照片上。

## 材料

完整保留原项目目录的 **25 款胶片 + 9 款印相材料**。`stock-catalog.json` 为原始目录；34 个 JSON 位于 `profiles/`。

- 4 款反转片：Provia 100F、Velvia 100、Ektachrome 100、Kodachrome 64。
- 17 款彩色负片：含 Portra 系列及迫冲、Gold、Ektar、C200、Pro 400H、X-Tra、Ultramax、CineStill、Verita 和 Vision3。
- 4 款黑白胶片：Acros II、HP5 Plus、T-Max 100、Tri-X 400。
- 6 款彩色相纸、Ilford Multigrade IV RC、Kodak 2383 / 2393 拷贝片。

CineStill 800T 按原项目规则继承 Vision3 500T 数值并选择移除防光晕层的路径，不提供虚构的独立测量数据。

## 布局与对应范围

0.5.1 按原版重排为紧凑灰色三栏：左侧导航、设置剪贴板、胶片、印相、片边、日期后背、裁剪、放大机；右侧显影前按宽容度、输入/相机、胶片画幅、场景置位排列，显影后单独分组；控制直接位于对应面板中，取消 ⋯ 次级菜单。文件信息位于顶部，底部只保留缩略图带。材料使用分组文字列表。详细未实现、部分实现和近似算法见 [FEATURE-GAPS.md](./FEATURE-GAPS.md)。

## 工作流

- 输入：拍摄时白平衡、色温/色调、灰世界自动白平衡、中性区域吸管、自动测光、场景高光/阴影置位。
- 显影：胶片曝光/反差、色彩分离、镜前色彩滤镜、冲印曝光、Y/M 滤色片、灰世界自动配光、相纸反差、预闪、EDR 和黑白纸反差级。
- 扫描：曝光/冷暖/色调、曲线、整体/高光/阴影 RGB 平衡、颗粒、光晕、柔化、扩散、锐化、暗角、纸面眩光与冲印蒙版。
- 构图：自定义比例、裁切缩放/平移、90° 旋转、拉直、翻转。片边包含 135、半格、XPan、120 的 645 至 6×17，片门/片夹/齿孔、编号、灰雾与漏光。
- 日期：七段液晶、点阵与拍摄数据，位置/尺寸/曝光可调。
- 照片：每张照片独立设置与撤销历史，缩略图多选与设置剪贴板同步；不再提供配方文件、半格配对、照片移出/排序及 IndexedDB 会话保存/恢复。刷新前请导出结果，原有存储数据不会被主动清除。
- 辅助：RGB 直方图、场景亮度跨度、导航定位、放大、原图与分割对比。

## 导出与限制

- JPEG/PNG：8 位编码 sRGB，嵌入 sRGB ICC。JPEG 质量可调。
- TIFF：三通道 16 位 RGB、无压缩、ProPhoto RGB ICC；RAW 保留线性 ProPhoto 16 位数据，经高位深重采样和原版 C++ 全图浮点管线后量化。普通 8 位输入不会获得额外的原始细节。
- 输出受浏览器内存/纹理上限约束：全部格式最多 12 MP / 长边 8192。片边会增加最终尺寸。完整 RAW 会先按传感器全尺寸解码，再按导出上限缩放。
- Cube 只包含色彩变换，输入/输出均为编码 sRGB；不包含测光及任何空间效果、日期和片边。数字中间片为实验性 Cineon-style log；DI TIFF 不附 sRGB ICC，JPEG/PNG 仅供查看，不用于 Log 数据交换。
- ZIP 总体积限制为 512 MB，避免浏览器耗尽内存；超过请分批导出。输出不复制原始 EXIF/GPS。
- TIFF 输入支持未压缩、Deflate、PackBits 的 8/16 位交错 RGB/灰度条带，以及常见 RGB 矩阵 ICC / 灰度 ICC。暂不支持 BigTIFF、LZW/JPEG 压缩、CMYK、浮点、平面或拼块 TIFF；没有 ICC 的 TIFF 按 sRGB 解释。
- 全部显影使用 C++ WASM CPU Worker，不请求 WebGPU/WebGL；拖动预览长边480px，停止后恢复900px，速度受 CPU 影响。
- 已复用原版 Hanatos / 曲线 / 光谱 / CAM16 数学核心，已接入 DIR 扩散、三子层泊松颗粒与原版多次散射，仍缺原生片边/日期、自动镜头数据库校正及原生 HDR/EDR 显示。当前 EDR 是浏览器 SDR 映射；不能当作 HDR 输出。

## 本地运行与测试

发布仓库已包含编译产物，日常预览无需 npm 依赖。修改 C++ 后先按 [原生核心重建说明](./NATIVE-MIGRATION.md) 编译 WASM 和宿主探针；运行完整测试需要该探针。需要 Node.js 20 或更新版本：

```sh
node server.mjs
node --test tests/*.test.mjs
```

打开终端显示的 localhost 地址。`node server.mjs --pages-mode` 不发送 COOP/COEP 响应头，用来测试 Service Worker 隔离引导。不要通过 `file://` 直接双击 HTML。

## GitHub Pages

1. 将本目录的源文件上传到一个公开仓库。保留 `.nojekyll`、相对目录结构和 `vendor/libraw/dist/libraw.wasm`。
2. 仓库 Settings → Pages → Deploy from a branch，选择 `main` 和 `/ (root)`。
3. 首次 HTTPS 打开可能为隔离环境自动刷新一次。RAW 需要支持 Service Worker、SharedArrayBuffer 和 WebAssembly 的现代浏览器。

Pages 无法配置 COOP/COEP，因此页面使用同源、仅限本项目路径的 `coi-serviceworker.js` 补充隔离头；它不缓存或上传照片。启动过程在隔离就绪后才打开编辑器，避免晚到的刷新丢失已导入照片。

**不要上传测试照片、`test-output/`、凭证、本地缓存或源仓库的私人开发历史。** 网站包不包含任何用户照片。

## 授权

网页与 C++ 实现：GPL-3.0-or-later。28 份上游材料：Andrea Volpato，CC BY-SA 4.0；数值未改，仅紧凑排版。材料与导出 LUT 的变更记录见 [CHANGELOG.txt](./CHANGELOG.txt)。产品新增材料的来源和假设见 `licenses/PRODUCT-PROFILES-NOTICE.md`。LibRaw-Wasm、LibRaw、Little CMS、coi-serviceworker 的授权与可重建来源见 [NOTICE.html](./NOTICE.html)。生成的 sRGB ICC 为 Little CMS 创建的标准 sRGB 配置。

## 后续跟进上游

运行 `npm run check:upstream` 检查最新正式发布，或 `node scripts/check-upstream.mjs --ref main` 检查开发分支。只生成版本、材料与许可差异报告，不自动覆盖当前代码。升级、回归与回退步骤见 [UPDATING.md](./UPDATING.md)。

## 原生核心移植

0.5.1 保留界面，直接将原版 C++ 管线与 Metal 内核公式编译为 WASM CPU 运算。原版 ProPhoto RGB 工作空间、全图光谱处理和空间效果用于实际照片；预览/导出只在最后转换目标空间。移除了 WebGPU/WebGL，不再以 LUT 渲染照片。重建、对照与剩余差异见 [NATIVE-MIGRATION.md](./NATIVE-MIGRATION.md)。

0.5.1 优化：调色复用原生 ProPhoto 扫描、对比复用现有画面、请求合并、拖动快速预览与清晰预览自动切换。导出尺寸与色彩空间保持不变。性能与颜色回归详见 [NATIVE-MIGRATION.md](./NATIVE-MIGRATION.md)。

### 0.5.2 预览清晰度

先显示快速预览，停止操作后在独立CPU Worker按窗口与屏幕像素密度精化；100%按源照片像素与屏幕像素计算。后台任务可取消，不阻塞调参队列。预览最大4096长边/6MP，受限时明确显示；导出保持原有12MP上限。顶部仅标工作空间，输入、显示与导出空间在悬停说明中区分。RAW预览仍先半尺寸解码，完整RAW用于导出选项。

### 0.5.3 RAW 线性输入与显示修正

修复libraw-wasm 1.6.0实际绑定要求六项gamma数组、两项数组被静默忽略的问题，并关闭自动增亮及最大值调整。此前RAW被错误作为线性数据送入模型，因此旧RAW配方的外观会随修正变化。实际WASM合成DNG回归证明4:1场景亮度比得到4.00076，旧设置为2.40759。

原版画布不额外使用导出CAM16映射；现显示与文件导出分别处理，Canvas2D可用时保留Display P3并交给浏览器管理显示。工作空间仍为ProPhoto RGB，全部摄影计算仍为C++ WASM。Apple Core Image的专有RAW解码/相机配置与LibRaw不同，不宣称整个RAW工作流逐值一致。

划分对比按钮可重复点击关闭；预览支持以鼠标位置为中心滚轮缩放、左键拖动平移（放大后），与吸管/分割手柄分开处理。

### 0.5.4 界面与导出

取消所有面板次级菜单，印相紧接胶片；移除放大机光源与说明、照片管理、配方、会话保存和溢出警告。重置与旋转统一为圆弧 SVG，旋转后重置到适合窗口。精化预览使用醒目进度提示。导出下拉框恢复可见文字；生成结果保留下载链接和可见错误，便于手动重试。CPU 缓冲池改为最适合尺寸复用，释放闲置旧尺寸，输入/输出共享 ABI 缓冲；WASM 堆按需增长上限为 2 GiB，以容纳最多 12 MP 的完整管线，低内存设备仍可选择 2048px。

用户选择：待完整 WebGPU 管线及对照验证完成后再展示后端选择器；当前版本仍只运行 C++ WASM，不显示混合模式或占位选项。

### 0.5.5 预览浮层定位

功能差异入口改为带可访问名称与悬停说明的信息 SVG 图标。精化提示、RGB 直方图和处理提示位于照片滚动容器之外的独立浮层，滚轮缩放及左键拖动不会移动这些控件，也不会改变照片的滚动范围。
