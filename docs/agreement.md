# RV64 预备实验共同约定

## 接口与目标

- 目标：64 位 RISC-V Linux，`rv64gc`，`lp64d`。
- 核心函数：`int fact(int n)`，迭代计算阶乘。
- 输入输出：`getint()`、`putint(int)`、`putch(int)`；结果后调用 `putch(10)`。
- 有效测试域：本次只把 `0、1、5、10、12` 作为核心正确性输入，避免 32 位有符号阶乘溢出。
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

当前 Codex 工作区为 Windows，未安装上述 RISC-V 交叉工具链且没有教师 `lib.tar.gz`；这里完成代码与复现流程，不把本机静态检查写成 Ubuntu 实际运行结果。
