# HyperMesh CAE Agent

面向 HyperMesh 17 的可审计 CAE 工程师协同框架：Codex 通过本地 MCP 驱动 HyperMesh；按本包 Skill 执行的模型变更必须遵守工程师审核边界。当前发行版以车门 CAD→CAE 前处理作为已验证参考实现，产品目标是逐步扩展为可配置的通用 HyperMesh CAE Agent。

该包保留 MCP、GUI listener、通用 Agent Skill、知识卡、配色模板、点焊、胶粘和 RBE2 审核面板。未包含 HyperMesh、Codex、Python、模型、网格结果或历史运行记录。MCP 服务和启动脚本包含在包内；旧式 `.mcp.json` 因含机器绝对路径而不交付，改由目标电脑的安装脚本注册唯一 MCP。

完整软件架构、核心文件职责和推荐阅读顺序见 [ARCHITECTURE.md](ARCHITECTURE.md)。

## 产品目标

将 HyperMesh 的确定性 Tcl 操作、可追溯运行记录和工程师判断结合起来：agent 负责连接、受控执行、读回验证、保存证据和提示下一步；工程师负责模型语义、企业标准、例外判断和最终放行。后续通用化通过新增经过验证的流程 Profile、质量标准卡和审核门来实现，而不是把车门经验直接套用到所有模型。

## 当前已验证能力（车门参考实现）

| 能力 | 当前可做的内容 |
| --- | --- |
| 连接与审计 | 创建 HM17 GUI listener、检查 MCP 连接、保存 Tcl/日志/audit，并按 Skill 合同在大步骤前 Save As 到新 `.hm` 文件 |
| 模型管理 | 组件清点、经工程师确认后的命名和功能配色、连接参考几何归类 |
| 前处理 | 对未网格化 solid 与可确认的单层 surface 抽中面；执行低风险 Auto Cleanup 与问题扫描；按 component 独立运行 BatchMesh/受控回退 |
| 连接审核 | 扫描并局部展示点焊、胶粘、RBE2 候选，支持人工审核和补加；只对已批准候选创建连接 |
| 工程师协同 | 对包边、局部网格修复、网格质量、节点共用和异常连接提供定位、证据与局部操作建议，保留工程师决策门 |

MCP 的原始 Tcl 工具是执行原语，不会替工程师判断模型语义或自动批准每一步。Codex 必须通过本包 Skill 和相应 Profile 使用它们；直接绕过流程合同的原始调用不属于本产品承诺的安全工作流。

## 通用化目标与当前边界

当前包不是“任何 CAD、任何行业、全自动完成”的承诺。尚未泛化或不在包内的能力包括：跨行业组件语义识别、任意 CAD 特征理解、全自动包边、全自动网格质量修复与最终放行、材料/厚度/求解器属性自动化，以及未经工程师批准的连接创建。非车门模型必须由工程师提供相应 Profile、尺寸/容差/质量标准和验收条件后再执行模型变更。

## 当前车门参考流程的运行边界

| 阶段 | 责任 |
| --- | --- |
| 导入、组件管理、中面、自动清理、批量网格 | Agent 主导，工程师确认关键输入 |
| 包边、局部网格修复、网格质量判定 | 工程师主导，Agent 提供检查和局部协助 |
| 点焊、胶粘、RBE2 | Agent 扫描和展示；工程师审核后才允许创建 |

本 Skill 合同要求每个大步骤另存为带日期、阶段和操作名的新 HM 文件；保留原始输入，只在已验证输出存在后删除本阶段的恢复文件。

## 前置条件

- Windows；
- 已安装 Codex；自动注册 MCP 时命令行还需可运行 `codex`，否则使用下文的手工注册兜底；
- Python 3.10 或更高版本，可访问 Python 包索引；
- 已安装 HyperMesh 17。交互式审核需要 hw.exe；批处理功能另需 hmbatch.exe；
- 目标目录可写，例如 C:\CAE\hypermesh-cae-agent。

## 一次性安装

1. 将正式压缩包解压到稳定的本机目录。不要放在临时目录或会被同步软件重命名的目录。

2. 在包根目录打开 PowerShell，执行：

~~~powershell
.\scripts\install-local.ps1 -HyperMeshGuiExe 'C:\Program Files\Altair\2017\hw\bin\win64\hw.exe'
~~~

如果需要后台批处理，同时提供：

~~~powershell
.\scripts\install-local.ps1 -HyperMeshGuiExe 'C:\Program Files\Altair\2017\hw\bin\win64\hw.exe' -HyperMeshBatchExe 'C:\Program Files\Altair\2017\hm\bin\win64\hmbatch.exe'
~~~

若点焊连接所需的 Nastran FE 模板不在 HyperMesh 标准位置，补充本机模板目录。此设置仅用于连接创建，不提供材料、厚度或属性自动化：

~~~powershell
.\scripts\install-local.ps1 -HyperMeshGuiExe 'C:\...\hw.exe' -NastranTemplateDir 'C:\...\templates\feoutput\nastran\general'
~~~

安装脚本会创建包内 `.venv`、在线安装已锁定兼容版本的 MCP 运行时、写入本机 `.local\workstation.json`、把 `hypermesh-cae-agent` Skill 安装到当前 Codex 主目录，并用 `codex mcp add` 注册唯一的 `hypermesh-cae-agent` MCP。MCP 运行时只使用该包的 `.venv`，不依赖全局 Python。运行日志和生成 Tcl 会写入 `%LOCALAPPDATA%\HyperMeshCAEAgent\runs`，不会写回交付包。

这是唯一的正式安装路径：不要再单独执行 codex plugin add 或手工添加第二个同名 MCP。若已通过其他途径加载过同一 Skill，仅用于迁移时可增加 -SkipSkillInstall，避免重复加载。

若检测到本包旧名 hypermesh-mcp-server、同名 MCP 或 Skill，先检查它是否正在使用；确认替换后增加 -Force。-Force 只迁移可验证为 HyperMesh CAE Agent 的旧注册：必须是 `powershell.exe` 以受限参数通过 `-File start-hypermesh-mcp.ps1` 启动，并且 `codex mcp get --json` 未包含工具筛选、自定义超时、工作目录、继承环境变量或禁用状态。安装器会在删除前再次比对完整快照；无法证明归属、无法完整恢复或在迁移中发生变化的注册一律不自动删除，并提示人工处理。迁移中的新注册失败时，安装器只会删除与本次快照一致的临时注册，再恢复旧注册；若恢复不完整会明确报错。安装过程中不要在另一终端修改 Codex MCP 配置。

同名通用 Skill 也不会被递归删除：只有其 `SKILL.md` 可验证为本包的 `hypermesh-cae-agent` Skill 时，`-Force` 才会原地更新。升级时，若发现可验证归属的旧 `vehicle-door-cae` Skill，必须使用 `-Force` 执行迁移；安装器会在新 Skill 已验证安装成功后删除旧 Skill，避免 Codex 同时加载两套规则。无法验证的旧目录一律保留并给出 warning。不要添加 `.mcp.json`，也不要同时手工再注册一个同名 MCP。

## 安装验证

~~~powershell
.\scripts\check-environment.ps1 -AsJson
codex mcp get hypermesh-cae-agent
~~~

两项均应成功。然后重启 Codex 或新开一个任务，使新安装的 Skill 与 MCP 生效。

如果当前电脑没有可用的 codex 命令，可使用手工兜底路径：

~~~powershell
.\scripts\install-local.ps1 -HyperMeshGuiExe 'C:\...\hw.exe' -SkipMcpRegistration
Get-Content .\.local\codex-mcp-snippet.toml
~~~

将输出的 TOML 段落粘贴到该电脑的 Codex 配置后重启 Codex。不要将另一台电脑生成的配置或 .local 目录复制过来。

## 首次连接 HyperMesh

1. 在 HyperMesh 17 中打开一个可丢弃的模型。
2. 在 Codex 中请求：检查 HyperMesh CAE 环境，并为当前可见 HM17 创建 GUI listener Tcl；不要修改模型。
3. Codex 返回本次生成的 Tcl 路径后，在 HyperMesh 命令窗口执行：

~~~tcl
source "本次 Codex 返回的 listener Tcl 完整路径"
~~~

4. 在 Codex 中请求：检查 HyperMesh GUI 连接，只执行只读 MCP_PING_OK 测试，不修改模型。

仅在该测试成功后开始模型操作。每次 HyperMesh 重启后，都需要重新创建并 source 本次 listener Tcl；不要复用旧运行目录中的 Tcl。

## 复现验收清单

在另一台电脑上，以下结果全部成立即视为完整复现：

1. install-local.ps1 成功，且 .venv 中存在 mcp==1.27.1；
2. codex mcp get hypermesh-cae-agent 可见唯一 MCP；
3. Codex 能识别 `hypermesh-cae-agent` Skill；
4. check-environment.ps1 -AsJson 报告 GUI 或 batch 模式可用；
5. 可创建并 source GUI listener，读写测试只返回 MCP_PING_OK；
6. 可在不创建连接的条件下打开统一审核面板并扫描点焊、胶粘、RBE2；
7. 运行记录位于 %LOCALAPPDATA%\HyperMeshCAEAgent\runs，交付目录未出现 runs、模型或日志文件。

## 常见问题

- 环境预检提示 MCP 版本不对：重新运行安装脚本，不要用全局 Python 代替包内 .venv。
- Codex 看不到工具：运行 codex mcp get hypermesh-cae-agent，然后重启 Codex 或新开任务。
- GUI 连接失败：确认 HyperMesh 中已 source 本次 listener Tcl；检查端口 47881 是否被旧 HyperMesh 会话占用。
- 点焊创建提示 Nastran 模板缺失：确认 HyperMesh 自身 Nastran FE 模板可用；非标准安装时用 -NastranTemplateDir 重新运行安装脚本并重启 Codex。该模板是点焊创建依赖，不表示本包支持材料、厚度或属性自动化。
- RBE2 创建不可用：确认 HM17 自带 tbcload 1.6 可用；点焊、胶粘扫描仍可独立审核。

## 更新与卸载

更新时解压新包到新目录，再对新目录运行一次 install-local.ps1 -Force。不要覆盖旧目录中的 .local 或 .venv；若安装器提示旧 MCP 或 Skill 不可验证，请先用 `codex mcp get <名称> --json` 审核归属，再由工程师手动清理或保留。

卸载：

~~~powershell
codex mcp remove hypermesh-cae-agent
# 仅在确认下列目录仍是本包的 hypermesh-cae-agent Skill 后再删除：
Remove-Item "$env:USERPROFILE\.codex\skills\hypermesh-cae-agent" -Force -Recurse
~~~

确认没有任务正在使用该 MCP 后，再删除包目录；运行记录可按需从 %LOCALAPPDATA%\HyperMeshCAEAgent\runs 清理。

## 发布包校验

收到 ZIP 或从 Git 克隆后，先在包根目录执行：

~~~powershell
.\scripts\verify-package.ps1 -PackageRoot . -AsJson
~~~

结果中的 `ready` 必须为 `true`。该最小交付包只负责安装和验证，发布构建工具保留在维护者的开发环境中；不要手工编辑 `RELEASE-MANIFEST.json`，也不要把开发目录、模型或运行记录直接交付给他人。

交付包只包含运行所需的统一连接审核面板 `connector_review_panel.tcl`；RBE2 创建宏已内嵌并带校验注释，不包含旧的独立点焊/胶粘/RBE2 面板或外部 `.tbc` 宏。开发仓库中的 `testmodel/`、`.hm`、`.docx` 和历史运行记录只用于测试与追溯，均不属于正式交付物；验收时请使用目标电脑上的可丢弃模型。

交付包的具体架构与推荐阅读顺序见 [ARCHITECTURE.md](ARCHITECTURE.md)。
