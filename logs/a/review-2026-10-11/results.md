# A 环境独立复现：全部有效输入

| 路线 | 输入 | 预期 stdout | 退出码 | stdout 逐字节一致 | stderr 仅计时信息 |
| --- | ---: | --- | ---: | --- | --- |
| fact_source | 0 | `1\n` | 0 | 是 | 是 |
| fact_hand_ir | 0 | `1\n` | 0 | 是 | 是 |
| fact_hand_asm | 0 | `1\n` | 0 | 是 | 是 |
| fact_source | 1 | `1\n` | 0 | 是 | 是 |
| fact_hand_ir | 1 | `1\n` | 0 | 是 | 是 |
| fact_hand_asm | 1 | `1\n` | 0 | 是 | 是 |
| fact_source | 2 | `2\n` | 0 | 是 | 是 |
| fact_hand_ir | 2 | `2\n` | 0 | 是 | 是 |
| fact_hand_asm | 2 | `2\n` | 0 | 是 | 是 |
| fact_source | 3 | `6\n` | 0 | 是 | 是 |
| fact_hand_ir | 3 | `6\n` | 0 | 是 | 是 |
| fact_hand_asm | 3 | `6\n` | 0 | 是 | 是 |
| fact_source | 4 | `24\n` | 0 | 是 | 是 |
| fact_hand_ir | 4 | `24\n` | 0 | 是 | 是 |
| fact_hand_asm | 4 | `24\n` | 0 | 是 | 是 |
| fact_source | 5 | `120\n` | 0 | 是 | 是 |
| fact_hand_ir | 5 | `120\n` | 0 | 是 | 是 |
| fact_hand_asm | 5 | `120\n` | 0 | 是 | 是 |
| fact_source | 6 | `720\n` | 0 | 是 | 是 |
| fact_hand_ir | 6 | `720\n` | 0 | 是 | 是 |
| fact_hand_asm | 6 | `720\n` | 0 | 是 | 是 |
| fact_source | 7 | `5040\n` | 0 | 是 | 是 |
| fact_hand_ir | 7 | `5040\n` | 0 | 是 | 是 |
| fact_hand_asm | 7 | `5040\n` | 0 | 是 | 是 |
| fact_source | 8 | `40320\n` | 0 | 是 | 是 |
| fact_hand_ir | 8 | `40320\n` | 0 | 是 | 是 |
| fact_hand_asm | 8 | `40320\n` | 0 | 是 | 是 |
| fact_source | 9 | `362880\n` | 0 | 是 | 是 |
| fact_hand_ir | 9 | `362880\n` | 0 | 是 | 是 |
| fact_hand_asm | 9 | `362880\n` | 0 | 是 | 是 |
| fact_source | 10 | `3628800\n` | 0 | 是 | 是 |
| fact_hand_ir | 10 | `3628800\n` | 0 | 是 | 是 |
| fact_hand_asm | 10 | `3628800\n` | 0 | 是 | 是 |
| fact_source | 11 | `39916800\n` | 0 | 是 | 是 |
| fact_hand_ir | 11 | `39916800\n` | 0 | 是 | 是 |
| fact_hand_asm | 11 | `39916800\n` | 0 | 是 | 是 |
| fact_source | 12 | `479001600\n` | 0 | 是 | 是 |
| fact_hand_ir | 12 | `479001600\n` | 0 | 是 | 是 |
| fact_hand_asm | 12 | `479001600\n` | 0 | 是 | 是 |

runs=39; failed=0
