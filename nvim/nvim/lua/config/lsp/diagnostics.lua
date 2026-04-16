-- Diagnostics configuration

vim.diagnostic.config({
  virtual_lines = { only_on_current_line = true, highlight_whole_line = false },
  update_in_insert = true,
  virtual_text = false,
  signs = true,
  float = {
    show_header = true,
    border = "rounded",
    format = function(d)
      local t = vim.deepcopy(d)
      local code = d.code or (d.user_data and d.user_data.lsp and d.user_data.lsp.code)
      if code then
        t.message = string.format("%s [%s]", t.message, code):gsub("1. ", "")
      end
      return t.message
    end,
  },
  severity_sort = true,
})

vim.keymap.set("", "<leader>l", function()
  local vl = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({
    virtual_lines = not vl and { only_on_current_line = true, highlight_whole_line = false } or false,
  })
end, { desc = "Toggle virtual lines diagnostics" })

vim.keymap.set("n", "<leader>gj", function()
  vim.diagnostic.jump({ count = 1, wrap = true, float = true })
end)

vim.keymap.set("n", "<leader>gk", function()
  vim.diagnostic.jump({ count = -1, wrap = true, float = true })
end)

vim.keymap.set("n", "<localleader>cd", function()
  vim.diagnostic.open_float(0, { scope = "line" })
end)
