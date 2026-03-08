-- init.lua -- Entry point (replaces init.vim -> vimrc)

-- Foundation (options includes leader keys, must load before plugins)
require("config.options")
require("config.globals")
require("config.icons")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local is_mac = vim.fn.has("macunix") == 1

require("lazy").setup({
  { import = "config.plugins" },
  { import = "config.plugins.languages" },
}, {
  concurrency = is_mac and 32 or nil,
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Core modules (after plugins are declared so lazy specs resolve)
require("config.keymaps")
require("config.autocmds")
require("config.highlights")
require("config.filetypes")
require("config.commands")
require("config.utils")

-- LSP (modern vim.lsp.config + vim.lsp.enable)
require("config.lsp")

-- Machine-local overrides
local vimrc_local = vim.fn.expand("~/.vimrc.local")
if vim.fn.filereadable(vimrc_local) == 1 then
  vim.cmd("source " .. vimrc_local)
end
