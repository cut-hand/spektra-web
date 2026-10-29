# 跟进原项目更新

当前基线与差异范围见 [UPSTREAM.md](./UPSTREAM.md)。`upstream-version.json` 固定上游标签、完整提交、35 个目录/材料文件的源 blob SHA、规范化内容 SHA-256，以及许可文件 SHA。

## 检查更新

Node.js 20 或更新版本，无依赖。默认检查上游最新正式发布；也可以指定 `main`、标签或完整提交。

```sh
node scripts/check-upstream.mjs
node scripts/check-upstream.mjs --ref main
node scripts/check-upstream.mjs --ref spektralab-v1.3.4
```

脚本只从 GitHub 公共 API 读取版本和 Git 树，输出 JSON，不修改本地文件，不读取照片，也不自动部署。报告包含新增/修改/删除的材料、目录与许可文件、完整目标提交和原生代码比较链接。遇到网络错误、API 限流或不完整 Git 树会失败，不会把失败当作“没有更新”。未配置定时运行；需检查时运行上述命令。

## 升级步骤

1. 保存当前工作并建立升级分支。记录脚本报告的完整目标提交，之后所有读取固定到它，避免 `main` 在升级过程中移动。
2. 阅读上游 Release Notes 和代码比较。分别核对材料/别名/相容性、参数语义、引擎计算、界面工作流、许可变化。材料无变化不代表功能或模型无变化。
3. 按差异导入材料，完整保留 metadata、出处、版权和原始许可证。不要把新胶片只作为名称添加，也不要把产品数据误署名给 spektrafilm。更新 `CHANGELOG.txt` 记录改动。
4. 对照上游修改更新浏览器实现。新增数据结构、光谱算法和参数先验证结果；未移植的能力保留在差异表中。不要仅因控件存在就标记功能等价。
5. 在隔离的升级分支逐份比对解析后的 JSON，更新 `upstream-version.json` 的源 blob SHA 和规范化内容 SHA-256。改变基线提交时同步修改版本测试的预期提交；检查材料数量、相容性和别名测试是否需要随上游变化。
6. 执行 `node --test tests/*.test.mjs`。用本地 RAW 再测导入、预览、完整重新解码、TIFF16/ICC、JPEG、批量导出取消、配对和会话恢复。测试照片始终留在被忽略的目录。
7. 需要宣称原生画质一致时，另行取得相同输入、参数、色彩空间的原生参考输出，进行定量和视觉比较。当前的 LUT 自身插值测试不能替代此步骤。
8. 更新 `package.json`、网页“关于”、`UPSTREAM.md`、README 和 `TEST-REPORT.md` 的版本、对应范围和检查日期。通过后再发布到 GitHub Pages。

## 发布与回退

Pages 使用 `main` 根目录，所有资源采用相对路径；需在实际 `/spektra-web/` 子路径测试首次 Service Worker 引导与 RAW 解码。发布前用 `git diff --stat`、`git ls-files` 检查仓库内容，排除用户原片、测试导出、凭证和机器路径。

为每个稳定浏览器版保留提交或标签。发现回归时用 `git revert` 回退相关提交并重新部署；保留升级报告和失败证据，不强制覆盖历史。浏览器 IndexedDB 会话不随静态部署自动迁移，修改会话结构时必须显式升级并保留旧数据恢复路径。
