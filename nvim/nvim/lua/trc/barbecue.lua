local status_ok, barbecue = pcall(require, 'barbecue')
if not status_ok then
  return
end


barbecue.setup({
  create_autocmd = false, -- prevent barbecue from updating itself automatically
  attach_navic = false,
})

vim.api.nvim_create_autocmd({
  "WinScrolled", -- or WinResized on NVIM-v0.9 and higher
  "BufWinEnter",
  "CursorHold",
  "InsertLeave",

  -- include this if you have set `show_modified` to `true`
  "BufModifiedSet",
}, {
  group = vim.api.nvim_create_augroup("barbecue.updater", {}),
  callback = function()
    require("barbecue.ui").update()
  end,
})
