# sysy-compilerLAB

RISC-V 预备实验：以迭代阶乘为例，对照 C/SysY 源程序、手写 LLVM IR 与手写 RV64 汇编，并通过同一 SysY 运行库验证输出。

## 目录

- `src/`：源程序与运行库冒烟测试。
- `ir/`：手写 LLVM IR。
- `asm/`：手写 RISC-V 汇编。
- `tests/`：统一测试脚本、期望输出与结果矩阵。
- `docs/agreement.md`：目标、接口、版本与测试约定。
- `docs/report/编译系统原理实验完整报告_郝煦享_田茂炜.md`：两人分工明确、内容去重后的完整实验报告。
- `docs/report/A实验报告草稿_2026-10-10.md`、`B实验报告草稿_2026-10-11.md`：合并前的阶段草稿，保留作过程记录。
- `logs/a/`、`logs/b/`：双方实验记录。
- `docs/report/A复现补记_2026-10-11.md`：PR 修正版在 A 的 WSL 中独立复现的记录；由助手执行，不冒充学生手工操作。
- `logs/local/`：忽略的本机新运行记录，不覆盖双方已提交的证据。

## Ubuntu 构建与测试

从课程渠道取得教师提供的 `lib.tar.gz`，本地放在项目根目录。该文件不随仓库公开分发；取得许可前不要重新加入 Git。确认压缩包清单后解压到 `vendor/`，确保存在 `vendor/lib/sylib.c`，然后执行：

```bash
tar -tzf lib.tar.gz
mkdir -p vendor
tar -xzf lib.tar.gz -C vendor
make check-tools
make clean
make environment
make test
make inspect
sh tests/run_build_regressions.sh
sh tests/run_rv64_domain_tests.sh build/riscv64/fact_source \
  build/riscv64/fact_hand_ir build/riscv64/fact_hand_asm
```

默认使用 A 的实际环境工具名 `llvm-as-15`、`opt-15`、`llc-15`。若使用 LLVM 18：

```bash
make LLVM_AS=llvm-as-18 OPT=opt-18 LLC=llc-18 test inspect
```

构建产物位于 `build/`。新五组测试结果与反汇编记录默认写入 `logs/local/b/`，完整输入域的复现记录默认写入 `logs/local/a-review/`。原 `logs/a/`、`logs/b/`、`tests/results.md` 作为历史证据保留，不由默认复现命令覆盖。

`make clean` 只删除 `build/riscv64/`、`build/runtime/`，不会删除任何日志。回归测试中的清理行为仅在 `/tmp` 下的新建夹具内执行，夹具路径会打印供排查。

可为不同复现者指定独立输出目录：

```bash
make LOG_DIR=logs/local/my-run RESULT_FILE=logs/local/my-run/results.md test inspect
```

`LOG_DIR` 与 `RESULT_FILE` 会传入统一测试脚本。不要主动把输出目录设回原证据目录。完成复现后，只挑选真实、核对过的新记录纳入版本控制。

## 最终提交边界

当前报告仍为 Markdown 整合稿，不是老师要求的最终 PDF。阶乘及 0～12 测试不能证明更多语言特性的正确性；条件分支和更多整数运算的覆盖范围需向助教确认或补例。MLIR 是另行选择的进阶任务。

移除当前版本的压缩包跟踪不会清除已发布的 Git 历史。本地原件应保留；公开分发许可和远端处理方式需要两位成员另行确认，不进行强制推送或历史重写。
