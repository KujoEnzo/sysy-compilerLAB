RISCV_PREFIX ?= riscv64-linux-gnu-
CC           := $(RISCV_PREFIX)gcc
AR           := $(RISCV_PREFIX)ar
OBJDUMP      := $(RISCV_PREFIX)objdump
READELF      := $(RISCV_PREFIX)readelf
NM           := $(RISCV_PREFIX)nm
LLVM_AS      ?= llvm-as-15
OPT          ?= opt-15
LLC          ?= llc-15
QEMU         ?= qemu-riscv64

ARCH_FLAGS   := -march=rv64gc -mabi=lp64d
CFLAGS       := $(ARCH_FLAGS) -mcmodel=medany -O0
LDFLAGS      := $(ARCH_FLAGS) -static

BUILD_DIR    := build/riscv64
RUNTIME_DIR  := build/runtime
LOG_DIR      ?= logs/local/b
RESULT_FILE  ?= $(LOG_DIR)/results.md
RUNTIME_SRC  ?= vendor/lib/sylib.c
RUNTIME_OBJ  := $(RUNTIME_DIR)/sylib_rv64_linux.o
RUNTIME_LIB  := $(RUNTIME_DIR)/libsysy_rv64_linux.a

SMOKE_EXE    := $(BUILD_DIR)/runtime_smoke
SOURCE_EXE   := $(BUILD_DIR)/fact_source
IR_EXE       := $(BUILD_DIR)/fact_hand_ir
ASM_EXE      := $(BUILD_DIR)/fact_hand_asm

.PHONY: all check-tools check-runtime environment runtime smoke source ir asm test inspect clean

all: check-tools smoke source ir asm

check-tools:
	@command -v $(CC) >/dev/null || { echo "missing: $(CC)" >&2; exit 1; }
	@command -v $(AR) >/dev/null || { echo "missing: $(AR)" >&2; exit 1; }
	@command -v $(LLVM_AS) >/dev/null || { echo "missing: $(LLVM_AS)" >&2; exit 1; }
	@command -v $(OPT) >/dev/null || { echo "missing: $(OPT)" >&2; exit 1; }
	@command -v $(LLC) >/dev/null || { echo "missing: $(LLC)" >&2; exit 1; }
	@command -v $(QEMU) >/dev/null || { echo "missing: $(QEMU)" >&2; exit 1; }

check-runtime:
	@test -f "$(RUNTIME_SRC)" || { \
		echo "missing: $(RUNTIME_SRC)" >&2; \
		echo "extract the teacher-provided lib.tar.gz into vendor/ first" >&2; \
		exit 1; \
	}

environment: check-tools | $(LOG_DIR)
	@{ \
		echo "date=$$(date -Is)"; \
		uname -a; \
		df -h /; \
		$(CC) --version | sed -n '1p'; \
		$(LLVM_AS) --version | sed -n '1p'; \
		$(OPT) --version | sed -n '1p'; \
		$(LLC) --version | sed -n '1p'; \
		$(QEMU) --version | sed -n '1p'; \
	} > $(LOG_DIR)/environment.txt

$(BUILD_DIR) $(RUNTIME_DIR) $(LOG_DIR):
	mkdir -p $@

$(RUNTIME_OBJ): $(RUNTIME_SRC) | $(RUNTIME_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(RUNTIME_LIB): $(RUNTIME_OBJ)
	$(AR) rcs $@ $<

runtime: check-runtime $(RUNTIME_LIB)

$(BUILD_DIR)/runtime_smoke.o: src/runtime_smoke.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(SMOKE_EXE): $(BUILD_DIR)/runtime_smoke.o $(RUNTIME_LIB)
	$(CC) $(LDFLAGS) $^ -o $@

smoke: check-runtime $(SMOKE_EXE) | $(LOG_DIR)
	@printf '42\n' | $(QEMU) ./$(SMOKE_EXE) > $(LOG_DIR)/runtime_smoke.stdout 2> $(LOG_DIR)/runtime_smoke.stderr; \
	status=$$?; printf 'exit=%s\n' "$$status" > $(LOG_DIR)/runtime_smoke.exit; \
	test "$$status" -eq 0 || exit "$$status"; \
	diff -u tests/expected/smoke.stdout $(LOG_DIR)/runtime_smoke.stdout

$(BUILD_DIR)/fact_source.o: src/fact_sysy.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(SOURCE_EXE): $(BUILD_DIR)/fact_source.o $(RUNTIME_LIB)
	$(CC) $(LDFLAGS) $^ -o $@

source: check-runtime $(SOURCE_EXE)

$(BUILD_DIR)/fact_hand.bc: ir/fact_hand.ll | $(BUILD_DIR)
	$(LLVM_AS) $< -o $@
	$(OPT) -passes=verify -disable-output $@

$(BUILD_DIR)/fact_hand_ir.s: ir/fact_hand.ll $(BUILD_DIR)/fact_hand.bc | $(BUILD_DIR)
	$(LLC) -mtriple=riscv64-unknown-linux-gnu \
		-mattr=+m,+a,+f,+d,+c -target-abi=lp64d $< -o $@

$(BUILD_DIR)/fact_hand_ir.o: $(BUILD_DIR)/fact_hand_ir.s
	$(CC) $(CFLAGS) -c $< -o $@

$(IR_EXE): $(BUILD_DIR)/fact_hand_ir.o $(RUNTIME_LIB)
	$(CC) $(LDFLAGS) $^ -o $@

ir: check-runtime $(IR_EXE)

$(BUILD_DIR)/fact_hand_asm.o: asm/fact_hand.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(ASM_EXE): $(BUILD_DIR)/fact_hand_asm.o $(RUNTIME_LIB)
	$(CC) $(LDFLAGS) $^ -o $@

asm: check-runtime $(ASM_EXE)

test: all | $(LOG_DIR)
	QEMU="$(QEMU)" LOG_DIR="$(LOG_DIR)" RESULT_FILE="$(RESULT_FILE)" \
		sh tests/run_rv64_tests.sh \
		$(SOURCE_EXE) $(IR_EXE) $(ASM_EXE)

inspect: all environment | $(LOG_DIR)
	file $(SMOKE_EXE) $(SOURCE_EXE) $(IR_EXE) $(ASM_EXE) > $(LOG_DIR)/file-types.txt
	$(READELF) -h $(ASM_EXE) > $(LOG_DIR)/fact_hand_asm.readelf.txt
	$(NM) -u $(RUNTIME_LIB) > $(LOG_DIR)/runtime-undefined-symbols.txt
	$(OBJDUMP) -dr $(BUILD_DIR)/fact_hand_asm.o > $(LOG_DIR)/fact_hand_asm.object-disassembly.txt
	$(OBJDUMP) -d $(ASM_EXE) > $(LOG_DIR)/fact_hand_asm.linked-disassembly.txt
	@if test -f vendor/lib/libsysy_riscv.a; then \
		$(READELF) -h vendor/lib/libsysy_riscv.a > $(LOG_DIR)/teacher-runtime.readelf.txt; \
		$(NM) -u vendor/lib/libsysy_riscv.a > $(LOG_DIR)/teacher-runtime.undefined-symbols.txt; \
	fi

clean:
	rm -rf -- "$(BUILD_DIR)" "$(RUNTIME_DIR)"
