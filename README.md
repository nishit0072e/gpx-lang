# GPX Programming Language

**Author:** Nishit ([@nishit0072e](https://github.com/nishit0072e))  
**Copyright:** (c) 2026 Nishit. All rights reserved.  
**License:** Proprietary & Confidential (See [`LICENSE`](LICENSE))

A modern, high-performance systems programming language designed for bare-metal speed, clean syntax, and multi-architecture compilation (targeting **x86-64**, **ARM64**, **RISC-V**, **WebAssembly**, and **C**).

---

## Architecture Pipeline

```
              GPX Source Code (*.gpx)
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
              │  Target-Free  │  3-address code intermediate representation
              │      IR       │
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │ Optimization  │  constant folding, algebraic simplification, DCE
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

## Installation & Getting Started

### Option 1: Standalone Binary (Recommended)
Download the pre-compiled `gpx.exe` binary directly from the [GitHub Releases](https://github.com/nishit0072e/gpx-lang/releases) page:
1. Download `gpx.exe`.
2. Add the folder containing `gpx.exe` to your system `PATH`.
3. Verify installation:
   ```bash
   gpx --help
   ```

### Option 2: Install via Python Package Wheel
If you have Python 3.10+ installed:
1. Download the release wheel (`gpx_compiler-0.1.0-py3-none-any.whl`) from Releases.
2. Install with pip:
   ```bash
   pip install gpx_compiler-0.1.0-py3-none-any.whl
   ```
3. Run `gpx` directly in your terminal.

---

## Compiler CLI Usage

```bash
# 1. Run program directly in the VM (no binary created)
gpx examples/03_fibonacci.gpx --run

# 2. Compile to a Native Windows Executable (.exe)
gpx examples/03_fibonacci.gpx -o fib.exe
.\fib.exe

# 3. Compile to Executable AND preserve intermediate C code
gpx examples/03_fibonacci.gpx -o fib.exe --save-c

# 4. End-to-end Pipeline Diagnostics & Inspection
gpx examples/03_fibonacci.gpx --inspect

# 5. Emit Bare-Metal RISC-V RV32I Assembly
gpx examples/03_fibonacci.gpx --target riscv --emit

# 6. Type Check without Compiling
gpx examples/03_fibonacci.gpx --check

# 7. View Intermediate Representation (TAC) with Optimizations
gpx examples/01_arithmetic.gpx --ir --opt
```

---

## Repository Structure

```
gpx-lang/
├── docs/
│   ├── language-spec.md       # Formal EBNF grammar, types & memory model
│   ├── cli-guide.md           # CLI commands, flags, and testing guide
│   └── language-comparison.md # Performance & architecture vs C, Rust, Go, Zig
├── examples/
│   ├── 01_arithmetic.gpx      # Arithmetic and variable expressions
│   ├── 02_control_flow.gpx    # Conditionals (if/else) and while loops
│   └── 03_fibonacci.gpx       # Functions and recursion
├── LICENSE                    # Proprietary copyright license
└── README.md                  # Quickstart & documentation
```

---

## Documentation Links

- [`docs/language-spec.md`](docs/language-spec.md): Complete EBNF grammar, types, scoping rules, and memory model.
- [`docs/cli-guide.md`](docs/cli-guide.md): Complete CLI reference, testing, debugging (`--inspect`), and code generation guide.
- [`docs/language-comparison.md`](docs/language-comparison.md): Comparative analysis vs C, Rust, Go, Zig across speed, memory, scaling, and optimizations.

---

## Ownership & Intellectual Property

Copyright (c) 2026 Nishit. All rights reserved.  
All language design, specifications, architecture, and implementations are the proprietary intellectual property of the author. See [`LICENSE`](LICENSE) for terms.
