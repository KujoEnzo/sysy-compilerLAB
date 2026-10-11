#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
    echo "usage: $0 FACT_SOURCE FACT_IR FACT_ASM" >&2
    exit 2
fi

qemu=${QEMU:-qemu-riscv64}
source_exe=$1
ir_exe=$2
asm_exe=$3
log_dir=${LOG_DIR:-logs/local/b}
result_file=${RESULT_FILE:-$log_dir/results.md}
tmp_dir=${TMP_DIR:-build/riscv64/test}

mkdir -p "$log_dir" "$tmp_dir" "$(dirname -- "$result_file")"

for exe in "$source_exe" "$ir_exe" "$asm_exe"; do
    if [ ! -x "$exe" ]; then
        echo "not executable: $exe" >&2
        exit 2
    fi
done

cat > "$result_file" <<'EOF'
# RV64 阶乘测试结果

本文件由 `tests/run_rv64_tests.sh` 生成。stdout 按字节与期望文件比较；stderr 与退出码分别保留在本次指定的日志目录。默认目录为 `logs/local/b/`。

| 路线 | 输入 | 预期 stdout | 实际 stdout | 退出码 | stdout 一致 |
| --- | ---: | ---: | ---: | ---: | --- |
EOF

failed=0

run_one() {
    route=$1
    exe=$2
    input=$3
    expected=$4
    stdout_file="$log_dir/${route}_${input}.stdout"
    stderr_file="$log_dir/${route}_${input}.stderr"
    exit_file="$log_dir/${route}_${input}.exit"
    expected_file="$tmp_dir/expected_${input}.stdout"

    printf '%s\n' "$expected" > "$expected_file"
    if printf '%s\n' "$input" | "$qemu" "$exe" > "$stdout_file" 2> "$stderr_file"; then
        status=0
    else
        status=$?
    fi
    printf 'exit=%s\n' "$status" > "$exit_file"

    actual=$(tr -d '\r\n' < "$stdout_file")
    if [ "$status" -eq 0 ] && cmp -s "$expected_file" "$stdout_file"; then
        match=是
    else
        match=否
        failed=1
    fi
    printf '| %s | %s | `%s\\n` | `%s` | %s | %s |\n' \
        "$route" "$input" "$expected" "$actual" "$status" "$match" >> "$result_file"
}

for case_pair in 0:1 1:1 5:120 10:3628800 12:479001600; do
    input=${case_pair%%:*}
    expected=${case_pair#*:}
    run_one fact_source "$source_exe" "$input" "$expected"
    run_one fact_hand_ir "$ir_exe" "$input" "$expected"
    run_one fact_hand_asm "$asm_exe" "$input" "$expected"
done

if [ "$failed" -ne 0 ]; then
    echo "one or more tests failed; see $result_file and $log_dir" >&2
    exit 1
fi

echo "all 15 runs passed; results: $result_file"
