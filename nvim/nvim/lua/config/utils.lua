local M = {}

-- Zap trailing whitespace (from autoload/mappings/leader.vim)
function M.zap()
  local pos = vim.fn.getcurpos()
  local search = vim.fn.getreg("/")
  vim.cmd([[keepjumps %substitute/\s\+$//e]])
  vim.fn.setreg("/", search)
  vim.cmd("nohlsearch")
  vim.fn.setpos(".", pos)
end

-- Align current paragraph (from autoload/mappings/leader.vim)
function M.align()
  local pos = vim.fn.getcurpos()
  local search = vim.fn.getreg("/")
  vim.cmd("keepjumps normal =ae")
  vim.fn.setreg("/", search)
  vim.cmd("nohlsearch")
  vim.fn.setpos(".", pos)
end

-- Escape pattern for search (from autoload/autocmds.vim)
function M.escape_pattern(str)
  return vim.fn.escape(str, [[~"\.^$[]*]])
end

-- Get visual selection text (from autoload/autocmds.vim)
function M.get_visual_selection()
  local _, lnum1, col1 = unpack(vim.fn.getpos("'<"))
  local _, lnum2, col2 = unpack(vim.fn.getpos("'>"))
  local lines = vim.fn.getline(lnum1, lnum2)
  if #lines == 0 then
    return ""
  end
  local selection = vim.opt.selection:get()
  lines[#lines] = string.sub(lines[#lines], 1, col2 - (selection == "inclusive" and 0 or 1))
  lines[1] = string.sub(lines[1], col1)
  return table.concat(lines, "\n")
end

-- Spell setup (from autoload/functions.vim)
function M.spell()
  vim.opt_local.spell = true
  vim.opt_local.spellfile = vim.fn.expand("~/.vim/spell/en.utf-8.add")
  vim.opt_local.spelllang = "en,es"
end

-- Plaintext mode (from autoload/functions.vim)
function M.plaintext()
  vim.opt_local.concealcursor = "nc"
  vim.opt_local.list = false
  vim.opt_local.textwidth = 0
  vim.opt_local.wrap = true
  vim.opt_local.wrapmargin = 0
  M.spell()

  -- Break undo sequences into chunks after punctuation
  local buf_map = function(lhs, rhs)
    vim.keymap.set("i", lhs, rhs, { buffer = true })
  end
  buf_map("!", "!<C-g>u")
  buf_map(",", ",<C-g>u")
  buf_map(".", ".<C-g>u")
  buf_map(":", ":<C-g>u")
  buf_map(";", ";<C-g>u")
  buf_map("?", "?<C-g>u")
  vim.keymap.set("n", "j", "gj", { buffer = true })
  vim.keymap.set("n", "k", "gk", { buffer = true })
end

-- Clear all registers (from autoload/functions.vim)
function M.clearregisters()
  local regs = vim.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-\"", "")
  for _, reg in ipairs(regs) do
    vim.fn.setreg(reg, {})
  end
end

-- Keynote mode (from autoload/functions.vim)
function M.keynote()
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.cmd("TOhtml")
  local tempfile = vim.fn.trim(vim.fn.system("mktemp")) .. ".html"
  vim.cmd("saveas! " .. tempfile)
  vim.fn.system("open -b com.google.Chrome " .. tempfile)
  vim.cmd("quit")
end

-- Statusline utilities (from trc.utils)
M.color_suffix = "MyColors"

M.icons = {
  linux = "  ",
  macos = "  ",
  windows = "   ",
  ERROR = " ",
  WARN = " ",
  INFO = " ",
  HINT = " ",
  lsp = " ",
  git = "",
}

M.colors = {
  bg = "#202328",
  fg = "#bbc2cf",
  yellow = "#ECBE7B",
  cyan = "#008080",
  green = "#98be65",
  orange = "#FF8800",
  violet = "#a9a1e1",
  magenta = "#c678dd",
  skyblue = "#7daea3",
  blue = "#51afef",
  oceanblue = "#45707a",
  darkblue = "#081633",
  red = "#ec5f67",
  cream = "#a89984",
  grey = "#bbc2cf",
  black = "#202328",
  white = "#ffffff",
}

M.func = {
  strPrefixSuffix = function(str, args)
    args = args or {}
    local suffix = args.suffix or ""
    local prefix = args.prefix or ""
    return prefix .. str .. suffix
  end,
  osInfo = function(args)
    local fmt = vim.bo.fileformat
    local icon
    if fmt == "unix" then
      icon = M.icons.linux
    elseif fmt == "mac" then
      icon = M.icons.macos
    else
      icon = M.icons.windows
    end
    return M.func.strPrefixSuffix(icon, args)
  end,
  linesInfo = function(args)
    local str = "%l:%L  %v"
    return M.func.strPrefixSuffix(str, args)
  end,
  truncate = function(trunc_width, trunc_len, hide_width, no_ellipsis)
    return function(str)
      local win_width = vim.fn.winwidth(0)
      if hide_width and win_width < hide_width then
        return ""
      elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
        return str:sub(1, trunc_len) .. (no_ellipsis and "" or "...")
      end
      return str
    end
  end,
  scrollBar = function(args)
    local bars = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #bars) + 1
    local str = string.rep(bars[i], 2)
    return M.func.strPrefixSuffix(str, args)
  end,
  fileName = function(args)
    local f = vim.api.nvim_buf_get_name(0)
    f = vim.fn.fnamemodify(f, ":.")
    if f == "" then
      return "[No Name]"
    end
    return M.func.strPrefixSuffix(f, args)
  end,
  fileStatus = function()
    if vim.bo.modified then
      return "[+] "
    elseif not vim.bo.modifiable or vim.bo.readonly then
      return " "
    else
      return ""
    end
  end,
}

M.Conditions = {
  BufferNotEmpty = function()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
  end,
  HideWidth = function()
    return vim.fn.winwidth(0) > 80
  end,
  CheckGit = function()
    local filepath = vim.fn.expand("%:p:h")
    local gitdir = vim.fn.finddir(".git", filepath .. ";")
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
  CheckLSP = function()
    local clients = vim.lsp.get_clients()
    return next(clients) ~= nil
  end,
  BarWidth = function(n)
    return (vim.opt.laststatus:get() == 3 and vim.opt.columns:get() or vim.fn.winwidth(0)) > (n or 80)
  end,
}

M.vim_mode = {
  colors = {
    n = "Green",
    i = "Red",
    v = "Magenta",
    ["\22"] = "Blue",
    V = "Blue",
    c = "Magenta",
    no = "Green",
    s = "Orange",
    S = "Orange",
    ["\19"] = "Orange",
    ic = "Yellow",
    R = "Violet",
    Rv = "Violet",
    cv = "Red",
    ce = "Red",
    r = "Cyan",
    rm = "Cyan",
    ["r?"] = "Cyan",
    ["!"] = "Red",
    t = "Red",
  },
  names = {
    n = "N",
    no = "N?",
    nov = "N?",
    noV = "N?",
    ["no\22"] = "N?",
    niI = "Ni",
    niR = "Nr",
    niV = "Nv",
    nt = "Nt",
    v = "V",
    vs = "Vs",
    V = "V_",
    Vs = "Vs",
    ["\22"] = "^V",
    ["\22s"] = "^V",
    s = "S",
    S = "S_",
    ["\19"] = "^S",
    i = "I",
    ic = "Ic",
    ix = "Ix",
    R = "R",
    Rc = "Rc",
    Rx = "Rx",
    Rv = "Rv",
    Rvc = "Rv",
    Rvx = "Rv",
    c = "C",
    cv = "Ex",
    r = "...",
    rm = "M",
    ["r?"] = "?",
    ["!"] = "!",
    t = "T",
  },
}

function M.initHLcolors()
  local suffix = M.color_suffix
  for name, color in pairs(M.colors) do
    vim.api.nvim_set_hl(0, suffix .. "Fg" .. name, { fg = color, default = true })
    vim.api.nvim_set_hl(0, suffix .. "BlackFg" .. name, { fg = color, bg = "black", default = true })
    vim.api.nvim_set_hl(0, suffix .. "WhiteFg" .. name, { fg = color, bg = "white", default = true })
    vim.api.nvim_set_hl(0, suffix .. "BoldFg" .. name, { fg = color, bold = true, default = true })
    vim.api.nvim_set_hl(0, suffix .. "ItalicFg" .. name, { fg = color, italic = true, default = true })
    vim.api.nvim_set_hl(0, suffix .. "Bg" .. name, { bg = color, default = true })
    vim.api.nvim_set_hl(0, suffix .. "BlackBg" .. name, { fg = "black", bg = color, default = true })
    vim.api.nvim_set_hl(0, suffix .. "WhiteBg" .. name, { fg = "white", bg = color, default = true })
  end
end

return M
