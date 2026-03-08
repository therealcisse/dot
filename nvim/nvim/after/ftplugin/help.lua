vim.opt_local.expandtab = true
vim.opt_local.textwidth = 78
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4

local function right_align()
  local text = vim.fn.matchstr(vim.fn.getline("."), [[^\s*\zs.\+\ze\s*$]])
  local remainder = (vim.bo.textwidth + 2) - #text
  vim.fn.setline(vim.fn.line("."), string.rep(" ", remainder) .. text)
  vim.cmd("undojoin")
end

function _G._help_format_expr()
  if vim.fn.mode() == "i" or vim.v.char ~= "" then
    return 1
  end

  local line = vim.fn.getline(vim.v.lnum)
  if line:match("^=+$") then
    vim.cmd("normal! macc")
    vim.cmd("normal! 78i=")
    vim.cmd("normal! `a")
    vim.cmd("undojoin")
    return
  elseif line:match("^%k[%k%s]+%s*%*[%k%-]+%*%s*") then
    local header, link = line:match("^(%k[%k%s]+)%s*(%*.+)$")
    if header and link then
      header = header:gsub("^%s+", ""):gsub("%s+$", "")
      local remainder = (vim.bo.textwidth + 1) - #header - #link
      vim.fn.setline(vim.v.lnum, header .. string.rep(" ", math.max(remainder, 1)) .. link)
    end
    return
  end

  return 1
end

local function toggle_help_file_type()
  if vim.bo.filetype == "help" then
    vim.bo.filetype = ""
    vim.opt_local.list = true
    vim.opt_local.listchars = "tab:>~"
    vim.opt_local.colorcolumn = "78"
  else
    vim.bo.filetype = "help"
    vim.opt_local.list = false
    vim.opt_local.colorcolumn = ""
  end
end

vim.keymap.set("n", "<leader>th", toggle_help_file_type, { buffer = true, silent = true })
vim.keymap.set("n", "<leader>ha", right_align, { buffer = true, silent = true })
vim.keymap.set(
  "n",
  "<leader>i=",
  "i==============================================================================<esc>",
  { buffer = true, silent = true }
)

vim.opt_local.formatexpr = "v:lua._help_format_expr()"
