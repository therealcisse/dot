local ok, ts = pcall(require, 'nvim-treesitter')
if not ok then
  return
end

-- Install parsers
ts.install {
  'bash',
  'yaml',
  'markdown',
  'markdown_inline',
  'hcl',
  'lua',
  'regex',
  'scala',
  'go',
  'html',
  'javascript',
  'java',
  'json',
  'python',
  'tsx',
  'nix',
}

-- Enable treesitter features per filetype
local indent_disable = {
  dart = true, python = true, css = true, html = true,
  gdscript = true, gdscript3 = true, gd = true, Dockerfile = true,
}

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter_setup', { clear = true }),
  pattern = '*',
  callback = function(event)
    local lang = event.match

    -- Enable treesitter highlighting (provided by Neovim core)
    pcall(vim.treesitter.start, event.buf, lang)

    -- Enable treesitter indentation (unless disabled for this filetype)
    if not indent_disable[lang] then
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Incremental selection
vim.keymap.set('n', '<c-space>', function()
  require('nvim-treesitter.incremental_selection').init_selection()
end, { desc = 'Init treesitter selection' })
vim.keymap.set('v', '<c-space>', function()
  require('nvim-treesitter.incremental_selection').node_incremental()
end, { desc = 'Increment treesitter selection' })
vim.keymap.set('v', '<M-space>', function()
  require('nvim-treesitter.incremental_selection').node_decremental()
end, { desc = 'Decrement treesitter selection' })
vim.keymap.set('v', '<c-s>', function()
  require('nvim-treesitter.incremental_selection').scope_incremental()
end, { desc = 'Scope incremental selection' })

vim.cmd [[highlight IncludedC guibg=#373b41]]

-- Inspect treesitter tree (replaces old TSPlaygroundToggle)
vim.keymap.set('n', '<leader>tp', ':InspectTree<CR>', { desc = 'Treesitter inspect tree' })
vim.keymap.set('n', '<leader>th', ':Inspect<CR>', { desc = 'Treesitter inspect highlight' })

-- gitsigns (guarded)
local gs_ok, gs = pcall(require, 'gitsigns')
if not gs_ok then
  return
end
