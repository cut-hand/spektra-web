# 原生数学核心移植：0.4.0

固定基线 SpektraLab 1.3.4 / `fd891c6bc5eb350387602deb5c1ef9b6dcdab948`。界面保持原布局，照片始终在浏览器本机处理。

## 已接入的执行链

`LibRaw WASM → 输入调整 → 原版 C++ 数学准备（WASM）→ 原生公式 WGSL 逐点颜色计算 → 33³ float 材料 LUT → 现有 WebGL 预览/空间效果 → 导出`

WebGPU 不可用、初始化失败、设备丢失或启动数值自检不通过时，材料 LUT 使用同一 C++ WASM 逐点适配层计算。没有静默退回旧三基谱模型。“关于浏览器版”显示实际后端。

- `vendor/spektralab/core/`：15 个上游 C++ 翻译单元及其头文件，内容未改动；包含 Hanatos、CAT16、CAM16、光谱、曲线、印相、DI、宽容度工具等。
- `vendor/spektralab/UPSTREAM.json`：每个导入文件的 SHA-256、原始 Git blob 及固定来源。原版常量包原样使用，构建校验摘要。
- `native/bridge.cpp`：新增浏览器适配层，调用原版准备函数并实现无空间效果的逐点参考；这是本项目的改动，不能冒充原版完整渲染器。
- `native/pointwise.wgsl`：逐点 GPU 路径。Hanatos 双三次查表、密度曲线、局部 DIR、81 波段印相/扫描、CAM16、DI 与 EDR。
- `native-core.js`：资源装载、内存与错误边界；`native-webgpu.js`：GPU 资源生命周期；`engine-worker.js`：串行执行，避免共用 C++ 模型被异步请求覆盖。
- `native-neutral.js`：原生逐点模型上的自动配光估算。

## 参数映射与限制

现阶段输入/输出仍使用网页的 sRGB，而非原生 App 的完整 ProPhoto/ColorSync 链。原界面的参数值保留；不保证与原生同名滑杆数值完全等价。

- 放大机 3200 K 选项映射到原生校准的 TH-KG3，其余温度映射 A 或 BB 标准光源。
- 胶片曝光映射原版 camera.exposure_compensation_ev，放大机亮度按 `2^EV` 映射 print_exposure；Y/M 按原生 CC 偏移，原版中性滤色片数据库保留。
- 原版曲线处理后，网页纸反差控制通过曝光轴缩放保留。黑白等级通过滤色片组合映射；不是原生完整黑白 UI 工作流的等价声明。
- 现有“色彩分离”映射原生 DIR 矩阵强度，但只进行逐点校正，没有空间扩散。颗粒/光晕/柔化/眩光继续使用浏览器实现。
- 33³ LUT 是为保留当前渲染器的过渡层，会产生插值误差。WebGPU 已承担逐点 LUT 生成，尚未直接对每个照片像素运行完整原生流水线。
- 宽容度图仍是浏览器的导数阈值近似，尚未接入原生 medium/scene probe 的完整测量流程。
- EDR 使用原版校准表的逐点 SDR 路径；浏览器 HDR 显示、完整色域输出和软打样尚未实现。

## 重建

不需要 Python 图像引擎、服务器或原生 App。需要 Node.js 20+、C++20 编译器与官方 Emscripten **4.0.23**。本机工具链放在项目仓库之外，不是产品依赖。

```sh
# 按官方 emsdk 文档安装/激活 4.0.23，然后在当前终端：
source /path/to/emsdk/emsdk_env.sh
node scripts/build-native.mjs
node scripts/build-native.mjs --native
node --test tests/*.test.mjs
node server.mjs --pages-mode
```

也可以使用环境变量 `EMSDK`、`EMSDK_PYTHON`、`EMXX`、`CXX` 指定工具。构建使用 C++20、O2、异常处理、禁止 fast-math 和 FP contraction。`vendor/spektralab/dist/` 包含 `core.mjs`、`core.wasm` 和原版常量包。编译产物随站点分发；源代码、资源来源和构建脚本公开，允许修改重建与替换。

常量包缺失时，脚本从固定上游提交获取并验证 SHA-256，不从随时变化的 main 下载。材料使用本仓库已核对的 profiles，不修改实测数据。

## 验证边界

宿主 C++ 与 WASM 使用同一适配层，能够发现编译器/资源/接口差异；WGSL 与 WASM 使用相同输入，能够发现 GPU 公式移植错误。两者都不能证明整个 Metal App 与本网页一致。

- `tests/native-core.test.mjs`：未修改源码摘要、宿主/WASM 对照、161 个相容材料路径与 LUT 插值误差。
- `tests/native-worker.test.mjs`：真实 Worker 无 WebGPU 回退、并发请求串行化、缓存元数据、黑白配光与相容性拒绝。
- 浏览器打开 `/tests/native-webgpu.html`，点击 Run parity checks：43 个材料/参数用例，每例 522 个 RGB；允许最大绝对误差 3e-5。测试排除空间与随机效果。
- 实际 RAW 和 TIFF 导出继续在本机验证；测试照片、截图与结果不进入公开仓库。

## 后续替换顺序

1. 把 WebGPU 逐点颜色计算从材料 LUT 生成移到照片像素，去掉 33³ 插值过渡层。
2. 按原顺序移植镜头模糊、散射/光晕、DIR 空间扩散与颗粒，保留物理单位、边界条件和随机流。
3. 接入原生场景置位/宽容度测量、ProPhoto 工作空间、输出色域与软打样。
4. 用同一已解码浮点输入与固定随机种子，与 Metal 逐节点和整图比较，分别记录数值、视觉与性能结果。

上游更新脚本同时报告已导入 C++ 和常量包的变化，升级不自动覆盖适配层或材料。
