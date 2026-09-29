# GPX Compiler CLI Guide & Documentation

This document describes the complete Command Line Interface (CLI) for the GPX compiler, including direct execution, debugging, pipeline inspection, and target code generation.

---

## Command Syntax Overview

```bash
gpx <source_file.gpx> [options]
```

Or using the Python module directly:
```bash
python -m compiler.main <source_file.gpx> [options]
```

---

## 1. Quick Reference Table

| Category | Flag | Description |
| :--- | :--- | :--- |
| **Execution** | `--run` | Directly executes the program in the internal IR VM without creating any disk files |
| **Inspection** | `--inspect` / `--debug` | Runs the full pipeline and displays tokens, AST, raw IR, optimized IR, C code, and RISC-V assembly |
| | `--tokens` | Prints lexical token stream and exits |
| | `--ast` | Prints the parsed Abstract Syntax Tree (AST) hierarchy and exits |
| | `--check` | Performs semantic analysis and type checking without compiling |
| | `--ir` | Prints the Three-Address Code (TAC) intermediate representation |
| | `--opt` | Applies constant folding, algebraic simplifications, and dead-code elimination |
| **Code Generation** | `-o <filename.exe>` | Compiles directly to a native binary using GCC (**no temporary C files left on disk**) |
| | `--save-c` | Preserves the intermediate `.c` source file alongside the `.exe` binary |
| | `--emit-c` | Prints the transpiled C99 code directly to stdout |
| | `-o <filename.c>` | Saves the transpiled C99 code to a file |
| | `--target riscv` | Selects the RISC-V RV32I assembly backend |
| | `--emit-asm` | Prints RISC-V assembly directly to stdout |
| | `-o <filename.s>` | Saves RISC-V assembly to a file |

---

## 2. Execution Modes

### 2.1 Direct VM Execution (`--run`)
Executes the code immediately inside the target-agnostic Three-Address Code Virtual Machine. No intermediate files or external compilers (`gcc`) are required.

```powershell
gpx examples/03_fibonacci.gpx --run
```
**Output:**
```text
[Program returned: 6765]
```

### 2.2 Native Binary Compilation (`-o <name>.exe`)
Translates GPX to C99 and compiles it into a high-performance native Windows executable (`.exe`) via `gcc`.

> [!NOTE]
> By default, intermediate C files are automatically cleaned up in memory/temp storage so your directories remain tidy.

```powershell
# Compile to native binary
gpx examples/03_fibonacci.gpx -o fib.exe

# Run the native binary
.\fib.exe
```
**Output:**
```text
[OK] Native binary compiled successfully -> fib.exe
6765
```

### 2.3 Preserving Generated C Code (`--save-c` or `--emit-c`)
If you want to view, inspect, or keep the generated C code, use either `--save-c`, `--emit-c`, or output to `.c`:

```powershell
# Option A: Compile binary AND preserve the .c file
gpx examples/03_fibonacci.gpx -o fib.exe --save-c

# Option B: Print C code to terminal
gpx examples/03_fibonacci.gpx --emit-c

# Option C: Save only the C source file
gpx examples/03_fibonacci.gpx -o fib.c
```

---

## 3. Debugging & Inspection Flags

### 3.1 Complete Pipeline Inspection (`--inspect` or `--debug`)
Displays the transformation of your code across every single compiler stage in one consolidated view:

```powershell
gpx examples/01_arithmetic.gpx --inspect
```

**Stages Displayed:**
1. **Stage 1 (Tokens):** Scanned token stream with line & column locations.
2. **Stage 2 (AST):** Hierarchical abstract syntax tree showing precedence and expressions.
3. **Stage 3 (Raw TAC IR):** Linear 3-address code prior to optimization.
4. **Stage 4 (Optimized TAC IR):** IR after constant folding, algebraic simplification, and DCE.
5. **Stage 5 (C Code):** Generated C99 source.
6. **Stage 6 (RISC-V Assembly):** Generated bare-metal RV32I assembly.

### 3.2 Individual Inspection Flags

#### Inspect Tokens
```powershell
gpx examples/01_arithmetic.gpx --tokens
```

#### Inspect AST Hierarchy
```powershell
gpx examples/02_control_flow.gpx --ast
```

#### Run Semantic / Type Checking Only
```powershell
gpx examples/03_fibonacci.gpx --check
```

#### Inspect Raw vs Optimized IR
```powershell
# Unoptimized IR
gpx examples/01_arithmetic.gpx --ir

# Optimized IR (constant folded)
gpx examples/01_arithmetic.gpx --ir --opt
```

---

## 4. RISC-V Bare-Metal Target

GPX has built-in code generation for RISC-V (RV32I/RV32IM) architectures:

```powershell
# Print RISC-V assembly to terminal
gpx examples/03_fibonacci.gpx --target riscv --emit

# Save assembly to a .s file
gpx examples/03_fibonacci.gpx --target riscv -o fib.s
```

---

## 5. Testing & Verification

Run the automated test suite covering lexing, parsing, semantic checking, IR generation, VM execution, optimization, and code generation:

```powershell
python -m unittest discover tests
```
