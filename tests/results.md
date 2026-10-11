# RV64 阶乘测试结果

本文件由 `tests/run_rv64_tests.sh` 生成。stdout 按字节与期望文件比较；stderr 与退出码分别保留在 `logs/b/`。

| 路线 | 输入 | 预期 stdout | 实际 stdout | 退出码 | stdout 一致 |
| --- | ---: | ---: | ---: | ---: | --- |
| fact_source | 0 | `1\n` | `1` | 0 | 是 |
| fact_hand_ir | 0 | `1\n` | `1` | 0 | 是 |
| fact_hand_asm | 0 | `1\n` | `1` | 0 | 是 |
| fact_source | 1 | `1\n` | `1` | 0 | 是 |
| fact_hand_ir | 1 | `1\n` | `1` | 0 | 是 |
| fact_hand_asm | 1 | `1\n` | `1` | 0 | 是 |
| fact_source | 5 | `120\n` | `120` | 0 | 是 |
| fact_hand_ir | 5 | `120\n` | `120` | 0 | 是 |
| fact_hand_asm | 5 | `120\n` | `120` | 0 | 是 |
| fact_source | 10 | `3628800\n` | `3628800` | 0 | 是 |
| fact_hand_ir | 10 | `3628800\n` | `3628800` | 0 | 是 |
| fact_hand_asm | 10 | `3628800\n` | `3628800` | 0 | 是 |
| fact_source | 12 | `479001600\n` | `479001600` | 0 | 是 |
| fact_hand_ir | 12 | `479001600\n` | `479001600` | 0 | 是 |
| fact_hand_asm | 12 | `479001600\n` | `479001600` | 0 | 是 |
