vim.opt_local.shiftwidth = 2
vim.opt_local.commentstring = "//%s"
vim.opt_local.formatoptions:remove("o")

if vim.fn.findfile("src/uncrustify.cfg", ";") ~= "" then
  vim.opt_local.formatprg = "uncrustify -q -l C -c src/uncrustify.cfg --no-backup 2>/dev/null"
end
