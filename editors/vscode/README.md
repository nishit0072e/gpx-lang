# GPX Language Support for VS Code & Antigravity IDE

Official extension package for **GPX (Guided Programming eXperience)** providing syntax highlighting, brackets & indentation configuration, and code snippets.

---

## Package

- **VSIX Package:** [`gpx-lang-0.3.0.vsix`](gpx-lang-0.3.0.vsix)

---

## Installation

### Method 1: Command Line (CLI)

```bash
# For VS Code:
code --install-extension gpx-lang-0.3.0.vsix

# For Antigravity IDE:
antigravity-ide --install-extension gpx-lang-0.3.0.vsix
```

### Method 2: Graphical Interface (UI)

1. Open **VS Code** or **Antigravity IDE**.
2. Press `Ctrl+Shift+X` (or click the **Extensions** icon on the sidebar).
3. Click the `...` menu (Views and More Actions) in the top-right corner of the Extensions pane.
4. Select **Install from VSIX...**.
5. Select `gpx-lang-0.3.0.vsix` and click **Install**.

---

## Features

- **Rich Syntax Highlighting:** Supports all GPX keywords (`let`, `fn`, `struct`, `union`, `if`, `while`, `for`, `in`, `null`), legacy primitive types (`int`, `float`, `double`, `bool`, etc.), pointer types (`*T`, `**T`), escape sequences, and `printf` format placeholders (`%d`, `%f`, `%p`, etc.).
- **Pointers & Memory Operators:** Highlighting for `&`, `*`, `->`, and range `..`.
- **Code Snippets:** Auto-completion for functions, structs, unions, loops, and printf templates.
