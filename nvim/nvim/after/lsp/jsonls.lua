---@type vim.lsp.Config
return {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas({
        select = { "Renovate", "GitHub Workflow Template Properties" },
      }),
      validate = { enable = true },
    },
  },
}
