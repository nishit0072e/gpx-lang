# GPX Interactive REPL & Debugger Guide

The **GPX Interactive Shell** (`gpx --repl`) provides an immediate, stateful Read-Eval-Print Loop for the GPX programming language. Designed for both rapid algorithmic prototyping and interactive learning, the REPL features persistent session state, live expression evaluation, audio playback, 2D turtle graphics integration, and real-time step-through memory inspection.

---

## 1. Quick Start

### Launching the REPL

Launch the interactive shell from any terminal:

```powershell
gpx --repl
```

Or via the Python module:

```powershell
python -m compiler.main --repl
```

### Welcome Banner & Interface

```text
================================================================================
          GPX Interactive Shell v0.9.1 (Guided Programming eXperience)
================================================================================
Welcome! Type GPX expressions, declarations, or DSA & sound statements.
Type .help for commands, .vars to view variables, .step <expr> to debug, .exit to quit.

gpx> 
```

---

## 2. REPL Meta Commands

Commands begin with a period (`.`) and execute shell management operations rather than GPX code.

| Command | Shorthand | Description |
| :--- | :--- | :--- |
| `.help` | `.h` | Displays the help menu and quick examples |
| `.vars` | `.v` | Lists all active variables, values, and runtime types |
| `.funcs` | `.f` | Lists all user-defined functions registered in the session |
| `.mem`, `.heap` | | Inspects active heap blocks, byte allocations, and freed status |
| `.step <expr>` | | Launches the Real-Time Memory & Instruction Debugger on an expression |
| `.ir` | | Displays Three-Address Code (TAC) IR generated for the last command |
| `.ast` | | Displays the parsed Abstract Syntax Tree for the last command |
| `.load <file.gpx>`| | Loads, compiles, and registers a `.gpx` source file into the session |
| `.clear` | | Clears the terminal screen |
| `.reset` | | Resets session variables, functions, and heap to a clean state |
| `.exit`, `.quit` | `.q` | Exits the interactive shell |

---

## 3. Core Features & Syntax

### 3.1 Direct Expression Evaluation

Expressions entered into the prompt are evaluated immediately and printed with their evaluated value and type tag:

```gpx
gpx> 40 + 2
=> 42 [int]

gpx> 12.5 * 2.0
=> 25.0 [double]

gpx> "Hello, " + "GPX!"
=> "Hello, GPX!" [string]

gpx> 10 > 5 && 3 <= 8
=> true [bool]
```

### 3.2 Variable Declarations & State Persistence

Variables declared with `let` or `const` persist across REPL inputs:

```gpx
gpx> let a = 12.5
a declared.

gpx> a
=> 12.5 [double]

gpx> let b = a * 2.0
b declared.

gpx> print(b)
25.0
```

To view all defined variables, use `.vars`:

```gpx
gpx> .vars

=== SESSION VARIABLES ===
  a = 12.5  [float]
  b = 25.0  [float]
```

### 3.3 Built-in Runtime Type Reflection (`type` / `typeof`)

Inspect the runtime type of any variable or expression using the built-in `type()` or `typeof()` functions:

```gpx
gpx> let x = 42
x declared.

gpx> type(x)
=> "int" [string]

gpx> let msg = "GPX Systems Language"
msg declared.

gpx> type(msg)
=> "string" [string]

gpx> type(12.5)
=> "float" [string]
```

### 3.4 Semicolon Flexibility

GPX enforces semicolons in compiled source files for structural clarity. However, the REPL supports ergonomics for interactive typing:
- Semicolons are optional for expressions (e.g., `a + 10`).
- Semicolons immediately preceding a closing brace `}` are optional (e.g., `{return a}`).

```gpx
gpx> fn square(x: int) -> int { return x * x }
[Registered: square]

gpx> square(9)
=> 81 [int]
```

### 3.5 Multiline Function & Block Input

When an opening brace `{` is left unclosed, the REPL automatically enters multiline mode (`... `) until all braces are balanced:

```gpx
gpx> fn fib(n: int) -> int {
...      if (n <= 1) {
...          return n;
...      }
...      return fib(n - 1) + fib(n - 2);
...  }
[Registered: fib]

gpx> fib(10)
=> 55 [int]
```

### 3.6 Standard Library Headers (`#include`)

Include any GPX standard library header at any point in your session:

```gpx
gpx> #include <io.gpx>
[Included library]

gpx> #include <sound.gpx>
[Included library]

gpx> #include <list.gpx>
[Included library]
```

---

## 4. Interactive Sound & Audio Synthesizer

Because the GPX REPL runs inside the Three-Address Code Virtual Machine with direct hardware bindings, audio commands play instantly through your speakers.

### 4.1 Preset Sound Effects (SFX)

Trigger 8-bit retro gaming sound effects with a single command:

```gpx
gpx> #include <sound.gpx>
[Included library]

gpx> sound_sfx_coin();
[Action: 987 Hz -> 1318 Hz coin tone plays]

gpx> sound_sfx_laser();
[Action: Pitch sweep downward laser plays]

gpx> sound_sfx_jump();
[Action: Pitch sweep upward jump plays]

gpx> sound_sfx_powerup();
[Action: Multi-frequency arpeggio plays]

gpx> sound_sfx_gameover();
[Action: Descending minor chromatic sequence plays]
```

### 4.2 Musical Melodies & Note Synthesizer

Play note frequencies directly using standard musical pitch notation:

```gpx
gpx> sound_play_note("C4", 250);
gpx> sound_play_note("E4", 250);
gpx> sound_play_note("G4", 250);
gpx> sound_play_note("C5", 500);
```

### 4.3 Raw Waveform Synthesis & WAV Export

Synthesize custom square, sine, triangle, sawtooth, and noise waveforms and export them directly to `.wav` audio files:

```gpx
gpx> sound_export_sfx("my_coin.wav", SOUND_SFX_COIN);
=> 1 [int]
```

---

## 5. DSA & OOP in the REPL

### 5.1 Dynamic Data Structures (`<list.gpx>`)

Experiment with dynamic arrays interactively:

```gpx
gpx> #include <list.gpx>
[Included library]

gpx> let list = list_create();
list declared.

gpx> list.push(10);
gpx> list.push(20);
gpx> list.push(30);

gpx> list.len
=> 3 [int]

gpx> list.get(1)
=> 20 [int]

gpx> list.pop()
=> 30 [int]
```

### 5.2 Structs and Object-Oriented Methods

Define structures and attach methods using the Go-style receiver syntax:

```gpx
gpx> struct Counter { val: int }
[Registered: Counter]

gpx> fn (c: *Counter) increment(delta: int) { c->val = c->val + delta; }
[Registered: increment]

gpx> let my_c = Counter { val: 100 };
my_c declared.

gpx> my_c.increment(50);
gpx> my_c.val
=> 150 [int]
```

---

## 6. Real-Time Memory & Instruction Debugger (`.step`)

The GPX REPL includes a step-through debugger with **time-travel rewinding** and **heap allocation inspection**.

### 6.1 Stepping into an Expression

Launch the debugger on any expression or block using `.step`:

```gpx
gpx> #include <memory.gpx>
[Included library]

gpx> .step let p = malloc(32);
```

The terminal opens the interactive inspector:

```text
================================================================================
          GPX REAL-TIME MEMORY & INSTRUCTION INSPECTOR
================================================================================
Function: main | IP: 1 / 4 | Cycles: 1
Instruction: [AllocIR] t0 = malloc 32

--- REGISTERS / ENVIRONMENT ---
  t0: <HeapPointer #1+0>

--- ACTIVE HEAP BLOCKS (1 total, 32 bytes) ---
  Block #01: 32B | Status: ACTIVE | Data: [0, 0, 0, 0, 0, 0, 0, 0]

--- UPCOMING TAC INSTRUCTIONS ---
  -> 0001: t0 = malloc 32
     0002: p = t0
     0003: return 0

Debugger: [n]ext, [s]tep, [b]ack, [c]ont, [r]egs, [m]em, [k]stack, [q]uit
dbg> 
```

### 6.2 Debugger Commands

| Key | Command | Description |
| :---: | :--- | :--- |
| `n` | Next Step | Executes the current TAC instruction and advances |
| `s` | Step In | Steps into the function call |
| `b` | Step Backward | **Time-travel rewinds** to the preceding execution snapshot |
| `c` | Continue | Runs all remaining instructions to completion |
| `r` | Registers | Displays active local variables and TAC temporaries |
| `m` | Memory / Heap | Dumps full heap block states, offsets, and data buffers |
| `k` | Call Stack | Displays the active call stack frames |
| `q` | Quit | Exits the debugger and returns to the `gpx>` prompt |

---

## 7. Inspecting TAC IR and AST

Inspect compiler intermediate structures for any line executed in the REPL:

### 7.1 View TAC Intermediate Representation (`.ir`)

```gpx
gpx> let total = (10 + 20) * 3
total declared.

gpx> .ir

=== TAC IR OF LAST EVALUATION ===
function gpx_anon_run():
    t0 = 10 + 20
    t1 = t0 * 3
    total = t1
    return 0
```

### 7.2 View Abstract Syntax Tree (`.ast`)

```gpx
gpx> .ast

=== AST OF LAST EVALUATION ===
Program(
FnDecl(gpx_anon_run() -> int Block([
  VarDecl(total: None = BinaryOp(*
    BinaryOp(+
      Integer(10),
      Integer(20)
    ),
    Integer(3)
  )),
  Return(Integer(0))
]))
)
```

---

## 8. Loading External Files (`.load`)

Load complete `.gpx` source programs directly into your interactive session:

```gpx
gpx> .load examples/24_oop_bank_account.gpx
[OK] Loaded and evaluated 24_oop_bank_account.gpx

gpx> .funcs

=== REGISTERED FUNCTIONS ===
  fn account_create(id, initial_balance)
  fn deposit(acc, amount)
  fn print_summary(acc)
  fn withdraw(acc, amount)
```

Now all functions and structs defined in the file can be called and inspected interactively!

---

## 9. Summary & Cheat Sheet

```text
Launch:
  gpx --repl

Key Commands:
  .vars               List session variables and types
  .funcs              List registered functions
  .mem                Inspect heap memory blocks
  .step <expr>        Step into memory debugger
  .ir                 Show generated TAC IR
  .ast                Show syntax tree
  .load <file.gpx>    Load file into session
  .reset              Clear all state
  .exit               Quit shell

Special Features:
  type(x)             Inspect runtime type ("int", "float", "string", etc.)
  sound_sfx_*()       Play immediate sound effects
  { ... }             Multi-line automatic indentation
```
