#!/bin/sh
# Independent literal expectations for the complete agreed input domain.
set -eu
if [ "$#" -ne 3 ]; then
    echo 'usage: sh tests/run_rv64_domain_tests.sh SOURCE_EXE IR_EXE ASM_EXE' >&2
    exit 2
fi
qemu=${QEMU:-qemu-riscv64}
log_dir=${LOG_DIR:-logs/local/a-review}
mkdir -p "$log_dir"
for exe in "$@"; do
    test -x "$exe" || { echo "not executable: $exe" >&2; exit 2; }
done
printf '# A 环境独立复现：全部有效输入\n\n| 路线 | 输入 | 预期 stdout | 退出码 | stdout 逐字节一致 | stderr 仅计时信息 |\n| --- | ---: | --- | ---: | --- | --- |\n' > "$log_dir/results.md"
failed=0
runs=0
for pair in 0:1 1:1 2:2 3:6 4:24 5:120 6:720 7:5040 8:40320 9:362880 10:3628800 11:39916800 12:479001600; do
    input=${pair%%:*}
    expected=${pair#*:}
    printf '%s\n' "$expected" > "$log_dir/expected.stdout"
    for route in fact_source fact_hand_ir fact_hand_asm; do
        case "$route" in
            fact_source) exe=$1 ;;
            fact_hand_ir) exe=$2 ;;
            fact_hand_asm) exe=$3 ;;
        esac
        if printf '%s\n' "$input" | "$qemu" "$exe" \
            > "$log_dir/${route}_${input}.stdout" \
            2> "$log_dir/${route}_${input}.stderr"; then
            status=0
        else
            status=$?
        fi
        printf 'exit=%s\n' "$status" > "$log_dir/${route}_${input}.exit"
        match=是
        timing_only=是
        if [ "$status" -ne 0 ] || ! cmp -s "$log_dir/expected.stdout" "$log_dir/${route}_${input}.stdout"; then
            match=否
            failed=1
        fi
        if [ "$(wc -l < "$log_dir/${route}_${input}.stderr")" -ne 1 ] \
            || ! grep -Eq '^TOTAL: [0-9]+H-[0-9]+M-[0-9]+S-[0-9]+us$' "$log_dir/${route}_${input}.stderr"; then
            timing_only=否
            failed=1
        fi
        printf '| %s | %s | `%s\\n` | %s | %s | %s |\n' \
            "$route" "$input" "$expected" "$status" "$match" "$timing_only" >> "$log_dir/results.md"
        runs=$((runs + 1))
    done
done
printf '\nruns=%s; failed=%s\n' "$runs" "$failed" >> "$log_dir/results.md"
test "$failed" -eq 0 || { echo "domain tests failed; see $log_dir" >&2; exit 1; }
printf 'all %s full-domain runs passed; results: %s/results.md\n' "$runs" "$log_dir"
