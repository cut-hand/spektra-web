# 对应的原项目版本

浏览器版自身版本：**0.5.3**（2026-10-30）。这是独立实验移植，不是原项目官方发布。

材料与功能参考基线：**SpektraLab 1.3.4**。

- 原仓库：[JamesQiu2005/SpektraLab](https://github.com/JamesQiu2005/SpektraLab)
- 发布标签：[spektralab-v1.3.4](https://github.com/JamesQiu2005/SpektraLab/releases/tag/spektralab-v1.3.4)
- 固定提交：[`fd891c6bc5eb350387602deb5c1ef9b6dcdab948`](https://github.com/JamesQiu2005/SpektraLab/tree/fd891c6bc5eb350387602deb5c1ef9b6dcdab948)
- 校验日期：2026-10-30。

已把本仓库的 `stock-catalog.json` 和 34 份材料 JSON 与该固定提交逐份比较：解析后的完整 JSON（含 metadata 与数值）一致，仅文件排版不同。原版 Git blob SHA 和本地规范化 JSON SHA-256 记录在 [upstream-version.json](./upstream-version.json)，可离线运行 `node --test tests/catalog.test.mjs` 检查本地材料是否偏离该清单。

2026-10-30 核对的上游 `main` 为 `379f4abf62c65a85f64758e6f111cd46dfa78512`；其材料目录和 34 份数据与 1.3.4 标签没有差异。浏览器版固定引用 1.3.4，不以随时间变化的“最新版”作为版本说明。

## 对应范围

| 范围 | 浏览器版 0.5.3 |
|---|---|
| 胶片与印相目录 | 1.3.4 的 25 款胶片、9 款印相材料；34 份原始配置 |
| 照片工作流 | 本机 RAW 解码、逐张参数、多选同步、批量导出、半格配对、日期片边、裁切和会话恢复 |
| 光谱处理核心 | 固定 1.3.4 的原始 C++ 数学源文件编译为 WASM，新增逐点适配层；仍不是完整 Metal 管线移植 |
| 色彩与空间效果 | Hanatos、曲线、光谱、印相与 CAM16 已接入；WASM/WebGPU 逐点对照通过，整机未验证 |
| 尚未实现 | 完整逐像素渲染、DIR 空间扩散、原版颗粒/散射模型、自动镜头数据库校正、原生 HDR 显示和完整色彩管理/软打样 |

因此“基于 1.3.4”指可核实的材料与参考基线，不能理解为 1.3.4 的所有能力或画质已等价实现。各导出限制见 [README.md](./README.md)。原始授权与变更见 [NOTICE.html](./NOTICE.html) 和 [CHANGELOG.txt](./CHANGELOG.txt)。

0.5.3 恢复原版布局与六组设置剪贴板；逐项差异见 [FEATURE-GAPS.md](./FEATURE-GAPS.md)。

C++ 数学源码的逐文件清单、构建与验证边界见 [NATIVE-MIGRATION.md](./NATIVE-MIGRATION.md)。
