#!/bin/sh
# Exercise the real Makefile in disposable fixtures; never clean the repository.
set -eu
repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
sandbox=$(mktemp -d /tmp/sysy-build-regression.XXXXXX)
cp "$repo/Makefile" "$sandbox/Makefile"
mkdir -p "$sandbox/tests/expected" "$sandbox/build/riscv64" \
    "$sandbox/build/runtime" "$sandbox/logs/a" "$sandbox/logs/b" \
    "$sandbox/logs/local/b" "$sandbox/fixtures"
cp "$repo/tests/expected/smoke.stdout" "$sandbox/tests/expected/smoke.stdout"
cp "$repo/tests/fixtures/"*.sh "$sandbox/fixtures/"
chmod +x "$sandbox/fixtures/"*.sh
touch "$sandbox/build/riscv64/runtime_smoke" "$sandbox/build/runtime/generated.o"
printf 'original B evidence\n' > "$sandbox/logs/b/evidence.stdout"
printf 'original A evidence\n' > "$sandbox/logs/a/evidence.stdout"
printf 'local reproduction evidence\n' > "$sandbox/logs/local/b/evidence.stdout"
cp "$sandbox/logs/b/evidence.stdout" "$sandbox/original-b.stdout"
cp "$sandbox/logs/a/evidence.stdout" "$sandbox/original-a.stdout"
cp "$sandbox/logs/local/b/evidence.stdout" "$sandbox/original-local.stdout"
printf 'original B smoke evidence\n' > "$sandbox/logs/b/runtime_smoke.stdout"
cp "$sandbox/logs/b/runtime_smoke.stdout" "$sandbox/original-smoke.stdout"
printf 'original B result matrix\n' > "$sandbox/tests/results.md"
cp "$sandbox/tests/results.md" "$sandbox/original-results.md"
failures=0

if make -s -C "$sandbox" -o build/riscv64/runtime_smoke smoke \
    RUNTIME_SRC=Makefile QEMU="$sandbox/fixtures/smoke_exit7.sh" \
    LOG_DIR=logs/local/b > "$sandbox/exit7.log" 2>&1; then
    echo 'FAIL: smoke accepted expected stdout with exit code 7'
    failures=$((failures + 1))
else
    grep -qx 'exit=7' "$sandbox/logs/local/b/runtime_smoke.exit"
    echo 'PASS: smoke rejects a nonzero program exit'
fi

if make -s -C "$sandbox" -o build/riscv64/runtime_smoke smoke \
    RUNTIME_SRC=Makefile QEMU="$sandbox/fixtures/smoke_wrong.sh" \
    LOG_DIR=logs/local/b > "$sandbox/wrong-output.log" 2>&1; then
    echo 'FAIL: smoke accepted wrong stdout with exit code 0'
    failures=$((failures + 1))
else
    echo 'PASS: smoke rejects incorrect stdout'
fi

if make -s -C "$sandbox" -o build/riscv64/runtime_smoke smoke \
    RUNTIME_SRC=Makefile QEMU="$sandbox/fixtures/smoke_ok.sh" \
    LOG_DIR=logs/local/b > "$sandbox/success.log" 2>&1; then
    grep -qx 'exit=0' "$sandbox/logs/local/b/runtime_smoke.exit"
    cmp "$sandbox/tests/expected/smoke.stdout" "$sandbox/logs/local/b/runtime_smoke.stdout"
    echo 'PASS: smoke accepts correct stdout and exit code 0'
else
    echo 'FAIL: smoke rejected correct stdout and exit code 0'
    failures=$((failures + 1))
fi

# Require a newly generated default stdout, not a prior explicit-directory run.
rm -f -- "$sandbox/logs/local/b/runtime_smoke.stdout"
if make -s -C "$sandbox" -o build/riscv64/runtime_smoke smoke \
    RUNTIME_SRC=Makefile QEMU="$sandbox/fixtures/smoke_ok.sh" \
    > "$sandbox/default-output.log" 2>&1 \
    && cmp -s "$sandbox/original-smoke.stdout" "$sandbox/logs/b/runtime_smoke.stdout" \
    && cmp -s "$sandbox/tests/expected/smoke.stdout" "$sandbox/logs/local/b/runtime_smoke.stdout"; then
    echo 'PASS: default smoke output preserves original B evidence'
else
    echo 'FAIL: default smoke output overwrote original B evidence'
    failures=$((failures + 1))
fi

touch "$sandbox/build/riscv64/fact_source" \
    "$sandbox/build/riscv64/fact_hand_ir" "$sandbox/build/riscv64/fact_hand_asm"
chmod +x "$sandbox/build/riscv64/"*
cp "$repo/tests/run_rv64_tests.sh" "$sandbox/tests/run_rv64_tests.sh"
if make -s -C "$sandbox" -o check-tools -o build/riscv64/runtime_smoke \
    -o build/riscv64/fact_source -o build/riscv64/fact_hand_ir \
    -o build/riscv64/fact_hand_asm test RUNTIME_SRC=Makefile \
    QEMU="$sandbox/fixtures/qemu_factorial_cases.sh" \
    LOG_DIR=logs/local/custom RESULT_FILE=logs/local/custom/matrix.md \
    > "$sandbox/custom-output.log" 2>&1 \
    && test -f "$sandbox/logs/local/custom/matrix.md" \
    && test -f "$sandbox/logs/local/custom/fact_hand_asm_12.stdout" \
    && cmp -s "$sandbox/original-results.md" "$sandbox/tests/results.md" \
    && cmp -s "$sandbox/original-smoke.stdout" "$sandbox/logs/b/runtime_smoke.stdout"; then
    echo 'PASS: make test forwards output locations and preserves original results'
else
    echo 'FAIL: make test ignored output locations or overwrote original results'
    failures=$((failures + 1))
fi

# clean runs only under the mktemp fixture, never under the caller's project.
make -s -C "$sandbox" clean > "$sandbox/clean.log" 2>&1
if cmp -s "$sandbox/original-b.stdout" "$sandbox/logs/b/evidence.stdout" \
    && cmp -s "$sandbox/original-a.stdout" "$sandbox/logs/a/evidence.stdout" \
    && cmp -s "$sandbox/original-local.stdout" "$sandbox/logs/local/b/evidence.stdout" \
    && test ! -e "$sandbox/build/riscv64" \
    && test ! -e "$sandbox/build/runtime"; then
    echo 'PASS: clean removes build products and preserves all evidence'
else
    echo 'FAIL: clean removed evidence or left build products behind'
    failures=$((failures + 1))
fi
printf 'regression failures=%s; retained fixture=%s\n' "$failures" "$sandbox"
test "$failures" -eq 0
