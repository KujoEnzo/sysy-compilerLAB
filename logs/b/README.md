# B 侧日志目录

在 Ubuntu 项目根目录执行：

```bash
make test
make inspect
```

`make environment` 会保存系统、磁盘和工具版本；`make test` 会保存每条路线、每个输入的 `.stdout`、`.stderr` 和 `.exit`；`make inspect` 会保存文件类型、ELF 头、运行库未定义符号、手写汇编目标文件与链接后程序的反汇编。

本目录中的 README 只是日志格式说明。没有实际运行产生的文件时，不应在报告中声称手写汇编已经通过 QEMU。
