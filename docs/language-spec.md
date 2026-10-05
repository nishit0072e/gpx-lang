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
| `while` | While loop statement |
| `do` | Do-while loop statement |
| `for` | For loop / For-each statement |
| `in` | Range iterator keyword |
| `struct` | Structure composite type declaration |
| `union` | Union shared-memory type declaration |
| `true` | Boolean true |
| `false` | Boolean false |
| `null` | Null pointer constant |

### 2.4 Identifiers
Identifiers name variables, functions, and types.
- **Pattern:** `[a-zA-Z_][a-zA-Z0-9_]*`
- Must not collide with reserved keywords.

### 2.5 Literals
- **Integer Literals:** Sequences of decimal digits `[0-9]+` (e.g., `0`, `42`, `1024`). Optional `l` or `L` suffix specifies a 64-bit `long`.
- **Floating-Point Literals:** Real numbers in standard decimal or scientific notation:
  - Standard decimal fractions: `3.14`, `10.0`, `.5`, `.125` (leading dot supported).
  - Scientific notation: `1.5e-3`, `2.0E+4`, `1e6`.
  - Type suffixes: `f` or `F` designates a 32-bit single-precision `float` (e.g. `3.14f`, `5f`); `d`, `D`, or no suffix designates a 64-bit `double` (e.g. `2.71828`, `10.5d`).
- **Boolean Literals:** `true` and `false`.
- **Pointer Literal:** `null` (represents a null pointer to any pointer type).
- **Character Literals:** Enclosed in single quotes `'...'` (e.g., `'a'`, `'\n'`, `'\x41'`).
- **String Literals:** Enclosed in double quotes `"..."` (e.g., `"Hello, GPX\n"`).

### 2.6 Escape Sequences
Both character and string literals support standard C/GPX escape sequences:

| Escape Sequence | Description | Hex / ASCII |
| :--- | :--- | :--- |
| `\n` | Newline (Line Feed) | `0x0A` |
| `\t` | Horizontal Tab | `0x09` |
| `\r` | Carriage Return | `0x0D` |
| `\a` | Alert / Bell | `0x07` |
| `\b` | Backspace | `0x08` |
| `\f` | Form Feed | `0x0C` |
| `\v` | Vertical Tab | `0x0B` |
| `\\` | Literal Backslash | `0x5C` |
| `\'` | Literal Single Quote | `0x27` |
| `\"` | Literal Double Quote | `0x22` |
| `\0` | Null Character | `0x00` |
| `\xHH` | Hexadecimal byte (1 to 2 hex digits, e.g. `\x1b`, `\x41`) | Custom |
| `\ooo` | Octal byte (1 to 3 octal digits, e.g. `\101`) | Custom |

### 2.7 Operators & Delimiters

| Category | Symbols |
| :--- | :--- |
| **Arithmetic** | `+`, `-`, `*`, `/`, `%` |
| **Assignment** | `=` |
| **Pointers & Memory** | `&` (address-of), `*` (dereference), `->` (indirect member access) |
| **Relational** | `==`, `!=`, `<`, `<=`, `>`, `>=` |
| **Logical** | `&&`, `||`, `!` |
| **Member & Range** | `.` (member access), `..` (range delimiter) |
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

### 3.3 Compound Types: Structures & Unions
* **Structures (`struct Name { ... }`):** User-defined composite record types consisting of named fields with heterogeneous types. Stored contiguously in memory with native struct layout semantics.
  ```gpx
  struct Point {
      x: int;
      y: int;
  }
  let p = Point { x: 10, y: 20 };
  p.x = 42;
  ```
* **Unions (`union Name { ... }`):** Shared-memory types where all members share the same memory location, allowing different interpretations of the underlying binary data.
  ```gpx
  union Data {
      i: int;
      f: float;
  }
  let d: Data;
  d.i = 100;
  ```

### 3.4 Pointers & Memory Indirection
GPX features first-class typed pointers for zero-overhead systems programming, low-level hardware control, and high-performance algorithms:
* **Pointer Types (`*T`, `**T`):** Declared by prefixing any type with `*` (e.g. `*int`, `*Point`, `**int`).
* **Address-Of Operator (`&`):** Obtains the memory address of an lvalue (variable, struct field, or dereference).
* **Dereference Operator (`*`):** Reads or writes the value stored at the referenced memory address.
  ```gpx
  let x: int = 42;
  let p: *int = &x;
  *p = 100; // Directly mutates x
  ```
* **Indirect Member Access (`->`):** Accesses and assigns members on struct pointers without cumbersome `(*p).field` syntax:
  ```gpx
  let pt = Point { x: 1, y: 2 };
  let ptr = &pt;
  ptr->x = 50;
  ```
* **Null Literal (`null`):** Represents an empty/zero memory reference. Can be compared against pointers using `==` and `!=`.

### 3.5 Functions, Pass-by-Reference & Recursion
* **Pass-by-Reference:** Passing pointers allows functions to mutate caller state efficiently without copying:
  ```gpx
  fn swap(a: *int, b: *int) {
      let temp = *a;
      *a = *b;
      *b = temp;
  }
  ```
* **Direct Recursion:** Functions can call themselves recursively (e.g., factorial, fibonacci). Each recursive invocation maintains its own activation record / stack frame.
  ```gpx
  fn factorial(n: int) -> int {
      if n <= 1 {
          return 1;
      }
      return n * factorial(n - 1);
  }
  ```
* **Mutual Recursion & Forward References:** Functions can call other functions declared later in the file. The semantic analyzer and backend compilers use multi-pass symbol discovery and forward declarations:
  ```gpx
  fn is_even(n: int) -> bool {
      if n == 0 { return true; }
      return is_odd(n - 1);
  }
  fn is_odd(n: int) -> bool {
      if n == 0 { return false; }
      return is_even(n - 1);
  }
  ```

---

## 4. Formal Grammar (EBNF)

```ebnf
Program         ::= TopLevelItem* EOF ;

TopLevelItem    ::= FunctionDecl | StructDecl | UnionDecl | VarDecl | Statement ;

(* Declarations *)
StructDecl      ::= "struct" IDENTIFIER "{" StructField* "}" ";"? ;
UnionDecl       ::= "union" IDENTIFIER "{" StructField* "}" ";"? ;
StructField     ::= IDENTIFIER ":" Type ( ";" | "," )? ;

VarDecl         ::= "let" IDENTIFIER ( ":" Type )? ( "=" Expression )? ";" ;
FunctionDecl    ::= "fn" IDENTIFIER "(" ParamList? ")" ( ( "->" | ":" ) Type )? Block ;
ParamList       ::= Param ( "," Param )* ;
Param           ::= IDENTIFIER ":" Type ;

Type            ::= "*"? ( "int" | "long" | "byte" | "short" | "float" | "double" 
                  | "bool" | "char" | "string" | "void" | IDENTIFIER ) ;

(* Statements *)
Statement       ::= VarDecl
                  | DerefAssignStmt
                  | IndirectMemberAssignStmt
                  | MemberAssignStmt
                  | AssignStmt
                  | ReturnStmt
                  | IfStmt
                  | WhileStmt
                  | DoWhileStmt
                  | ForStmt
                  | ForEachStmt
                  | ExprStmt
                  | Block ;

DerefAssignStmt ::= "*" Expression "=" Expression ";" ;
IndirectMemberAssignStmt ::= IDENTIFIER "->" IDENTIFIER "=" Expression ";" ;
MemberAssignStmt::= IDENTIFIER "." IDENTIFIER "=" Expression ";" ;
AssignStmt      ::= IDENTIFIER "=" Expression ";" ;
ReturnStmt      ::= "return" Expression? ";" ;
IfStmt          ::= "if" Expression Block ( "else" ( IfStmt | Block ) )? ;
WhileStmt       ::= "while" ( "(" Expression ")" | Expression ) Block ;
DoWhileStmt     ::= "do" Block "while" ( "(" Expression ")" | Expression ) ";" ;
ForStmt         ::= "for" "(" ( VarDecl | AssignStmt )? ";" Expression? ";" ( MemberAssignStmt | AssignStmt | ExprStmt )? ")" Block ;
ForEachStmt     ::= "for" IDENTIFIER "in" Expression ".." Expression Block ;
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
Unary           ::= ( "-" | "!" | "&" | "*" ) Unary | Postfix ;
Postfix         ::= Primary ( ( "." | "->" ) IDENTIFIER )* ;
Primary         ::= INTEGER
                  | FLOAT
                  | CHAR
                  | STRING
                  | "true"
                  | "false"
                  | "null"
                  | StructInitExpr
                  | IDENTIFIER ( "(" ArgList? ")" )?
                  | "(" Expression ")" ;

StructInitExpr  ::= IDENTIFIER "{" FieldInitList? "}" ;
FieldInitList   ::= FieldInit ( ( "," | ";" ) FieldInit )* ( "," | ";" )? ;
FieldInit       ::= IDENTIFIER ":" Expression ;
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

### 7.4 Floating-Point, Escape Sequences & Format Specifiers
GPX provides built-in `printf(fmt, ...)` for formatted output across all backends:

```gpx
fn main() -> int {
    let pi: float = 3.14159f;
    let e: double = 2.718281828459;
    let flag: bool = true;
    let letter: char = 'G';
    let label: string = "Release";

    printf("=== %s %c ===\n", label, letter);
    printf("Pi (2 decimals): %.2f\n", pi);
    printf("Euler's e (4 decimals): %.4f\n", e);
    printf("Boolean flag: %b\n", flag);
    printf("Hexadecimal: 0x%X, Octal: 0%o\n", 255, 64);
    printf("Literal Percent: 100%%\n");
    return 0;
}
```

#### Format Specifiers Reference

| Specifier | Datatype | Example Input | Formatted Output |
| :--- | :--- | :--- | :--- |
| `%d`, `%i` | Signed Integer (`byte`, `short`, `int`, `long`) | `42`, `-10` | `42`, `-10` |
| `%u` | Unsigned Integer | `42` | `42` |
| `%ld` | 64-bit Long Integer | `922337203685477580` | `922337203685477580` |
| `%f` | Floating Point (`float`, `double`) | `3.14159` | `3.141590` |
| `%.Nf` | Float with precision $N$ | `3.14159` (with `%.2f`) | `3.14` |
| `%lf` | Double Precision Float | `2.71828` | `2.718280` |
| `%g`, `%G` | Compact Floating Point | `20000.0` | `20000` |
| `%e`, `%E` | Scientific Notation | `0.0015` | `1.500000e-03` |
| `%c` | Character (`char`) | `'X'` | `X` |
| `%s` | String (`string`) | `"Hello"` | `Hello` |
| `%b` | Boolean (`bool`) | `true`, `false` | `true`, `false` |
| `%x`, `%X` | Hexadecimal (lower / upper) | `255` | `ff`, `FF` |
| `%o` | Octal | `64` | `100` |
| `%%` | Escaped Percent Symbol | N/A | `%` |

### 7.5 Structures, Unions & Advanced Loops
Demonstrating composite records, memory unions, and all loop constructs (`for`, `for..in`, `do-while`, `while`):

```gpx
struct Vector2D {
    x: int;
    y: int;
}

union ValueSlot {
    as_int: int;
    as_float: float;
}

fn main() -> int {
    // Structures
    let v = Vector2D { x: 10, y: 20 };
    v.x = 42;
    printf("Vector: (%d, %d)\n", v.x, v.y);

    // Unions
    let slot: ValueSlot;
    slot.as_int = 100;
    slot.as_float = 3.14159;
    printf("Slot float: %.2f\n", slot.as_float);

    // 1. C-Style For Loop
    for (let i = 0; i < 3; i = i + 1) {
        printf("For loop i = %d\n", i);
    }

    // 2. Range For-Each Loop
    for n in 1..4 {
        printf("For-each n = %d\n", n);
    }

    // 3. Do-While Loop
    let k = 0;
    do {
        k = k + 1;
    } while (k < 3);

    // 4. While Loop
    while (k > 0) {
        k = k - 1;
    }

    return 0;
}
```


