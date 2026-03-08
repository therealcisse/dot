---@type vim.lsp.Config
return {
  cmd = {
    "haskell-language-server-wrapper",
    "--lsp",
    "-d",
    "-l",
    "/tmp/hls.log",
  },
  filetypes = { "haskell", "lhaskell" },
  root_markers = { "*.cabal", "stack.yaml", "cabal.project", "package.yaml", "hie.yaml" },
}
