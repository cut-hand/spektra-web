# 浏览器完整功能移植进度

目标：补齐原项目材料和用户界面功能，发布到 GitHub Pages；所有图像处理留在浏览器。

## 已保存
- 原版完整 StockCatalog.json 与 34 份原始配置（25 胶片、9 印相材料）。
- CineStill 800T 按原版作为 Vision3 500T 的别名，不能伪造独立测量数据。
- 原始 28 份材料 CC BY-SA 4.0；新增产品材料的出处见 licenses/PRODUCT-PROFILES-NOTICE.md。
- 原第一版完整界面和处理代码已复制到本目录，不包含测试照片、Sites 配置、凭证或私人截图。
- 正在接入反转片直扫、黑白相容性和完整材料选取界面。
- 已保存 coi-serviceworker 原始源码与 MIT 许可，待接入 Pages。

## 功能审计待办
- [x] 完整材料选取、搜索、相容性、反转片与数字中间片
- [x] 显影前：测光、胶片曝光、白平衡、色调、镜头/光学模拟、场景置位
- [x] 显影后：曝光、曲线、白平衡、色彩平衡
- [x] 放大机：光源、曝光、滤色片、预闪、对比蒙版、自动配光
- [x] 胶片：密度曲线、颗粒、光晕、耦合剂、格式尺寸
- [x] 片边、日期后背与半格配对
- [x] 任意裁切、旋转、翻转、拉直
- [x] 多照片选择、排序、设置剪贴板、同步
- [x] 逐张批量导出、进度与取消
- [x] JPEG/PNG、16 位 TIFF、数字中间片与 cube 导出
- [x] 配方与本地会话保存/恢复
- [x] GitHub Pages 引导和 Service Worker 无头隔离测试
- [ ] 原生引擎数值一致性（不能以控件存在代替验证）

## 发布
- GitHub 账号：cut-hand；计划仓库：spektra-web。
- GitHub 连接器已验证，可操作现有仓库代码；没有创建仓库或开启 Pages 的接口。
- 浏览器访问 github.com/new 当前网络失败；稍后继续正常连接检查，不修改用户网络设置。
- 发布前须继续排除用户 RAW、测试导出照片、私人截图、凭证和机器路径。

初始版本的处理是简化模型。原版效果和数值未实现时必须持续注明，不得把参数接口补齐误称为原版完整移植。

## 本地开发检查点（2026-10-29）
- 完整材料目录和 161 条相容材料路径通过基础有限性、阶调及灰阶测试。
- 实装输入白平衡/场景置位、曲线/色彩平衡、物理尺寸控制的简化空间效果，GPU 与 CPU 路径均已接入。
- 实装日期叠加、片门/齿孔/片夹边框、几何裁切。
- 已写入多选同步、拖动排序、半格配对、IndexedDB 本地会话代码，端到端回归待进行。
- 已写入 TIFF16/ICC、Cube、ZIP 编码器，导出界面接入和文件读取验证待进行。
- 当前测试 12 项通过；没有把新模块的代码存在算作测试通过。

## 验证检查点
- headerless 本地服务器（Pages 模式）通过 Service Worker 隔离后，真实 RAW 16 位传感器解码成功（3514×2344）。
- 浏览器导出的 RAW TIFF 经 Pillow 重新读取：2048×1366、RGB 三通道各 16 位、sRGB ICC 588 字节；出现 57,047 个不同采样值，确认没有只把 8 位整数乘 257。
- 新增导出和重采样测试后：17 项通过。
- 正在验证三张 RAW 的顺序批量 ZIP，以及日期、片边、半格、会话恢复和高分辨率内存行为。

## 继续开发检查点
- 多选同步、排序、半格配对与分帧调整、日期和片边已写入并开始真实浏览器验证。
- JPEG ICC 重复标记已修复；TIFF16 增加本地导入、RGB 矩阵 ICC 转换和安全的 EXIF 拍摄信息读取，文件往返测试通过。
- 加入自动白平衡/吸管、灰世界配光、导航、曲线预览和溢出警告。
- 现有会话成功从 IndexedDB 恢复。三份 RAW 批量 ZIP 校验通过，JPEG ICC 修复后的浏览器重测尚待完成。
- 新版导出及导入测试已增加至 20 项，完整回归待最后修改完成后执行。
- 原版常量文件只下载到一部分，尚未纳入网站或声称原生重建完成。原生数值路径和镜头数据库仍为明确缺口。

## 发布前检查点（2026-10-30）
- 22 项自动测试通过。真实浏览器中：三张 RAW 顺序导出、取消、会话恢复、半格与分帧编辑、材料同步、反转片、黑白级别、日期片边和自动调整已验证。
- 完整 RAW 解码并输出 11,997,789 像素 TIFF（4241×2829），RGB 三通道各 16 位、ICC 588 字节，成功后可继续编辑。
- JPEG 修复后仅有一个 ICC 段；PNG ICC 可读，黑白输出全部像素 RGB 通道相等；Cube 共 35,937 行有效数据。
- 2026-10-30 已通过 Chrome 登录并创建 cut-hand/spektra-web 公开仓库，准备上传代码与开启 Pages。
- 这里勾选的是浏览器工作流覆盖，不代表原生引擎数值一致。原版 Hanatos/DIR/CAM16、自动镜头数据库、HDR 与完整原生 EDR 仍未实现。

## 授权检查点（2026-10-30）
- 核对原项目 README：应用/引擎 GPL-3.0-or-later，材料/印相 LUT 为 CC BY-SA 4.0。
- 保留原始完整许可证、产品材料来源和第三方库声明；加入独立 CHANGELOG.txt。
- Cube 导出写入作者、来源、许可链接和修改声明；黑白产品材料分别署名。
- GitHub 文件对象已上传，待最终提交及 Pages 开启。测试照片不进入公开仓库。

## 版本基线检查点（2026-10-30）
- 浏览器版 0.2.0；原项目材料基线 SpektraLab 1.3.4，标签 spektralab-v1.3.4，完整提交 fd891c6bc5eb350387602deb5c1ef9b6dcdab948。
- 34 份材料与原目录逐份完整 JSON 比较一致；upstream-version.json 保存源 blob 与本地规范化 SHA-256。
- UPSTREAM.md、README 和关于弹窗写明基线、范围和原生引擎缺口。

## 后续维护准备
- 新增只读上游版本/材料/许可差异检查脚本，支持最新发布或指定 ref；网络失败不误报为无变化。
- UPDATING.md 明确固定提交、审查差异、导入数据、回归、版本同步、发布与回退步骤。
- 未开启无人值守自动更新；脚本不会覆盖当前实现或上传照片。

## 部署完成与正式站点验证（2026-10-30）
- GitHub 仓库 https://github.com/cut-hand/spektra-web，首次完整提交 77f39f3fa8b3448884b928500e8c0413bbc86635。
- GitHub Pages https://cut-hand.github.io/spektra-web/ 已成功部署，main 根目录发布，HTTPS 开启。
- 正式 Pages 首次打开完成引导，示例 GPU 渲染成功；真实 RAW 本机解码 3514×2344、16 位，GPU 显影成功。
- 正式网站 Cube 下载包含 Andrea Volpato / spektrafilm 署名、CC BY-SA 4.0 链接和修改声明。
- 原试用站点也已同步发布为 0.2.0。
- 24 项自动测试通过；上游更新脚本对固定 1.3.4 和最新正式发布的真实 API 检查通过。
- Git 本地 main 对接 GitHub，原 master 开发检查点保留；照片和测试截图仍被忽略。

## 0.3.0 原版布局对齐（进行中，2026-10-30）
- 用户要求使用原项目相同布局；已核对其截图与固定 1.3.4 的六个 UI/模型源文件。
- 三栏紧凑灰色界面、完整文字材料列表、左侧原顺序分组、右侧显影前后已重排。
- 设置剪贴板改为六组独立勾选，复制时固定分组；同步保留目标的裁切、日期、片边和显影后调整。
- FEATURE-GAPS.md 记录实际未实现和近似功能，不能用布局/参数存在代替功能等价。
- 正在进行浏览器回归，完成后继续发布到原 GitHub Pages 与试用站点。

## 0.3.0 本地验证检查点
- 25 项自动测试通过；胶片/相纸相容性、六组复制粘贴保留裁切、显影前后、片边/日期/放大机已在浏览器回归。
- 真实 RAW 导入 3514×2344，导出 TIFF 经独立读取确认为 RGB 三通道各 16 位、sRGB ICC 588 字节。
- 已调整预览按实际内边距适合窗口，消除水平溢出。
- 布局对齐不代表功能等价；详细差异已保存 FEATURE-GAPS.md，网页关于与 README 提供入口。

## 0.3.0 发布与最后回归（2026-10-30）
- GitHub Pages 与原试用站点已发布三栏原版布局；正式站点确认左侧八组顺序、25 胶片及 9 相纸+DI/直扫列表。
- 修复移动控件后吸管与半格分帧保留旧容器引用的问题；吸管启停、右帧编辑及重新合成已补测。
- 发布界面截图保存于被忽略的 test-output；没有上传用户照片或截图。

## 用户补充右侧与整机截图（0.3.1 进行中）
- 去掉底部状态栏和预览下方信息条，把照片尺寸并入顶部工具栏；参数标题移到右栏顶部。
- 显影前只保留宽容度、输入/相机、胶片画幅、场景置位；其余功能收进对应菜单。
- 曝光档位宽容度图由当前浏览器模型与输入测量，显示覆盖率并明确标注近似，不冒用原生数据。
- 新增真实效果开关、按拍摄设置复位/手动状态和胶片基准边显示，待回归。

## 0.3.1 验证完成（2026-10-30）
- 27 项测试通过；手动/拍摄时白平衡、效果开关、长短基准边、CineStill 防光晕状态和菜单吸管通过浏览器验证。
- 新右栏下 RAW 导入及 16 位 TIFF 导出通过；独立读取为 2048×1366、RGB 各 16 位、ICC 588 字节。
- 新截图要求的底部信息栏已删除显示，文件信息并入顶部；显影前只有四个主分组。
- 原生算法、完整色彩管理、片边/日期/半格等功能差异继续公开记录；未用近似 EV 图冒充原生测量。

## 0.3.1 最终线上核对
- Pages 发布成功，新样式 URL 带版本以刷新缓存；四个右侧分组在 864 像素高视口内完整显示。
- 缩略图上方的照片数量/管理行也移入顶部更多工具的照片管理入口，底部仅保留照片。
- 放大机的额外光源与说明收进本组菜单；原版四个调节项直接显示。
- 测试照片与截图继续留在被忽略的本地 test-output。

## C++ / WASM 移植开始（2026-10-30）
- 保留现有界面与固定 1.3.4 基线，先移植数学核心，再逐步替换 GPU 运算。
- 已获取完整固定提交与官方 Emscripten 4.0.23；源文件/资源逐文件 SHA-256 保存 vendor/spektralab/UPSTREAM.json。
- 原始数据不改；C++ 原生/WASM 同输入对照；整机画质一致性仍需独立验证。

## 第一阶段 C++ 数学核心接入检查点
- 原版 15 个 C++ 数学源文件未修改，官方 Emscripten 4.0.23 编译成功；Hanatos、CAT16、原生曲线/光谱/印相常量与 CAM16 现已参与网页 LUT 计算。
- 新 native/bridge.cpp 是明确排除空间与随机效果的逐点适配层，不冒充完整 Metal 管线；输出工作空间暂时保持网页的 sRGB。
- 8 组胶片/相纸/正片/黑白/DI/参数样本的宿主 C++ 与 WASM 对照最大绝对误差 2.054e-15；这不代表 Metal 全管线一致性。
- 本地网页已经真实加载 9 MB 原版常量与 WASM，示例图渲染成功，无控制台错误；准备逐步接入 WebGPU 与 RAW 回归。
- 本地预览 owned session 17982 / http://127.0.0.1:4174/；WASM 输出与重复资源未入 Git，将通过固定构建脚本生成。

## 第二阶段 WebGPU 逐点内核检查点
- 已按原生公式移植 Hanatos 查表/曝光、曲线、局部 DIR、81 波段印相/扫描、CAM16 与 DI/EDR 逐点 WGSL 内核；仍排除空间扩散与随机效果。
- 浏览器真实 WebGPU 与 C++ WASM 对照：9 组材料/参数、每组 522 个 RGB，最大绝对误差约 4.24e-6；33³ float LUT 生成有限。
- WebGPU 现在用于生成网页实际使用的材料 LUT；预览采样与空间效果仍走现有 WebGL。不是完整逐像素 WebGPU 渲染器，不宣称完整原版一致。
- 增加启动数值自检，WebGPU 不可用/失效时退回同一套 C++ WASM 数学模型。原生计算请求串行，防止异步换材料污染全局 C++ 模型。

## 0.4.0 发布前验证完成
- 34 项自动测试通过；161 条原生材料路径有限。
- 43 组真实浏览器 WebGPU 对照通过，最大误差 4.24e-6；512 样本 33³ 插值平均 0.0001944 / 最大 0.003866。
- IMG08589.ARW 新核心渲染及 TIFF16 导出已通过独立读取，2048×1366 / 三通道 16 位 / ICC588。
- 原生源文件、GPU 参考代码与常量更新检查已加入；NATIVE-MIGRATION.md 保存架构、构建、参数映射、差异和后续替换顺序。
- GitHub 已准备 runtime 目录，编译产物先上传后才原子发布新入口，避免线上入口引用缺失 WASM。

## WASM 全图管线 / ProPhoto RGB（进行中）
- 用户明确要求停止 WebGPU，直接移植原版技术到 WASM；以此替代先前 WGSL 路线。
- 已保存原版 pipeline/blur/scene latitude/contrast mask 与 Metal 内核原文；生成器只做地址空间、向量构造及串行调度适配。
- CPU 后端已通过 clang++ 编译，保留原始 float32 公式、Philox/泊松颗粒、反射边界和双浮点 IIR。
- 正接入实际照片、ProPhoto 线性输入/工作扫描/最终显示输出及自动测光；尚未验证或发布，不能把编译通过当作完整一致性。

## 0.5.0 全图 WASM / ProPhoto 验证完成
- 取消 WebGPU/WebGL，原版 C++ run_film/run_print 与核公式直接处理全部照片像素；物理空间散射/反射、DIR 扩散、三子层泊松颗粒、微结构、眩光和锐化已接入。
- RAW 改为 LibRaw 线性 ProPhoto RGB16，预览最终转 sRGB，TIFF16 保留 ProPhoto RGB ICC；带 ICC TIFF 的宽色域 float 数据也保留。
- 新默认均衡映射 native balanced，reset 全部使用相同默认。旧明确设置的配方保留。
- 40 项测试中 39 通过/1 本地 Metal 可选跳过；另单独运行 Metal 门禁 6 项全部通过。无颗粒原版 Metal 全图样本最大误差 4.411e-6；颗粒完整结果不承诺逐像素同粒子，分布矩另验。
- 五种密度各 65,536 像素的粒子核均值/方差/偏度与独立原版 Metal 相符，通过泊松解析矩门禁。
- IMG08589.ARW 真实解码和 2048×1366 TIFF 导出完成；独立 Pillow/LittleCMS 读取 ProPhoto ICC596、RGB各16位。
- 当前准备发布；原生片边/日期、镜头库和 HDR/软打样仍在 FEATURE-GAPS.md 明示。不存在将这些未完成部分声明为已完成。

## 0.5.0 性能问题修复开始
- 用户报告网页非常卡；保持纯 WASM 和 ProPhoto 路线，先测量再改。
- 已定位代码中每次调节/对比都重跑完整照片管线、逐像素重复 JSON 查询/零值创意运算、每次参数变更重建所有材料按钮，以及不参与照片渲染的33³分析LUT阻塞交互。
- 原始 WASM 和 bridge 已备份到忽略的 test-output/performance，正在记录同输入性能基线。

## 0.5.1 性能检查点
- C++输出参数循环外解析、恒等剪枝；100万像素以下ProPhoto扫描缓存，完整输入字节和摄影参数/形状/模型版本匹配，调色复用而非重跑胶片。
- 纯CPU原生float32显示核替代宿主double参考，O3安全数学；无SIMD最低版本限制、无WebGPU/WebGL。
- 原图/分割对比缓存，控件同步与渲染合并，旧帧丢弃，拖动480/稳定900渐进预览。
- 113中性点分析取代交互33³LUT，Cube按需生成；材料列表/分析结果缓存。
- 42测试41通过/1可选Metal跳过；新增显示/缓存回归通过。三轮交错调色约2.8秒降至0.266秒；同图最大差异4.98e-6。浏览器20次分割零额外WASM任务。
- 已保存本地Git检查点91721ba及忽略目录性能报告，正在RAW回归及发布。

- 最新内存优化避免大尺寸输出再复制一份RGB32扫描。RAW TIFF2048×1366 / ProPhoto ICC596 / RGB各16位独立验证，8,392,704采样与0.5.0逐值相同。补充DI显示变换旁路回归，准备最终发布。

## 0.5.2 预览清晰度与色彩空间标签
- 用户对比同一IMG08651.ARW指出模糊；定位为固定900px预览放大至高DPI窗口，原缩放百分比也错误绑定预览尺寸。
- 改为按源图、窗口及DPR计算稳定预览，快照后后台独立CPU Worker精化；改参终止过期Worker，释放大WASM堆；不占交互/导出队列。
- 按源像素/屏幕像素计算百分比及100%一比一；大预览限制4096长边/6MP，限制时明确提示。RAW仍先半尺寸解码，导出可选完整，未宣称完整RAW原生预览等价。
- 主栏仅工作：ProPhoto RGB；输入/显示/导出和真实预览像素在悬停信息说明，避免两个无角色的色彩空间并列。
- 正在以IMG08651.ARW浏览器回归，完成后发布。

- 检查点db31f96已保存。46测试45通过/1可选跳过；IMG08651.ARW稳定预览1390×927对应DPR2/695×464 CSS，大预览2999×2000成功约22秒；调参取消/对比/重置/导出无错误。TIFF2048×1366 / RGB16 / ProPhoto ICC596独立确认。即将发布0.5.2，WASM产物未改。

## 0.5.3 RAW 色差及交互修复进行中
- 用户仍见色差；实际LibRaw WASM确认两项gamm被忽略，旧RAW不是线性输入。IMG08651亮度中位数旧0.1917，六项gamma+禁自动增亮0.0403；原版CIRAW线性参考0.0500。修复场景输入而非修改材料。
- 原版画布按工作空间交给ColorSync，网页误加最终CAM16色域压缩。正分离显示与导出契约，Canvas2D可用时保留Display P3，摄影核心继续C++ WASM、禁止WebGPU。
- Apple CIRAW专有相机配置不同于LibRaw泛用矩阵，纯浏览器不声称完整RAW工作流逐值一致。
- 同轮用户新增：分割按钮再次点击关闭，预览鼠标滚轮以指针为中心缩放、左键拖动平移；已接入，待真实浏览器测试。

- 检查点d029876已保存。48测试47通过/1可选跳过；实际WASM 4:1 DNG线性门禁通过，显示/文件转换分离对照通过；真实浏览器分割开关、滚轮和拖动通过。IMG08651.ARW新的TIFF2048×1366 / RGB16 / ProPhoto ICC596独立验证。准备0.5.3发布，不声称Apple/LibRaw完整一致。

## 0.5.4 — rail cleanup, export and visible refinement (2026-10-30)
- No rail ellipsis menus. Print immediately follows film. Enlarger illuminant/note, pointer/crop toolbar tools, photo management/pairing, recipe I/O, IndexedDB session UI/writes and clipping warning removed. Existing stored data not deleted. Core import/thumbnail selection/clipboard sync retained.
- Circular SVG reset and quarter-turn icons; geometry edits fit/center preview, custom aspect included in source cache key. Asymmetric high-bit quarter-turn regression verifies all directions and round trip.
- Export select padding/height clipping fixed; generated files keep a real download link, errors remain in modal. JPEG quality track follows value and exposes percentage, hidden for other types.
- Reproduced default 3514x2344 RAW export failure under 1 GiB. Best-fit CPU pool, obsolete idle buffer trimming, shared input/output frame allocation; on-demand ceiling 2 GiB. No core photographic formula/profile changes. Default RAW JPEG actual download: 3514x2344, 588-byte sRGB ICC; TIFF actual download: same dimensions, RGB16, 596-byte ProPhoto ICC, 47.1 MiB. Test files remain ignored/local.
- 49 tests: 48 pass, 1 optional Metal skipped. Existing C++/WASM comparisons pass with in-place ABI.
- Obvious refining badge (spinner + text), clears on completion/cancel/error, does not intercept pan/zoom.
- User now permits optional WebGPU, but explicitly chose to show selector ONLY after complete GPU pipeline/parity validation. Full WebGPU not implemented in this release, no partial option.
