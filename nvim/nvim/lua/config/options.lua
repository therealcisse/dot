-- Leader keys (must be set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- LuaSnip guard (must be set before plugins load)
vim.g.snippets = "luasnip"

-- Disable builtin plugins
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1

-- Plugin globals
vim.g.ts_highlight_lua = false
vim.g.omni_sql_default_compl_type = "syntax"
vim.g.move_key_modifier = "C"
vim.g.move_map_keys = 0
vim.g.SignatureMarkTextHLDynamic = 1
vim.g.WebDevIconsNerdTreeAfterGlyphPadding = ""
vim.g.WebDevIconsNerdTreeGitPluginForceVAlign = 0
vim.g.WebDevIconsOS = "Darwin"
vim.g.sort_motion_flags = "u"
vim.g.floating_window_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
vim.g.floating_window_border_dark = {
  { "╭", "FloatBorderDark" },
  { "─", "FloatBorderDark" },
  { "╮", "FloatBorderDark" },
  { "│", "FloatBorderDark" },
  { "╯", "FloatBorderDark" },
  { "─", "FloatBorderDark" },
  { "╰", "FloatBorderDark" },
  { "│", "FloatBorderDark" },
}

-- FZF
vim.env.FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border --no-preview"
vim.env.FZF_DEFAULT_COMMAND = "fd --type f"

-- General
vim.opt.termguicolors = true
vim.opt.equalalways = false
vim.opt.mouse = "a"
vim.opt.mousemodel = "extend"
vim.opt.mousehide = true
vim.opt.errorbells = false
vim.opt.visualbell = true
vim.opt.hidden = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4
vim.opt.ruler = true
vim.opt.report = 100
vim.opt.display:append("lastline")
vim.opt.startofline = false
vim.opt.joinspaces = false
vim.opt.clipboard = "unnamedplus"
vim.opt.winborder = "rounded"

-- Search
vim.opt.ignorecase = false
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.magic = true
vim.opt.gdefault = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.softtabstop = -1
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.cinwords = "if,elif,else,for,while,try,except,finally,def,class,func,fun,fn,interface,trait"

-- Wrapping and formatting
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:2"
vim.opt.linebreak = true
vim.opt.showbreak = "⤷ "
vim.opt.formatoptions:append("j")
vim.opt.formatoptions:append("n")
vim.opt.formatoptions:append("w")
vim.opt.infercase = true

-- Display
vim.opt.synmaxcol = 512
vim.cmd("syntax sync minlines=1024")
vim.opt.list = true
vim.wo.listchars = table.concat({
  "multispace:---+",
  "leadmultispace:---+",
  "eol:↴",
  "tab:│⋅",
  "trail:•",
  "nbsp:_",
  "space:⋅",
}, ",")
vim.opt.fillchars:append({ eob = " ", vert = "┃" })
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.cursorlineopt = "line,number"
vim.opt.signcolumn = "yes:2"
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.showtabline = 0
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.pumblend = 10

-- Scroll
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Shortmess
vim.opt.shortmess:append("AIOTWaotc")
vim.opt.shortmess:remove("F")

-- Completion
vim.opt.completeopt:remove("preview")
vim.opt.complete:remove("i")

-- Wildmenu
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildcharm = 26 -- <C-z> byte value
vim.opt.wildignore:append("*.swp")

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.winminheight = 0

-- Folds
vim.opt.foldlevel = 99
vim.opt.foldenable = true
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99

-- Diffs
vim.opt.diffopt:append("vertical")

-- Spell
vim.opt.spelllang = "en_us"

-- History and undo
vim.opt.history = 10000

-- Backup/swap/undo
if vim.env.SUDO_USER then
  vim.opt.backup = false
  vim.opt.writebackup = false
  vim.opt.swapfile = false
  vim.opt.undofile = false
else
  vim.opt.backupdir = vim.fn.expand("~/.vim/tmp/backup")
  vim.opt.directory = vim.fn.expand("~/.vim/tmp/swap//")
  vim.opt.undodir = vim.fn.expand("~/.vim/tmp/undo")
  vim.opt.undofile = true
end
vim.opt.backupskip = "/tmp/*,/private/tmp/*"

-- Session/view
vim.opt.viewdir = vim.fn.expand("~/.vim/tmp/view")
vim.opt.viewoptions = "cursor,folds"
vim.opt.sessionoptions = "folds"

-- Virtual edit
vim.opt.virtualedit = "insert,onemore,block"

-- Misc
vim.opt.switchbuf = "usetab"
vim.opt.whichwrap = "b,h,l,s,<,>,[,],~"
vim.opt.shell = "/bin/sh"
vim.opt.suffixesadd:append({ ".js", ".ts", ".json" })
vim.opt.path:append("*/**")
