# GPX Language Support for VS Code & Antigravity IDE

Official syntax highlighting, bracket matching, formatting tokens, and productivity snippets for the **GPX (Guided Programming eXperience)** programming language.

## Features

- **Rich Syntax Highlighting**:
  - Full keyword coloring: `let`, `fn`, `struct`, `union`, `if`, `else`, `while`, `do`, `for`, `in`, `return`.
  - Primitive types: `byte`, `short`, `int`, `long`, `float`, `double`, `char`, `string`, `bool`, `void`.
  - Custom Struct and Union types (`Point`, `Vector`, etc.).
  - Numeric literals: Integers, Decimals, Floats (`3.14f`), Scientific (`1.5e-3`), Hex (`0xFF`), Octal (`0o77`), Binary (`0b1010`).
  - Escape sequences in strings & chars (`\n`, `\t`, `\x41`, `\0`, etc.).
  - `printf` format specifiers highlighted inside strings (`%d`, `%f`, `%.2f`, `%s`, `%x`, etc.).
  - Operators: Arithmetic, comparison, logical, member dot (`.`), and range (`..`).
- **Smart Editing & Language Configuration**:
  - Auto-closing pairs for braces, brackets, parentheses, strings, and character literals.
  - Line comment toggle (`Ctrl + /` or `Cmd + /`) with `//`.
  - Block comment support (`/* ... */`).
  - Code folding for functions and brace blocks.
  - Smart automatic indentation after opening braces `{`.
- **Productivity Snippets**:
  - `main` -> Main function template
  - `fn` -> Function declaration
  - `struct` -> Struct declaration
  - `union` -> Union declaration
  - `for` -> 3-part C-style for loop
  - `foreach` -> Range-based for-each loop (`for x in 0..10`)
  - `dowhile` -> Do-While loop
  - `while` -> While loop
  - `if` / `ifelse` -> Conditional branching
  - `printf` / `print` -> Formatted and standard output

## Installation

### Automatic (Antigravity IDE & VS Code)
This extension is installed directly into:
- `%USERPROFILE%\.antigravity\extensions\gpx-lang`
- `%USERPROFILE%\.vscode\extensions\gpx-lang`

Restart the IDE or reload the window (`Ctrl+Shift+P` -> `Developer: Reload Window`), and all `.gpx` files will immediately receive rich syntax highlighting!
