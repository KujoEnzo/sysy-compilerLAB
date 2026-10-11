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

## Ubuntu 构建与测试

将教师提供的 `lib.tar.gz` 解压到 `vendor/`，确保存在 `vendor/lib/sylib.c`，然后执行：

```bash
make check-tools
make environment
make test
make inspect
```

默认使用 A 的实际环境工具名 `llvm-as-15`、`opt-15`、`llc-15`。若使用 LLVM 18：

```bash
make LLVM_AS=llvm-as-18 OPT=opt-18 LLC=llc-18 test inspect
```

构建产物位于 `build/`，B 侧测试与反汇编证据位于 `logs/b/`。`make clean` 只删除这两个生成目录中的 B 侧产物，不删除源程序、IR、汇编或文档。
