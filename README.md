```text
              ______________________      ______________________         ______                ______
            ________________________     ________________________        ______              ______
          ______              ______    ______             ______        ______            ______
        ______                         _____               ______         ______        ______
       _____                          _____               ______           ______    ______
      _____          ____________    ________________________               ____________
     _____         ______________   ______________________                 ____________
    _____                 ______   _____                                ______    ______
   _____                 ______   _____                              ______        ______
   ______              ______    _____                            ______            ______
   ________________________     _____                           ______              ______
   ______________________      _____                          ______                ______
```
<p align="center">
  <img src="assets/gpx-logo.svg" alt="GPX Systems Programming Language" width="100%">
</p>

<h1 align="center">GPX — Guided Programming eXperience</h1>

<p align="center">
  <b>A High-Performance, Multi-Backend Compiler with Bare-Metal Speed &amp; Target-Agnostic IR</b><br>
  <i>Engineered by <b><a href="https://github.com/nishit0072e">Nishit (@nishit0072e)</a></b></i>
</p>

<p align="center">
  <a href="https://github.com/nishit0072e/gpx-lang/releases"><img src="https://img.shields.io/github/v/release/nishit0072e/gpx-lang?color=7928ca&label=RELEASE&logo=github&style=for-the-badge" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/LICENSE-PROPRIETARY-0284c7.svg?style=for-the-badge" alt="License"></a>
  <img src="https://img.shields.io/badge/PYTHON-V3.10%2B-2563eb.svg?logo=python&logoColor=white&style=for-the-badge" alt="Python">
  <img src="https://img.shields.io/badge/CLI-NATIVE%20GPX-10b981.svg?style=for-the-badge" alt="CLI">
</p>

<p align="center">
  <a href="docs/language-spec.md"><img src="https://img.shields.io/badge/DOCS-PASSING-06b6d4.svg?style=for-the-badge" alt="Docs"></a>
  <img src="https://img.shields.io/badge/TESTS-28%20PASSING-059669.svg?style=for-the-badge" alt="Tests">
  <img src="https://img.shields.io/badge/TARGETS-RV32I%20%7C%20X86%20%7C%20ARM-d97706.svg?style=for-the-badge" alt="Targets">
  <img src="https://img.shields.io/badge/OPTIMIZER-TAC%20IR-db2777.svg?style=for-the-badge" alt="Optimizer">
  <img src="https://img.shields.io/badge/CODE%20STYLE-PEP8-111827.svg?logo=python&style=for-the-badge" alt="Code Style">
</p>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#the-vision">Vision</a> •
  <a href="#architecture-pipeline">Architecture</a> •
  <a href="#installation--getting-started">Installation</a> •
  <a href="#compiler-cli-usage">CLI Usage</a> •
  <a href="#repository-structure">Project Structure</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#ownership--intellectual-property">License</a>
</p>


<a id="the-vision"></a>
> ### 💡 The Founder's Keynote
> *"Most people look at compilers and see cold, impenetrable black boxes. We looked at them and asked an audacious question: What if compiling code wasn't a chore, but an exhilarating journey of discovery? What if every developer could peek behind the curtain of modern silicon and feel the raw pulse of the machine?*
> 
> *GPX was not born out of a checklist. It was born out of an insatiable obsession with how code comes alive. It stands for the **Guided Programming eXperience** — because the future belongs to builders who dare to master the machine from first principles."*
> 
> — **Nishit (@nishit0072e)**, Creator & Lead Architect

---

## Overview

**GPX (Guided Programming eXperience)** is a modern, statically-typed systems language engineered for those who crave bare-metal speed without losing cognitive clarity. 

Every transformation in GPX — from tokenization and AST parsing to target-agnostic Three-Address Code (TAC) and bare-metal RISC-V assembly — is designed to be introspectable, predictable, and blindingly fast.

### Core Highlights
* 🧭 **The Guided Experience:** Full compiler transparency. Step through tokens (`--tokens`), inspect ASTs (`--ast`), trace intermediate representation (`--ir`), and observe compiler optimization passes (`--opt`) with single-flag simplicity.
* ⚡ **Zero-Overhead Runtime:** No garbage collection pauses, no hidden runtimes, and instant cold startups (~1ms).
* 🛡️ **Strict Static Safety:** Compile-time type checking, lexical block scoping, and explicit type annotations.
* 🧠 **Middle-End Optimization Engine:** Constant folding, algebraic simplification identities ($x \times 0 \rightarrow 0, x + 0 \rightarrow x$), and dead-code elimination (DCE).
* ⚙️ **Pluggable Backends:** Generates optimized C99 (leveraging GCC `-O2` optimizations) and bare-metal RISC-V RV32I assembly.
* 📦 **Tiny Footprint:** Produces compact standalone binaries (~40 KB) without bloated runtimes.

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
Download the pre-compiled standalone `gpx.exe` binary directly from the [GitHub Releases](https://github.com/nishit0072e/gpx-lang/releases) page:
1. Download **`gpx.exe`**.
2. Add the directory containing `gpx.exe` to your system `PATH`.
3. Verify installation:
   ```bash
   gpx --help
   ```

### Option 2: Universal Wheel Package
For machines with Python 3.10+:
```bash
pip install https://github.com/nishit0072e/gpx-lang/releases/download/v0.1.0/gpx_compiler-0.1.0-py3-none-any.whl
```

---

## Compiler CLI Usage

```bash
# 1. Run program directly in the VM (instant execution, zero binary created)
gpx examples/03_fibonacci.gpx --run

# 2. Compile to a Native Windows Executable (.exe)
gpx examples/03_fibonacci.gpx -o fib.exe
.\fib.exe

# 3. Compile to Executable AND preserve intermediate C code
gpx examples/03_fibonacci.gpx -o fib.exe --save-c

# 4. End-to-end Pipeline Diagnostics & Stage Inspection
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
├── assets/
│   └── gpx-logo.svg           # 3D text branding banner
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

## Documentation

* 📖 [`docs/language-spec.md`](docs/language-spec.md): Complete EBNF grammar, types, scoping rules, and memory model.
* 🛠️ [`docs/cli-guide.md`](docs/cli-guide.md): Complete CLI reference, testing, debugging (`--inspect`), and code generation guide.
* ⚖️ [`docs/language-comparison.md`](docs/language-comparison.md): Comprehensive analysis comparing GPX against C, Rust, Go, and Zig across speed, memory, and scaling.

---

## Ownership & Intellectual Property

**Copyright (c) 2026 Nishit. All rights reserved.**  
All language design, specifications, architecture, and implementations are the proprietary intellectual property of the author. See [`LICENSE`](LICENSE) for terms.
