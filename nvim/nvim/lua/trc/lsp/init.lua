-- lua/trc/lsp/init.lua  (migrated to Neovim 0.11 native LSP config)

local imap = require('trc.keymap').imap
local nmap = require('trc.keymap').nmap

local M = {}

local lsp_util = require("lspconfig.util")

local util = require('trc.lsp.lsp_util')
local telescope_mapper = require('trc.telescope.mappings')
local handlers = require('trc.lsp.handlers')

local status = require('trc.lsp.status')
if status then
  status.activate()
end

function M.on_init(client, _)
  client.config.flags = client.config.flags or {}
  client.config.flags.allow_incremental_sync = true
end

local augroup_format = vim.api.nvim_create_augroup('my_lsp_format', { clear = true })
local autocmd_format = function(async, filter)
  vim.api.nvim_clear_autocmds({ buffer = 0, group = augroup_format })
  vim.api.nvim_create_autocmd('BufWritePre', {
    buffer = 0,
    callback = function()
      vim.lsp.buf.format({ async = async, filter = filter })
    end,
  })
end

local filetype_attach = setmetatable({
  sqls = function() end,

  lua_ls = function() end,

  ts_ls = function() end,

  terraformls = function()
    autocmd_format(false)
  end,

  tflint = function()
    autocmd_format(false)
  end,

  hls = function()
    autocmd_format(false)
  end,

  clang = function()
    autocmd_format(true)
  end,
}, {
  __index = function()
    return function() end
  end,
})

local buf_nnoremap = function(opts)
  if opts[3] == nil then
    opts[3] = {}
  end
  opts[3].buffer = 0
  nmap(opts)
end

local buf_inoremap = function(opts)
  if opts[3] == nil then
    opts[3] = {}
  end
  opts[3].buffer = 0
  imap(opts)
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if client.server_capabilities.inlayHintProvider then
      -- vim.lsp.inlay_hint.enable(true, bufnr)
    end

    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    end

    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
    end
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  callback = function(args)
    local _client = vim.lsp.get_client_by_id(args.data.client_id)
    -- Optionally reset buffer local opts
    -- vim.cmd('setlocal tagfunc< omnifunc<')
  end,
})

vim.keymap.set('n', '<leader>h', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)

vim.keymap.set('n', '<leader>k', function()
  vim.lsp.codelens.run()
end)

vim.keymap.set('n', '<leader>b', function()
  require('dap').toggle_breakpoint()
end, { noremap = true })
vim.keymap.set('n', '<leader>dt', function()
  require('dapui').toggle()
end, { noremap = true })
vim.keymap.set('n', '<leader>dc', function()
  require('dap').continue()
end, { noremap = true })
vim.keymap.set('n', '<leader>dr', function()
  require('dapui').open({ reset = true })
end, { noremap = true })

vim.keymap.set('n', '<leader>dE', function()
  require('dapui').eval(vim.fn.input('[DAP] Expression > '))
end)

-- Treat only real files as candidates for a root
local function is_real_file(name)
  if type(name) ~= "string" or name == "" then return false end
  -- skip URIs like oil://, lir://, fugitive://, etc.
  if name:match("^[%a+%.%-]+://") then return false end
  -- absolute path check and existence
  local abs = vim.fn.fnamemodify(name, ":p")
  if abs == "" then return false end
  local stat = vim.uv.fs_stat(abs)
  return stat ~= nil and (stat.type == "file" or stat.type == "link")
end

-- Safer startswith
local function starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

function M.on_attach(client, bufnr)
  local filetype = vim.api.nvim_buf_get_option(0, 'filetype')

  if vim.g.vscode then
    buf_inoremap({ 'K', vim.lsp.buf.hover })
  end

  buf_inoremap({ '<c-s>s', vim.lsp.buf.signature_help })

  buf_nnoremap({ '<localleader>rn', vim.lsp.buf.rename })
  buf_nnoremap({ '<localleader>ca', vim.lsp.buf.code_action })
  buf_nnoremap({ '<leader>e', vim.diagnostic.open_float })

  buf_nnoremap({ 'gd', vim.lsp.buf.definition })
  buf_nnoremap({ 'gD', vim.lsp.buf.declaration })
  buf_nnoremap({ 'gT', vim.lsp.buf.type_definition })

  buf_nnoremap({ 'gi', handlers.implementation })

  telescope_mapper('<localleader>gr', 'lsp_references', nil, true)
  telescope_mapper('gI', 'lsp_implementations', nil, true)

  filetype_attach[filetype](client)
end

-- Capabilities from blink.cmp
local updated_capabilities = require('blink.cmp').get_lsp_capabilities()
updated_capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
updated_capabilities.textDocument.codeLens = { dynamicRegistration = false }
updated_capabilities.textDocument.completion.completionItem.insertReplaceSupport = false

M.capabilities = updated_capabilities

-- Helper to emulate lspconfig.util.find_git_ancestor using your util module
local function find_git_root_or_cwd(fname)
  local rp = util.root_pattern('.git')
  return rp and rp(fname) or vim.loop.cwd()
end

-- Server definitions. Booleans mean default config. Tables extend defaults.
local servers = {
  graphql = true,
  sqls = true,

  pylsp = {
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
  },

  ts_ls = {
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
  },

  jsonls = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas {
          select = { 'Renovate', 'GitHub Workflow Template Properties' }
        },
        validate = { enable = true },
      }
    }
  },

  yamlls = require('yaml-companion').setup {
    builtin_matchers = {},
    schemas = {
      { name = 'Argo CD Application', uri = 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/application_v1alpha1.json' },
      { name = 'SealedSecret', uri = 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/bitnami.com/sealedsecret_v1alpha1.json' },
      { name = 'Kustomization', uri = 'https://json.schemastore.org/kustomization.json' },
      { name = 'GitHub Workflow', uri = 'https://json.schemastore.org/github-workflow.json' },
    },
    lspconfig = {
      flags = { debounce_text_changes = 150 },
      settings = {
        yaml = {
          validate = true,
          hover = true,
          schemaStore = { enable = false, url = '' },
          schemaDownload = { enable = true },
          schemas = require('schemastore').yaml.schemas {
            select = { 'kustomization.yaml', 'GitHub Workflow' }
          }
        }
      }
    }
  },

  cmake = (1 == vim.fn.executable('cmake-language-server')),
  zls = (1 == vim.fn.executable('zig')),
  dartls = true,

  solang = true,

  solidity = {
    cmd = { 'nomicfoundation-solidity-language-server', '--stdio' },
    filetypes = { 'solidity' },
    root_dir = function(fname) return find_git_root_or_cwd(fname) end,
    single_file_support = true,
  },

  clangd = {
    cmd = {
      'clangd',
      '--background-index',
      '--clang-tidy',
      '--header-insertion=iwyu',
      '--log=verbose',
    },
    initialization_options = {
      fallback_flags = { '-std=c++17' },
      clangdFileStatus = true,
    },
    init_options = {
      fallback_flags = { '-std=c++17' },
      clangdFileStatus = true,
    },
    handlers = nil,
  },

  gopls = {
    root_dir = function(fname)
      -- Resolve a usable filename, or bail out
      fname = fname or vim.api.nvim_buf_get_name(0)
      if not is_real_file(fname) then
        return nil
      end

      -- Compute absolute paths without constructing plenary Path yet
      local cwd = vim.loop.cwd() or ""
      local abs_cwd = vim.fn.fnamemodify(cwd, ":p")
      local abs_fname = vim.fn.fnamemodify(fname, ":p")

      -- Only now use plenary Path if you want the normalized absolute
      local Path = require("plenary.path")
      abs_cwd = Path:new(abs_cwd):absolute()
      abs_fname = Path:new(abs_fname):absolute()

      -- If CWD contains /cmd/ and file is under CWD, prefer CWD as root
      -- Works on macOS and Linux. For Windows, Path handles separators.
      if abs_cwd:find("/cmd/", 1, true) and starts_with(abs_fname, abs_cwd) then
        return abs_cwd
      end

      -- Otherwise fall back to usual project markers
      -- If none found, util.root_pattern returns nil, which tells lspconfig not to start
      return lsp_util.root_pattern("go.mod", ".git")(fname)
    end,
    settings = {
      gopls = {
        codelenses = { test = true },
        completeUnimported = true,
        usePlaceholders = true,
        analyses = { unusedparams = true },
        hints = {
          parameterNames = true,
          constantValues = true,
          compositeLiteralTypes = true,
          assignVariableTypes = true,
        },
      },
    },
    flags = { debounce_text_changes = 200 },
  },

  rust_analyzer = {
    cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
    flags = { debounce_text_changes = 150 },
    settings = {
      ['rust-analyzer'] = {
        cargo = { allFeatures = true },
        completion = { postfix = { enable = false } },
      },
    },
  },

  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },

  terraformls = true,
  tflint = true,

  hls = {
    cmd = {
      'haskell-language-server-wrapper',
      '--lsp',
      '-d',
      '-l',
      '/tmp/hls.log',
    },
    filetypes = { 'haskell', 'lhaskell' },
    root_dir = util.root_pattern('*.cabal', 'stack.yaml', 'cabal.project', 'package.yaml', 'hie.yaml'),
  },
}

-- Native 0.11 setup: write configs to vim.lsp.config then enable
local function enable_server(name, cfg)
  local existing = vim.lsp.config[name] or {}
  vim.lsp.config[name] = vim.tbl_deep_extend('force', existing, cfg or {})
  vim.lsp.enable(name)
end

local function setup_server(server, config)
  if not config then
    return
  end
  if type(config) ~= 'table' then
    config = {}
  end

  config = vim.tbl_deep_extend('force', {
    on_init = M.on_init,
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    flags = {},
    hint = {
      enable = true,
      arrayIndex = 'Enable',
      setType = true,
    },
  }, config)

  enable_server(server, config)
end

for server, config in pairs(servers) do
  setup_server(server, config)
end

return M
