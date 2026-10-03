# GPX Language Specification
**Name:** GPX (Guided Programming eXperience)  
**Version:** 0.2-draft  
**Status:** Working Specification  
**Architecture:** Target-Agnostic Frontend & IR -> Pluggable Multi-Backend (x86-64, ARM64, RISC-V, WebAssembly, C/LLVM)

---

## 1. Overview & Design Goals

**GPX (Guided Programming eXperience)** is a modern, statically-typed, imperative systems programming language designed to combine high-level syntactic clarity with low-level systems control. It follows a clean modular compiler architecture so that a single codebase can compile to native binaries across architectures, run in WebAssembly sandboxes, or target embedded silicon.

### Core Goals
- **Minimalist & Expressive:** Elegant syntax with zero grammatical ambiguities, friendly to humans and tooling.
- **Portability by Design:** The language semantics and intermediate representation (IR) are strictly target-independent.
- **Pluggable Multi-Backend Architecture:** One single GPX frontend can emit:
  - **x86-64** (Desktop, Cloud servers, Windows/Linux/macOS)
  - **ARM64 / AArch64** (Apple Silicon, Mobile, Raspberry Pi, Graviton)
  - **RISC-V** (Open-source silicon, RV32/RV64, SoC/FPGA)
  - **WebAssembly (Wasm)** (Web browsers, Cloudflare Workers, Node.js)
  - **C / LLVM IR** (Universal bootstrapping & maximum industry interoperability)
- **Zero-Cost Abstractions:** Strict static typing with predictable memory layouts and no hidden runtime overhead.

---

## 2. Lexical Structure

### 2.1 Source Encoding & Whitespace
- Source files are encoded in UTF-8.
- Whitespace consists of spaces, tabs, and newline characters. Whitespace separates tokens but is otherwise ignored, except inside string literals.

### 2.2 Comments
- **Line Comments:** Begin with `//` and extend to the end of the line.
- **Block Comments:** Delimited by `/*` and `*/` (nesting is not permitted in v0.1).

```gpx
// This is a single line comment
/* This is a 
   multi-line comment */
```

### 2.3 Keywords
The following identifiers are reserved keywords:

| Keyword | Description |
| :--- | :--- |
| `let` | Variable declaration |
| `fn` | Function declaration |
| `return` | Return statement |
| `if` | Conditional branch |
| `else` | Alternative branch |
| `while` | Loop statement |
| `true` | Boolean true |
| `false` | Boolean false |

### 2.4 Identifiers
Identifiers name variables, functions, and types.
- **Pattern:** `[a-zA-Z_][a-zA-Z0-9_]*`
- Must not collide with reserved keywords.

### 2.5 Literals
- **Integer Literals:** Sequences of decimal digits `[0-9]+` (e.g., `0`, `42`, `1024`). Hexadecimal (`0x[0-9a-fA-F]+`) will be supported in v0.2.
- **Boolean Literals:** `true` and `false`.
- **String Literals:** Enclosed in double quotes `"..."` (e.g., `"Hello, RISC-V\n"`). Escape sequences: `\n`, `\t`, `\\`, `\"`.
- **Character Literals:** Enclosed in single quotes `'...'` (e.g., `'a'`, `'\n'`).

### 2.6 Operators & Delimiters

| Category | Symbols |
| :--- | :--- |
| **Arithmetic** | `+`, `-`, `*`, `/`, `%` |
| **Assignment** | `=` |
| **Relational** | `==`, `!=`, `<`, `<=`, `>`, `>=` |
| **Logical** | `&&`, `||`, `!` |
| **Punctuation** | `(`, `)`, `{`, `}`, `[`, `]`, `,`, `:`, `;`, `->` |

---

## 3. Type System

GPX is statically and strongly typed, using predictable legacy type nomenclature with zero runtime overhead.

### 3.1 Legacy Primitive Types

| Type | Size | Description & Range |
| :--- | :--- | :--- |
| `bool` | 1 byte | Logical boolean (`true`, `false`) |
| `byte` | 1 byte | 8-bit signed integer (`-128` to `127`) |
| `short` | 2 bytes | 16-bit signed integer (`-32,768` to `32,767`) |
| `int` | 4 bytes | 32-bit signed integer (`-2,147,483,648` to `2,147,483,647`) |
| `long` | 8 bytes | 64-bit signed integer (`-9,223,372,036,854,775,808` to `9,223,372,036,854,775,807`) |
| `char` | 1 byte | 8-bit character literal (e.g. `'A'`, `'\n'`) |
| `float` | 4 bytes | 32-bit single-precision IEEE 754 floating point |
| `double` | 8 bytes | 64-bit double-precision IEEE 754 floating point |
| `string` | Pointer | Immutable string literal (`"..."`) |
| `void` | 0 bytes | Unit / empty return type |

### 3.2 Type Conversions & Numeric Promotion
* **Literal Range Checking:** Integer constants are checked at compile time and can initialize any integer type (`byte`, `short`, `int`, `long`, `char`) provided the value fits within the target type's bounds.
* **Implicit Widening:** Safe widening conversions are performed implicitly:
  $$\text{byte} \longrightarrow \text{short} \longrightarrow \text{int} \longrightarrow \text{long} \longrightarrow \text{float} \longrightarrow \text{double}$$
* **Arithmetic Promotion:** Binary arithmetic (`+`, `-`, `*`, `/`) between mixed numeric types promotes both operands to the higher-ranking type (e.g., `int + double` yields `double`, `byte + short` yields `int`).
* **Integer-Only Operations:** Modulo (`%`) is strictly permitted on integer types and rejected on floating-point operands.

### 3.3 Compound Types (Roadmap)
- **Arrays (`T[N]`):** Contiguous, fixed-size sequence of elements of type `T`.
- **Structs (`struct Name { ... }`):** User-defined record types.
- **Pointers (`*T`):** Direct memory addresses for low-level systems access.

---

## 4. Formal Grammar (EBNF)

```ebnf
Program         ::= TopLevelItem* EOF ;

TopLevelItem    ::= FunctionDecl | VarDecl ;

(* Declarations *)
VarDecl         ::= "let" IDENTIFIER ( ":" Type )? ( "=" Expression )? ";" ;
FunctionDecl    ::= "fn" IDENTIFIER "(" ParamList? ")" ( "->" Type )? Block ;
ParamList       ::= Param ( "," Param )* ;
Param           ::= IDENTIFIER ":" Type ;

Type            ::= "int" | "bool" | "char" | "void" | Type "[" INTEGER "]" ;

(* Statements *)
Statement       ::= VarDecl
                  | AssignStmt
                  | ReturnStmt
                  | IfStmt
                  | WhileStmt
                  | ExprStmt
                  | Block ;

AssignStmt      ::= IDENTIFIER "=" Expression ";" ;
ReturnStmt      ::= "return" Expression? ";" ;
IfStmt          ::= "if" Expression Block ( "else" ( IfStmt | Block ) )? ;
WhileStmt       ::= "while" Expression Block ;
ExprStmt        ::= Expression ";" ;
Block           ::= "{" Statement* "}" ;

(* Expressions & Precedence (Lowest to Highest) *)
Expression      ::= LogicalOr ;
LogicalOr       ::= LogicalAnd ( "||" LogicalAnd )* ;
LogicalAnd      ::= Equality ( "&&" Equality )* ;
Equality        ::= Relational ( ( "==" | "!=" ) Relational )* ;
Relational      ::= Additive ( ( "<" | "<=" | ">" | ">=" ) Additive )* ;
Additive        ::= Multiplicative ( ( "+" | "-" ) Multiplicative )* ;
Multiplicative  ::= Unary ( ( "*" | "/" | "%" ) Unary )* ;
Unary           ::= ( "-" | "!" ) Unary | Primary ;
Primary         ::= INTEGER
                  | STRING
                  | "true"
                  | "false"
                  | IDENTIFIER ( "(" ArgList? ")" )?
                  | "(" Expression ")" ;

ArgList         ::= Expression ( "," Expression )* ;
```

---

## 5. Scoping & Semantic Rules

1. **Lexical Block Scoping:** A block enclosed in `{ ... }` introduces a new scope. Variables declared within inner scopes shadow variables from enclosing scopes.
2. **Declaration Before Use:** Variables and functions must be declared before they are referenced.
3. **Immutability & Types:** 
   - Type inference is allowed if an initializer expression is present (`let x = 10` infers `int`).
   - If an explicit type is given, the initializer expression's type must match exactly.
4. **Function Signatures:** Functions must return the exact type specified by `-> Type`. If `-> Type` is omitted, the return type defaults to `void`.

---

## 6. Architecture & Multi-Backend Code Generation

To ensure GPX can scale internationally and run everywhere (from web browsers to cloud servers and embedded silicon), compilation is split into three decoupled tiers:

```
[ GPX Source ]
      │
      ▼ (Frontend: Lexer, Parser, Semantic Analysis)
[ Abstract Syntax Tree (AST) ]
      │
      ▼ (Lowering)
[ Target-Agnostic 3-Address Code (TAC) IR ]
      │
      ▼ (Target-Independent Optimizations)
[ Optimized IR ]
      ├──────────────────────┬──────────────────────┬──────────────────────┬──────────────────────┐
      ▼                      ▼                      ▼                      ▼                      ▼
  [ x86-64 Backend ]    [ ARM64 Backend ]     [ RISC-V Backend ]     [ WebAssembly ]       [ C / LLVM IR ]
  Windows, Linux,       Apple Silicon,        Embedded, FPGAs,       Browsers, Edge,       Cross-compiler &
  Intel/AMD Servers     Mobile, Graviton      Custom Silicon         Sandboxes             Toolchain interop
```

### 6.1 The Intermediate Representation (IR)
The GPX IR uses **Three-Address Code (TAC)**. Every complex expression is decomposed into simple instructions of the form:
`result = operand1 operator operand2`

Example TAC instructions:
- `t1 = 10`
- `t2 = 20`
- `t3 = t1 + t2`
- `br_if t3, label_true, label_false`
- `call func_name, [arg1, arg2]`
- `ret t3`

Because TAC does not know or care about CPU registers or instruction sets, all optimizations (constant folding, dead-code elimination, algebraic simplification) happen on this IR once, benefiting every single target architecture.

### 6.2 Target Backends & ABI Conventions

| Target | Primary Use Case | Register / Calling Convention | Binary Output Format |
| :--- | :--- | :--- | :--- |
| **x86-64** | Desktops, Windows/Linux PCs, Cloud Servers | System V AMD64 (`rdi`, `rsi`, `rdx`, `rax`) / Microsoft x64 (`rcx`, `rdx`, `r8`, `r9`) | ELF, PE/COFF, Mach-O |
| **ARM64 (AArch64)** | Apple Silicon (M1-M4), Smartphones, Raspberry Pi, AWS Graviton | AAPCS64 (`x0`-`x7` arguments/returns) | Mach-O, ELF |
| **RISC-V (RV32/RV64)** | Custom microcontrollers, FPGA soft-cores, open-source SoC | RISC-V ABI (`a0`-`a7`, `t0`-`t6`, `s0`-`s11`) | Bare-metal ELF, Flat binary |
| **WebAssembly (WASM)** | Native web browsers, cloud workers, microVMs | Stack-based bytecode (`i32`, `i64`, `f32`, `f64`) | `.wasm` binary module |
| **C99 Transpilation** | Universal porting & zero-dependency bootstrapping | Maps directly to standard ANSI C99 code | Portable `.c` source |

### 6.3 Memory & Execution Model
- **Word Size:** Configurable per target (32-bit for RV32/WASM, 64-bit for x86-64/ARM64/RV64).
- **Stack Alignment:** Enforced per target ABI (16-byte aligned on x86-64, ARM64, and RISC-V).
- **Data Sections:**
  - `.text`: Executable machine code instructions.
  - `.rodata`: Immutable string literals and constant tables.
  - `.data` / `.bss`: Global mutable variables and uninitialized memory.
  - Stack / Heap: Local activation records and dynamic memory.

---

## 7. Example Programs

### 7.1 Arithmetic & Variables
```gpx
let a: int = 10;
let b: int = 20;
let c: int = a + b * 2;
```

### 7.2 Functions & Recursion (Fibonacci)
```gpx
fn fib(n: int) -> int {
    if n <= 1 {
        return n;
    }
    return fib(n - 1) + fib(n - 2);
}

fn main() -> int {
    let result: int = fib(10);
    return result;
}
```

### 7.3 Iteration (While Loop)
```gpx
fn main() -> int {
    let count: int = 0;
    let sum: int = 0;
    while count < 10 {
        sum = sum + count;
        count = count + 1;
    }
    return sum;
}
```
