# Neovim Config Presentation (45 min)
## A Story of How I Work

---

## 0. The Leader Key (2 min)
- **What is it?** - A prefix key that creates a namespace for custom shortcuts
- **Your leader**: `Space` - easy to reach, works in all modes
- **Your localleader**: `\` - buffer/filetype-specific commands
- **Why it matters** - Keeps shortcuts memorable: `<leader>s` (save) vs memorizing random keys
- **Examples**:
  - `<leader>s` - save all | `<leader>S` - save current
  - `<leader>q` - quit | `<leader>Q` - quit all
  - `<leader>r` - search & replace
  - `<localleader>e` - edit config

---

## Act I: Opening Files & Understanding Modes (7 min)

### Why Neovim/Vim?
- **Speed** - hands stay on home row, no mouse
- **Composability** - verbs + modifiers + objects = infinite commands
- **Ubiquity** - vim keybindings everywhere (IDEs, browsers, shell)
- **Customizability** - your editor grows with you

### Lir - File Browser
You need to open a file first. Enter Lir.
- `-` - open file browser at current directory
- `Enter` - open file
- `a` - new file | `A` - new folder
- `r` - rename | `d` - delete
- `c` / `x` / `p` - copy / cut / paste
- `J` - mark multiple files for batch operations

### Modal Editing
You opened a file. Now why can't you type?

Neovim is a **modal editor** - keys behave differently depending on mode.

**Normal Mode** (default) - for navigation and commands
- Every key is a command: `w`, `b`, `dd`, `yy`
- Press `i` to enter Insert mode

**Insert Mode** - for typing text
- Keys type literally like any other editor
- Press `<Esc>` or `<C-c>` to return to Normal mode
- **Pro tip**: `<C-[>` is easier on your hands than reaching for `<Esc>`

**Why modes?**
- Most time is spent reading/navigating, not typing
- Commands don't require modifiers (no Ctrl+C, Ctrl+V)
- One keypress = one action (e.g., `d` not `<Del>`)

**Other modes** (brief mention):
- Visual mode (`v`) - select text
- Command mode (`:`) - ex commands

---

## Act II: Moving Through Text (8 min)

Now you have a file open. How do you move around?

### Anatomy of Text
- `w` - word forward | `W` - WORD forward (whitespace-delimited)
- `b` / `B` - word/WORD backward
- `e` - end of word
- `p` - paragraph
- Your config: `H` = `^` (line start), `L` = `$` (line end)

### Jumplist
- `<C-o>` / `<C-i>` - jump back/forward through your trail
- Your config: `<C-o>` + `zzzv` (recenter on jump)

---

## Act III: Editing Text (10 min)

You've arrived. Now make changes.

### Anatomy of Action
- `y` - yank (copy) | `yy`, `yw`, `y$`
- `c` - change (delete + insert) | `cw`, `ci"`, `ct,`
- `d` - delete | `dd`, `dw`, `d$`
- `.` - repeat last change (the most powerful key)

### Motion + Range (i/a)
- `i` - inside | `a` - around
- `ciw` - change inside word
- `ci"` - change inside quotes
- `ci(` - change inside parentheses
- `cit` - change inside tag
- `daw` - delete around word

### Text Objects
- Built-in: `w` word, `s` sentence, `p` paragraph, brackets
- Your plugins: `ae` entire file, `ii` indent block, `il` line, `iu` URL
  - `cae` - change entire file (replace all content)
  - `vaf` - visualize around function (select function + signature)
  - `dif` - delete inside function (body only)
- Treesitter hint: `m` for semantic/AST-aware selection

### Replace with Register - `mr*`
- `mriw` - replace inner word with register contents
- `mr$` - replace to end of line
- Black hole register `"_d` - delete without yanking

### Useful Commands
- `J` (your config: ArgWrap) / `M` (join lines)
- `gJ` / `gS` - splitjoin (toggle between one-liner and multiline)
- `:s/old/new/g` - substitution
- `<leader>r` - interactive search & replace word under cursor

---

## Act IV: Finding Things (5 min)

You need to find files, text, symbols across your project.

### Find Files
- `<C-p>` / `<leader>p` - Telescope find_files

### Find Text
- `<leader>/` - live grep (Telescope)
- `<C-g>/` - live grep with args
- `*` / `#` - search word under cursor (forward/backward)

### Find Symbols (LSP)
- `<localleader>wd` - workspace symbols
- `<localleader>ww` - document symbols

### Quickfix Workflow (Batch Operations)
1. Search with Telescope
2. `<Tab>` to select multiple files
3. `<C-q>` send to quickfix list
4. `:cfdo %s/old/new/g` - run command across all selected files

---

## Act V: Code Intelligence (7 min)

Now you're editing intelligently with LSP.

### Navigation
- `gd` - go to definition
- `gD` - go to declaration
- `<C-o>` - jump back

### Information
- `K` - hover documentation
- `<C-k>` - signature help (in insert mode)

### Refactoring
- `<leader>rn` - rename symbol
- `<leader>ca` - code actions

### Diagnostics
- `[e` / `]e` - next/previous error
- `<leader>e` - all diagnostics in loclist
- Metals (Scala): `<localleader>a` - open all diagnostics

### Goto Preview
- Preview definitions in floating windows without losing context

---

## Act VI: Git Workflow (5 min)

Your changes need to be committed.

### Gitsigns - Inline
- `]c` / `[c` - next/previous hunk
- `<leader>hp` - preview hunk
- `<leader>hs` - stage hunk
- `<leader>hS` - stage entire buffer
- `<leader>hb` - blame line
- `<leader>tb` - toggle inline blame

### Fugitive - Full Git
- `<C-g>s` - Git status
- `<C-g>b` - Git blame
- `<C-g>d` - Gvdiffsplit (diff in split)
- `<C-g>P` - push | `<C-g>L` - pull

### Lazygit
- `<leader>gl` - full Lazygit interface (terminal UI)

---

## Act VII: Window Management (3 min)

You're juggling multiple files and views.

### Splits
- `<C-w>s` - horizontal split
- `<C-w>v` - vertical split

### Navigation
- `<C-w>h/j/k/l` - move between windows
- Your config: `<leader><arrow>` - same thing

### Resizing
- Arrow keys - resize current window

### Management
- `<leader>o` - only (close all other windows)
- `<C-Enter>` - maximize current window

---

## Encore: Bonus Tricks (if time permits)

- **Surround**: `ysiw"` - surround word with quotes, `ds"` - delete surround
- **Comment**: `gcc` - toggle line comment, `gb` - block comment
- **Pounce**: `gs` - fuzzy jump (like EasyMotion)
- **Spectre**: `<leader>S` - project-wide search & replace UI
- **Snippets**: `<C-k>` / `<C-j>` - navigate snippet placeholders
- **Terminal**: `<C-\>` toggle floating, `<leader>T` horizontal terminal
