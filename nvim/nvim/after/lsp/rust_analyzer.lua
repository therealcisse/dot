---@type vim.lsp.Config
return {
  cmd = { "rustup", "run", "stable", "rust-analyzer" },
  flags = { debounce_text_changes = 150 },
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      completion = { postfix = { enable = false } },
    },
  },
}
