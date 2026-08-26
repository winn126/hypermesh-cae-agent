# 连接参考组件与模型文件生命周期（HM17）

## 目的

让点焊、胶粘和 RBE2 的审核过程可复现、可追溯，同时避免自动化覆盖工程师提供的原始 `.hm` 模型。

本规则中的“参考组件”指用于发现候选的点、标记实体、参考面或环，不是承载连接的板件网格，也不是已经实现的 connector collector。

## 连接参考组件

| 连接类型 | 标准参考 component | 可归集的实体 | 兼容旧别名 |
| --- | --- | --- | --- |
| 点焊 | `connector_ref_spot_weld` | 点焊小实体标记与中心参考点 | `cankao`、`hanjie` |
| 胶粘 | `connector_ref_glue` | GL 标记面、环或可确认的胶粘参考实体 | `(GL)`、`（GL）` |
| RBE2 | 不要求参考 component | 来自 FE 网格的圆形自由边 | 无 |

执行顺序：

1. 记录每个候选参考实体的原始 component、实体类型、ID 和数量。
2. 创建或复用上表的标准 component。
3. 仅当实体用途明确时自动移动它；含义不清、同时服务多个连接类型或包含板件网格的对象必须保留原位，列为工程师手工归类项。
4. 不得移动 FE 板件单元、结构件、属性、载荷或已实现 connector。
5. 启动审核插件时优先使用标准名称，同时传入兼容别名；在 run manifest 中记录本次实际使用的 reference component 和未归集项。

存在多个同类型候选 component 时，不按名称或颜色猜测。先展示清单、请求工程师选择，或完成有证据的归集后再扫描。

## 阶段化 Save As

每个模型改变阶段都按以下流程：

1. 从当前已验收模型另存为新的工作文件，推荐命名：
   `{source_stem}__P{phase}_{operation}__{timestamp_or_session}.hm`。
2. 仅在同一阶段内的破坏性子操作前，写入 `before` 或 `checkpoint` 恢复快照。
3. 把输入、工作模型、恢复快照、Tcl、日志和审计写入 run manifest。
4. 完成模型与审计验证后，把工作模型标记为该阶段的 `accepted_output_model`。
5. 在 manifest 先写入删除清单后，删除该阶段内部的 `before`/`checkpoint` 临时 `.hm` 文件。

绝不自动删除：

- 原始输入模型；
- 当前阶段的已验收输出模型；
- 尚未验证的恢复模型；
- 未列入 manifest 删除清单的文件；
- 早期阶段的已验收输出（除非最终交付验收后得到工程师批准）。

连接审核面板的 Apply 操作必须保存为新的 `P07_connectors` 结果模型；点焊、胶粘和 RBE2 可写入同一会话生成的结果文件。完成连接阶段的审核、创建和审计后，再由 agent 依据 manifest 清理这一阶段的临时 `before` 模型。

## 验收记录

每个阶段至少记录：

- `input_model` 和 `accepted_output_model`；
- `recovery_models` / `checkpoints`；
- `cleanup_candidates`、`deleted_intermediates` 和未删除原因；
- 执行 Tcl、日志、审计和工程师审批；
- 对连接阶段，实际使用的点焊/胶粘参考 component 和其实体数量。
