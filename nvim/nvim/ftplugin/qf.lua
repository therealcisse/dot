vim.b.did_ftplugin = 1

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.cmd("wincmd J")
  end,
})

vim.opt_local.colorcolumn = ""
vim.b.undo_ftplugin = "setl fo< com< ofu<"
vim.opt_local.wrap = true
vim.opt_local.relativenumber = false
vim.opt_local.number = true
vim.opt_local.list = false
