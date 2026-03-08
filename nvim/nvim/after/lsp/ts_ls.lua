---@type vim.lsp.Config
return {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "literals",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = { includeInlayParameterNameHints = "literals" },
    },
  },
}
