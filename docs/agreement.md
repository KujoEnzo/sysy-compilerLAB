# RV64 预备实验共同约定

## 接口与目标

- 目标：64 位 RISC-V Linux，`rv64gc`，`lp64d`。
- 核心函数：`int fact(int n)`，迭代计算阶乘。
- 输入输出：`getint()`、`putint(int)`、`putch(int)`；结果后调用 `putch(10)`。
- 有效输入域：整数 0～12；核心统一测试保留 `0、1、5、10、12` 五组。A 环境的补充复现覆盖全部 13 个有效整数；13 及以上的阶乘溢出、负数及输入失败不在本次正确性结论内。
- 三条 RV64 路线使用同一份由教师 `sylib.c` 重建的 Linux 静态库，不覆盖教师原始 `libsysy_riscv.a`。

## 已冻结文件

| 表示 | 文件 | 主责 |
| --- | --- | --- |
| SysY/C 兼容源程序 | `src/fact_sysy.c` | A：郝煦享（2412695） |
| 手写 LLVM IR | `ir/fact_hand.ll` | A：郝煦享（2412695） |
| 手写 RISC-V 汇编 | `asm/fact_hand.s` | B：田茂炜（2412784） |
| 构建与测试整合 | `Makefile`、`tests/run_rv64_tests.sh` | B：田茂炜（2412784） |

## 预期输出

| 输入 | stdout（含末尾换行） |
| ---: | --- |
| 0 | `1\n` |
| 1 | `1\n` |
| 5 | `120\n` |
| 10 | `3628800\n` |
| 12 | `479001600\n` |

测试只把 stdout 当作答案；退出码必须为 0。教师运行库可能向 stderr 输出 `TOTAL: ...`，该内容单独保存，不混入 stdout，也不自动视为失败。

## 实际环境基线

A 在 2026-10-10 的 Ubuntu 实验记录中使用：Ubuntu 22.04.1 LTS、GCC 11.4、Clang/LLVM 15.0.7、`riscv64-linux-gnu-gcc` 11.4、QEMU 6.2。`Makefile` 因此默认 LLVM 工具名带 `-15`，可在命令行覆盖，例如：

```bash
make LLVM_AS=llvm-as-18 OPT=opt-18 LLC=llc-18 test
```

Windows 是文档和代码编辑端，RISC-V 实际构建及运行在 Linux 中进行。B 的原始记录位于 `logs/b/`；2026-10-11 的 A 环境独立复现记录位于 `logs/a/review-2026-10-11/`。后者由 Codex 助手在 A 的 WSL 执行，不能表述为学生逐条手工运行；详情见 `docs/report/A复现补记_2026-10-11.md`。

## 原始证据与课程材料

- `make test`、`make inspect` 的新记录默认写入忽略目录 `logs/local/b/`，不覆盖 `logs/a/`、`logs/b/` 或原 `tests/results.md`。
- `make clean` 仅清理构建产物，保留所有记录。
- 从课程渠道单独取得 `lib.tar.gz`，保留教师原件；未确认公开许可前不跟踪该压缩包。不覆盖教师预编译库。
- 本轮只修正复现流程和补记证据，没有补做综合语义示例、MLIR 或最终 PDF，不能声称所有提交要求已经完成。
