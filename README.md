# GPX Compiler Project

A custom compiler for the **GPX** programming language, written from scratch in Python with a modular, target-agnostic architecture capable of generating code for **x86-64**, **ARM64**, **RISC-V**, **WebAssembly**, and **C**.

---

## Architecture Pipeline

```
              Source Code (*.gpx)
                      │
                      ▼
              ┌───────────────┐
              │     Lexer     │  characters -> tokens
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │    Parser     │  tokens -> AST
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │   Semantic    │  type checking, scopes, symbol table
              │   Analysis    │
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │      IR       │  target-agnostic 3-address code
              │  Generation   │
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │ Optimization  │  constant folding, dead-code elimination
              └───────┬───────┘
                      │
      ┌───────────────┼───────────────┬───────────────┬───────────────┐
      ▼               ▼               ▼               ▼               ▼
┌───────────┐   ┌───────────┐   ┌───────────┐   ┌───────────┐   ┌───────────┐
│  x86-64   │   │   ARM64   │   │  RISC-V   │   │WebAssembly│   │ C99 Emitter
│  Backend  │   │  Backend  │   │  Backend  │   │  Backend  │   │(Universal)│
└─────┬─────┘   └─────┬─────┘   └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
      ▼               ▼               ▼               ▼               ▼
 Windows/Linux    Apple/Mobile     Embedded/      Web Browser/       Any C
   Binaries         Binaries         FPGA           Cloudflare      Compiler
```

---

## Project Structure

```
newLang/
├── docs/
│   └── language-spec.md   # Language specification & EBNF grammar
├── compiler/
│   ├── __init__.py
│   ├── lexer.py           # Tokenizer
│   ├── parser.py          # Recursive descent parser
│   ├── ast_nodes.py       # AST node definitions
│   ├── semantic.py        # Symbol table & type checker
│   ├── ir.py              # Target-agnostic TAC IR representation
│   ├── optimizer.py       # Target-agnostic optimizations
│   ├── backends/          # Pluggable code generation backends
│   │   ├── __init__.py
│   │   ├── codegen_x86_64.py
│   │   ├── codegen_arm64.py
│   │   ├── codegen_riscv.py
│   │   ├── codegen_wasm.py
│   │   └── codegen_c.py
│   └── main.py            # CLI compiler driver (flag: --target)
├── examples/
│   ├── 01_arithmetic.gpx
│   ├── 02_control_flow.gpx
│   └── 03_fibonacci.gpx
├── tests/
└── README.md
```

## Documentation
- [`docs/language-spec.md`](docs/language-spec.md): Complete EBNF grammar, types, scoping rules, and memory model.
- [`docs/cli-guide.md`](docs/cli-guide.md): Complete CLI reference, testing, debugging (`--inspect`), and code generation guide.
- [`docs/language-comparison.md`](docs/language-comparison.md): Comparative analysis vs C, Rust, Go, Zig across speed, memory, scaling, and optimizations.

---

## Compiler CLI Usage

```bash
# 1. Run directly in the VM (no binary created)
gpx examples/03_fibonacci.gpx --run

# 2. Compile to Native Windows Executable (.exe) without leaving temp C files
gpx examples/03_fibonacci.gpx -o fib.exe
.\fib.exe

# 3. Compile to Executable AND preserve intermediate C code
gpx examples/03_fibonacci.gpx -o fib.exe --save-c

# 4. End-to-end Pipeline Inspection (Tokens, AST, Raw IR, Opt IR, C, RISC-V)
gpx examples/03_fibonacci.gpx --inspect

# 5. Emit RISC-V RV32I Bare-Metal Assembly
gpx examples/03_fibonacci.gpx --target riscv --emit

# 6. Type Checking & Semantic Verification
gpx examples/03_fibonacci.gpx --check

# 7. View Optimized Intermediate Representation
gpx examples/01_arithmetic.gpx --ir --opt
```

---

## Running the Automated Test Suite

```bash
python -m unittest discover tests
```
