-- lua/config/lsp/init.lua
-- Modern Neovim 0.11+ LSP configuration using vim.lsp.config + vim.lsp.enable

-- Load sub-modules
require("config.lsp.keymaps")
require("config.lsp.diagnostics")

local codelens = require("config.lsp.codelens")
codelens.setup()

-- Shared defaults for ALL servers
local capabilities = require("blink.cmp").get_lsp_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
capabilities.textDocument.codeLens = { dynamicRegistration = false }
capabilities.textDocument.completion.completionItem.insertReplaceSupport = false

vim.lsp.config("*", {
  capabilities = capabilities,
  handlers = {
    ["window/showMessage"] = require("config.lsp.show_message"),
    ["textDocument/codeLens"] = codelens.on_codelens,
  },
})

-- Yamlls (special case: yaml-companion returns a full config table)
local yaml_cfg = require("yaml-companion").setup({
  builtin_matchers = {},
  schemas = {
    { name = "Argo CD Application", uri = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/application_v1alpha1.json" },
    { name = "SealedSecret", uri = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/bitnami.com/sealedsecret_v1alpha1.json" },
    { name = "Kustomization", uri = "https://json.schemastore.org/kustomization.json" },
    { name = "GitHub Workflow", uri = "https://json.schemastore.org/github-workflow.json" },
  },
  lspconfig = {
    flags = { debounce_text_changes = 150 },
    settings = {
      yaml = {
        validate = true,
        hover = true,
        schemaStore = { enable = false, url = "" },
        schemaDownload = { enable = true },
        schemas = require("schemastore").yaml.schemas({
          select = { "kustomization.yaml", "GitHub Workflow" },
        }),
      },
    },
  },
})
vim.lsp.config("yamlls", yaml_cfg)

-- Enable all servers
-- Servers with after/lsp/<name>.lua files get their config merged automatically
local servers = {
  "graphql",
  "sqls",
  "pylsp",
  "ts_ls",
  "jsonls",
  "yamlls",
  "gopls",
  "rust_analyzer",
  "lua_ls",
  "terraformls",
  "tflint",
}

-- Conditional servers
if vim.fn.executable("cmake-language-server") == 1 then
  table.insert(servers, "cmake")
end
if vim.fn.executable("zig") == 1 then
  table.insert(servers, "zls")
end

vim.lsp.enable(servers)
