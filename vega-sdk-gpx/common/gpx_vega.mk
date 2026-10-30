# ============================================================================
# Guided Programming eXperience (GPX) -> VEGA RISC-V Build System
# ============================================================================

# Auto-locate SDK directories relative to this makefile
COMMON_DIR        := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
GPX_SDK           := $(abspath $(COMMON_DIR)/..)
ROOT_DIR          := $(abspath $(GPX_SDK)/..)
VEGA_TOOLS        := $(ROOT_DIR)/vega-tools-windows
VEGA_SDK          := $(ROOT_DIR)/vega-sdk

TOOLCHAIN_BIN     := $(VEGA_TOOLS)/bin
PYTHON            ?= python

# Output Directory (defined early for flags)
BIN               := build

# Cross-platform file/directory operations via Python
MKDIR_P           := $(PYTHON) -c "import os, sys; os.makedirs(sys.argv[1], exist_ok=True)"
RM_RF             := $(PYTHON) -c "import shutil, os, sys; shutil.rmtree(sys.argv[1], ignore_errors=True) if os.path.isdir(sys.argv[1]) else (os.remove(sys.argv[1]) if os.path.exists(sys.argv[1]) else None)"

# Cross Compiler Executables (Use explicit VEGA toolchain)
VEGA_CROSS_PREFIX := $(TOOLCHAIN_BIN)/riscv64-vega-elf-
CC                := $(VEGA_CROSS_PREFIX)gcc
OBJCOPY           := $(VEGA_CROSS_PREFIX)objcopy
OBJDUMP           := $(VEGA_CROSS_PREFIX)objdump
SIZE              := $(VEGA_CROSS_PREFIX)size

# Target Architecture & ABI (THEJAS32 / ARIES Board)
RISCV_ARCH        := rv32im
RISCV_ABI         := ilp32
RISCV_CMODEL      := medany

# Compiler & Linker Flags
CFLAGS            := -march=$(RISCV_ARCH) -mabi=$(RISCV_ABI) -mcmodel=$(RISCV_CMODEL)
CFLAGS            += -I$(VEGA_SDK)/bsp/include
CFLAGS            += -I$(GPX_SDK)/include
CFLAGS            += -fno-builtin-printf -fno-builtin-puts -fdata-sections -ffunction-sections
CFLAGS            += -DBARE_METAL

LDFLAGS           := -nostartfiles -march=$(RISCV_ARCH) -mabi=$(RISCV_ABI) -mcmodel=$(RISCV_CMODEL)
LDFLAGS           += -T $(VEGA_SDK)/bsp/common/mbl.lds
LDFLAGS           += -L$(VEGA_SDK)/bsp
LDFLAGS           += -Wl,--gc-sections
LDFLAGS           += -Wl,-Map,$(BIN)/$(EXECUTABLE_NAME).map

LDLIBS            := -Wl,--start-group -lvega -lc -lgcc -lm -Wl,--end-group

# Target Deliverables
PROGRAM_ELF       := $(BIN)/$(EXECUTABLE_NAME).elf
PROGRAM_BIN       := $(BIN)/$(EXECUTABLE_NAME).bin
PROGRAM_HEX       := $(BIN)/$(EXECUTABLE_NAME).hex
PROGRAM_DUMP      := $(BIN)/$(EXECUTABLE_NAME).dump

# Source Files
GPX_SOURCES       ?= $(wildcard *.gpx)
GEN_C_SOURCES     := $(patsubst %.gpx,$(BIN)/%.c,$(GPX_SOURCES))
OBJECT_FILES      := $(patsubst %.gpx,$(BIN)/%.o,$(GPX_SOURCES))

# Ensure intermediate files are preserved
.PRECIOUS: $(BIN)/%.c $(BIN)/%.o

# Ensure PYTHONPATH points to project root so compiler module resolves
export PYTHONPATH := $(ROOT_DIR)

.PHONY: all clean dump size

all: $(BIN) $(PROGRAM_ELF) $(PROGRAM_BIN) $(PROGRAM_DUMP) $(PROGRAM_HEX) size

$(BIN):
	@$(MKDIR_P) $(BIN)

# Step 1: Compile GPX source into C99 Bare-Metal Translation
$(BIN)/%.c: %.gpx | $(BIN)
	@echo [GPX] Compiling $< to $@
	$(PYTHON) -m compiler.main $< --target c -I $(GPX_SDK)/include -o $@

# Step 2: Compile C into RISC-V Object File
$(BIN)/%.o: $(BIN)/%.c | $(BIN)
	@echo [CC] Compiling $< to $@
	$(CC) $(CFLAGS) -c $< -o $@

# Step 3: Link into Bare-Metal RISC-V ELF
$(PROGRAM_ELF): $(OBJECT_FILES) | $(BIN)
	@echo [LD] Linking $@
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

# Step 4: Extract Raw Binary Firmware
$(PROGRAM_BIN): $(PROGRAM_ELF)
	@echo [OBJCOPY] Generating Raw Binary $@
	$(OBJCOPY) -O binary $< $@

# Step 5: Generate Disassembly Listing
$(PROGRAM_DUMP): $(PROGRAM_ELF)
	@echo [OBJDUMP] Disassembling to $@
	$(OBJDUMP) -d $< > $@

# Step 6: Generate Intel HEX File
$(PROGRAM_HEX): $(PROGRAM_ELF)
	@echo [OBJCOPY] Generating Intel Hex $@
	$(OBJCOPY) -O ihex $< $@

size: $(PROGRAM_ELF)
	@echo === Firmware Memory Footprint ===
	@$(SIZE) $<

clean:
	@$(RM_RF) $(BIN)
	@echo Clean completed.
