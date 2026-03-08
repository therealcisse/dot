---@type vim.lsp.Config
return {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = true, maxLineLength = 120 },
        pylint = { enabled = false },
        pyflakes = { enabled = true },
        jedi_completion = { fuzzy = true },
      },
    },
  },
}
