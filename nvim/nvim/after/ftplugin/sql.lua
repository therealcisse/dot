vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.relativenumber = false

local function string_newline()
  local current_line = vim.fn.getline(".")
  local match = current_line:match("(%s*)N'")
  local num_spaces = match and (#match - 2) or 0
  if num_spaces < 0 then
    num_spaces = 0
  end
  vim.cmd(string.format("normal! i '\r+%sN'", string.rep(" ", num_spaces)))
end

vim.keymap.set("i", ",,<CR>", function()
  string_newline()
end, { buffer = true })
