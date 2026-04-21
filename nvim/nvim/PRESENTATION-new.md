# My Neovim Config

A tour of how I work

---

## 1. Introduction

- What this talk covers: how I navigate, edit, search, and manage code
- Everything runs in the terminal, no mouse
- The config is Lua-based, built on lazy.nvim

---

### Try it: Introduction

1. Start Neovim fresh to see the Snacks dashboard
2. Press `n` to create a new scratch file
3. Close it with `:q`

---

## 2. Configuration Structure

- Lua-based config with lazy.nvim for plugin management
- Modular layout: `init.lua` loads `options`, `keymaps`, `plugins/*`, `lsp/`
- Leader key (`Space`) and localleader (`\`) as the foundation
- Each plugin is a spec in `plugins/`: name, config, keymaps

---

### Leader Key Examples

- `<leader>s` save all
- `<leader>q` quit
- `<leader>r` search and replace
- `<leader>S` save current file
- `<localleader>e` edit config

---

### Try it: Config Structure

1. `<C-p>` -> type `init.lua` -> open it, scroll through the requires
2. `<C-p>` -> type `editor` -> open `plugins/editor.lua` to see a plugin spec
3. Press `<leader>s` (save all)
4. Press `<leader>q` (quit, cancel with `n`)

---

## 3. File Management with Lir 

- `-` opens the file browser at the current file's directory
- Core operations: `Enter` open, `a` new file, `A` new folder
- `r` rename, `d` delete
- Clipboard: `c` copy, `x` cut, `p` paste
- `J` to mark files for batch operations
- Git status shown inline via `lir-git-status`

---

### Try it: Lir

1. Open `Main.scala` then press `-` to open Lir
2. Navigate into `src/` with `Enter`
3. Press `a`, type `Temp.scala`, press `Enter` to create
4. Press `r` on `Temp.scala`, rename to `Scratch.scala`
5. Press `d` on `Scratch.scala` to delete it

---

## 4. File Navigation with Telescope 

- `<C-p>` for fuzzy file finding (ivy theme)
- `<C-g>/` for live grep with args (ripgrep under the hood)
- Inside Telescope:
  - `<Tab>` toggle selection on a result
  - `<C-q>` send selected items to the quickfix list

---

### Try it: Telescope

1. `<C-p>` -> type `User` -> open `User.scala`
2. `<C-g>/` -> type `findUser` -> see results across files
3. In the grep results, `<Tab>` a few entries, then `<C-q>` to send to quickfix

---

## 5. Escape Tip and Ergonomic Remaps

- `<C-[>` is mapped to `<Esc>` in insert mode (closer than reaching for Esc or `<C-c>`)
- **Jumplist**: `<C-o>` jump back, `<C-i>` jump forward
- **`<C-o>` in insert mode**: run one normal mode command without leaving insert

---

### Emacs-style Insert Navigation

- Built on `<C-o>` (readline muscle memory)
- `<C-E>` end of line, `<C-Q>` beginning of line
- `<C-F>` forward char, `<C-B>` backward char
- `<C-D>` delete char under cursor

---

### Try it: Ergonomic Remaps

1. Open `Main.scala`, go to line 9
2. Press `A` to append, type ` // added`, press `<C-[>` to exit insert
3. Press `A` again, then `<C-Q>` to jump to line start, `<C-E>` to jump to end
4. Press `<C-o>dd` to delete the line without leaving insert mode
5. `<C-[>` to exit, then `<C-o>` / `<C-i>` to jump back and forward

---

## 6. Text Objects

- Built-in: `w` word, `s` sentence, `p` paragraph, `"`, `(`, `{`, `t` tag
- Every text object works with every verb: `c`, `d`, `y`, `v`
- `V` selects a full line, `o` in visual mode jumps between ends

---

### Plugin Text Objects

- All via `kana/vim-textobj-user`:
- `ae`/`ie` entire file
- `al`/`il` line
- `ai`/`ii` indent block
- `au`/`iu` URL, word column

---

### Try it: Text Objects

1. Cursor on `calculateTotal` (line 16) -> `ciw` -> type `computeSum`
2. Cursor inside `"Hello, World!"` (line 9) -> `ci"` -> type `Goodbye`
3. Cursor inside `(numbers)` (line 16) -> `ci(` -> type `items`
4. Cursor on indented block (line 20-22) -> `vii`
5. Undo all: `u` until restored

---

## 7. Surround Plugin 

- `ys{motion}{char}` add surround (e.g., `ysiw"` wraps word in quotes)
- `cs{old}{new}` change surround (e.g., `cs"'` changes double to single)
- `ds{char}` delete surround (e.g., `ds(` removes parentheses)
- Works with: `"`, `'`, `` ` ``, `(`, `[`, `{`, `<`, HTML tags

---

### Try it: Surround

1. Open `User.scala`, cursor on `name` (line 4) -> `ysiw"` to wrap in quotes
2. `cs"'` to change double quotes to single
3. `ds'` to remove the quotes entirely
4. Cursor on `String` -> `ysiw(` to add parentheses
5. Undo all: `u` until restored

---

## 8. Replace with Register 

- `mr{motion}` replaces the motion target with register contents
- `mriw` replace inner word
- `mr$` replace to end of line
- `mrip` replace inner paragraph
- Workflow: yank something (`yiw`), move to target, `mriw` to paste over

---

### Try it: Replace with Register

1. Open `UserService.scala`, cursor on `alice` (line 8) -> `yiw` to yank
2. Move cursor to `bob` (line 9) -> `mriw` (replaces `bob` with `alice`)
3. Undo with `u`

---

## 9. Align and Indent 

- `=` is Vim's reindent operator: `==` line, `=ap` paragraph, `=ae` entire file
- `<leader>F` reindents the entire file
- Visual `<leader>F` reindents the selection
- vim-lion: `gl{motion}{char}` aligns around a character
  - `glip=` aligns a paragraph around `=`
- Visual block trick: `<C-v>` select a column, `x` to strip

---

### Try it: Align and Indent

1. Open `Formatter.scala`, cursor on the messy `formatUser` block (lines 8-13)
2. `=ap` to reindent the paragraph
3. Move to the `val` block (lines 16-21) -> `glip=` to align around `=`
4. Undo: `u` until restored

---

## 10. Finding and Replacing Text

- `<C-g>/` live grep across the project (Telescope + ripgrep)
- `*` / `#` search word under cursor (stays in place)
- `<leader>r` interactive search and replace for word under cursor

---

### Quickfix Workflow (the power move)

1. `<C-g>/` to search
2. `<Tab>` to select matching files
3. `<C-q>` to send to quickfix list
4. `:cfdo %s/old/new/g | update` to apply across all files

---

### Try it: Finding and Replacing

1. Open `UserService.scala`, cursor on `findUser` -> press `*` (highlights all)
2. Press `<leader>r`, type `getUser`, confirm a few with `y`
3. Undo all: `u` until restored
4. Full quickfix flow:
   - `<C-g>/` -> type `findUser`
   - `<Tab>` to select results -> `<C-q>`
   - `:cfdo %s/findUser/getUser/g | update`

---

## 11. Gitsigns

- `]c` / `[c` navigate between hunks
- `<leader>hp` preview hunk in floating window
- `<leader>hs` stage hunk, `<leader>hS` stage buffer
- `<leader>hu` undo stage, `<leader>hr` reset hunk

---

### Gitsigns: Blame and Diff

- `<leader>hb` blame line (full commit info)
- `<leader>tb` toggle inline blame
- `<leader>hd` diff this file
- `<leader>td` toggle deleted lines
- `ih` text object for selecting a hunk

---

### Try it: Gitsigns

1. Open `Main.scala` (added line at line 20)
2. `]c` to jump to hunk, `<leader>hp` to preview
3. `<leader>hs` to stage, `<leader>hu` to undo
4. `<leader>tb` to toggle inline blame
5. Open `UserService.scala` -> `]c` to see modified line

---

## 12. LSP with Metals

- Metals for Scala, auto-attaches on FileType
- `gd` definition
- `K` hover docs

---

### LSP: Refactoring and Diagnostics

- `<localleader>rn` rename
- `[e`/`]e` jump between errors, `<leader>e` diagnostic float

---

### Try it: LSP with Metals

1. Cursor on `UserService()` (line 10) -> `gd`, then `<C-o>` back
2. Cursor on `getOrElse` in `UserService.scala` -> `K` for hover
3. Cursor on `calculateTotal` -> `<localleader>rn` to rename
4. `[e` / `]e` to navigate diagnostics
5. Cursor on `findUser` -> `<localleader>gr` for references

---

## 13. Noice Plugin 

- Replaces the native command line with a centered popup

---

### Try it: Noice

1. Type `:set` and watch the popup command line

---

## 14. Closing

- Config lives at `~/dot/nvim/nvim/`
- Questions?
