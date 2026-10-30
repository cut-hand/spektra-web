# 原版 C++ / WASM 管线：0.5.3

基线为 SpektraLab 1.3.4，固定提交 `fd891c6bc5eb350387602deb5c1ef9b6dcdab948`。保持现有原版布局，照片不离开浏览器。按用户要求移除了 WebGPU 和 WebGL 计算路径。

## 实际执行链

`LibRaw WASM（线性 ProPhoto RGB16）/带 ICC 的 TIFF → 高位深重采样 → C++ WASM → ProPhoto RGB 工作扫描 → 显影后调整 → 最终目标色彩转换 → Canvas 或导出`

原版 `Pipeline::run_film/run_print` 参与实际照片的每个像素，不再经过 33³ 材料 LUT。包括 Hanatos、原生曝光/曲线、物理像素尺寸、镜头模糊、核心+指数尾散射、多次反射光晕、无防光晕层 PSF、DIR 空间扩散、三子层颗粒、染料云/微结构、81 波段印相/扫描、原生场景置位/冲印蒙版、眩光、CAM16、DI、EDR 和扫描锐化。

- `vendor/spektralab/{core,pipeline,gpu,shaders}` 保存未修改上游原文，原始 SHA-256/Git blob 在 UPSTREAM.json。
- `scripts/prepare-native-pipeline.mjs` 将 Metal 地址空间和向量构造改为 C++，生成核调度。公式原文保留；并行最大值归约改为同等串行最大值；contrast mask 的 dispatch_apply 改为逐行循环。生成物在忽略目录，不替代原文。
- `native/metal-compat.hpp` 使用 Clang 向量，保留逐分量运算/排列、Philox 整数溢出、原版泊松采样与双浮点 IIR。
- `native/cpu-backend.cpp` 实现原版 Gpu 内存/调度接口，实际为 CPU。同步执行保证缓冲区复用安全，没有任何 GPU API。
- `native/bridge.cpp` 映射浏览器参数、转换输入为线性 ProPhoto、调用原版管线、最终 CAT02/CAM16/CCTF 输出。
- Canvas 仅显示最终 sRGB 画面；RAW 原始高位深数据和内部工作结果不经过 sRGB 裁切。JPEG/PNG 为 sRGB，TIFF16 嵌入自行生成、使用原版矩阵与分段 TRC 的 ProPhoto ICC。ICC 的构建脚本随源代码提供。
- `native/overscan-boundary.cpp` 明确拒绝尚未移植的原生 CoreText/Accelerate 片边/日期服务。现有浏览器片边/日期呈现继续使用，不能声称该部分原生等价。

## 参数与边界

新默认：均衡测光映射原版 `balanced`；颗粒/光晕强度 100 对应原版 1；DIR 默认 1，扫描锐化 70 对应 0.7。明确保存的旧配方继续保留值。

RAW 使用 LibRaw outputColor=4、线性 gamma、相机拍摄白平衡。输入色温/色调仍是相对于解码白平衡的浏览器调整，不是原版相机色温重解码。场景置位滑杆映射 native room，尚无原生完整自动 Fit。相纸反差现在映射原版曲线 morph；黑白纸等级仍映射滤色片包。显影后创意曲线/色彩平衡保留浏览器定义，但在 ProPhoto 中计算。旧彩色噪声比例控制隐藏，原版使用其自身的分层颗粒模型。

Cube 和宽容度图仍使用独立的逐点 sRGB 参考模型；它们不负责照片渲染，也不包含空间效果。宽容度仍标注近似，自动配光仍为灰世界估算。输出上限 12 MP，拖动预览长边 480px，停止后恢复 900px；WASM CPU 比 GPU 慢，调整期间排队执行。

## 构建和测试

官方 Emscripten 4.0.23，Node 20+，C++20 Clang；禁止 fast-math 和 FP contraction，使用原版 float32 存储。

```sh
source /path/to/emsdk/emsdk_env.sh
node scripts/build-native.mjs
node scripts/build-prophoto-icc.mjs
node scripts/build-native.mjs --native
node scripts/build-native.mjs --native --frame-probe
node --test tests/*.test.mjs
node server.mjs --pages-mode
```

本机独立原版 Metal 验证（仅本地测试，浏览器不使用 Metal）：

```sh
SPK_ORACLE_SOURCE=/path/to/pinned/SpektraLab node scripts/build-native.mjs --native --frame-probe --metal-oracle
SPK_ORACLE_METALLIB=/path/to/SpektraLab.app/Contents/Resources/Resources/engine/spektrafilm.metallib node --test tests/native-frame.test.mjs
```

对照原版已安装 1.3.4 Metal 库，10 组 96×64 合成图：无颗粒最大通道绝对误差 4.411e-6，低于 3e-5。颗粒跨平台的超越函数/曲线细小误差会改变离散抽样，不能保证相同粒子逐像素一致：本组最大 0.008955、平均最大 4.172e-5、RMSE 最大 0.000178。单独五个密度、每组 65,536 像素的原版粒子核均值/方差/偏度与 WASM 相符，且通过泊松解析矩检验。种子固定，WASM 自身重复结果一致。

这验证了所选配置的管线与核移植，不代表所有尺寸、全部组合、原版 RAW 解码和 UI 工作流都完全一致。真实 RAW 与导出另见 TEST-REPORT.md。剩余原生功能见 FEATURE-GAPS.md。


## 0.5.1 交互优化

- 合并同一帧内的控件同步与显影请求，忽略旧参数的过期结果。拖动时使用480px预览，停止180ms后恢复900px；导出仍按所选尺寸完整运行。
- 分割/原图对比复用显示结果；不再跑WASM。材料按钮不再随每一个滑杆事件重建。
- 单份预览扫描缓存限制为100万像素，匹配完整输入字节、形状、模型版本和全部摄影参数。显影后调色复用ProPhoto扫描，输入/曝光/材料等变化会使缓存失效；大尺寸导出不缓存扫描，限制内存占用。
- 逐像素参数查询移到循环外，跳过数学上的恒等处理。最终显示使用原版float32 CAM16核，不再对每个预览像素运行宿主double参考；与double参考测试最大差异3.04e-6。仍禁止fast-math，不使用WebGPU/WebGL。
- 宽容度分析只计算113个原生中性点。33³ LUT只在Cube导出时生成，不再阻塞照片调节。
- 本机900×600、相同输入的三轮交错测试：显影后调色基线2.78–2.86s，新版0.266s；首次完整计算从2.94s降到1.46s。三轮最大输出差异4.98e-6。浏览器实际Worker调色0.267s，20次分割不增加WASM任务。性能随设备与照片而变，仍是CPU完整计算。

## 0.5.2 预览呈现

摄影核心和编译产物不变。快速预览后，独立、可终止的CPU Worker计算匹配窗口DPR的细节；任务完成后释放Worker及WASM堆，保留完成图像用于原图/分割对比。切换照片、摄影参数或导出会取消过时任务。缩放独立于快照分辨率。当前6MP/4096px预览上限与RAW半尺寸解码边界在界面说明，导出仍按原配置执行。

## 0.5.3 RAW/画布边界纠正

libraw-wasm 1.6.0的applySettings仅接受六项gamm。先前传[1,1]被忽略，文档中所谓线性RAW并未得到运行验证，本轮已纠正为[1,1,0,0,0,0]，noAutoBright:true，adjustMaximumThr:0，bright:1，保留相机WB。用自生成两档4:1拜耳DNG直接运行所发WASM，旧比值2.40759，修复4.00076；不依赖私有照片。

原版Canvas在工作空间后交给ColorSync，文件导出另做CAM16。新增displayOutput契约只做目标矩阵/TRC；P3画布/图像数据/分割与片边/最终画布都保留一致标记。JPEG/PNG保持sRGB和原生导出映射，TIFF保持ProPhoto。跳过适配层冗余ProPhoto到自身变换，未修改上游矩阵、曲线或材料。

实际IMG08651.ARW与原版同设置CIRAWFilter参考对照确认，Apple相机配置与LibRaw泛用矩阵仍有差异；此诊断只在本机运行，不被产品依赖。没有宣称浏览器能运行Apple专有RAW引擎。
