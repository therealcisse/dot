if vim.g.started_by_firenvim then
  vim.opt_local.laststatus = 0
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.ruler = false
  vim.opt_local.showcmd = false

  vim.opt.rtp:append("~/git/vai.vim/")
  vim.opt_local.completefunc = "vai#completefunc"

  vim.keymap.set("i", "<tab>", "<c-n>", { buffer = true })
  vim.keymap.set("i", "<s-tab>", "<c-p>", { buffer = true })
end
