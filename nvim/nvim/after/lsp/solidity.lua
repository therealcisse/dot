---@type vim.lsp.Config
return {
  cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
  filetypes = { "solidity" },
  root_markers = { ".git" },
  single_file_support = true,
}
