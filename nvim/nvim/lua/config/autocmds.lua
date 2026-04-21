local utils = require("config.utils")

-- Alpha dashboard: hide statusline
vim.api.nvim_create_autocmd("User", {
  pattern = "AlphaReady",
  callback = function()
    vim.cmd([[set laststatus=0 | autocmd BufUnload <buffer> set laststatus=3]])
  end,
})

-- Close certain filetypes with q
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf", "help", "man", "lspinfo", "spectre_panel", "lir", "DressingSelect" },
  callback = function()
    vim.keymap.set("n", "q", ":close<CR>", { buffer = true, silent = true })
    vim.bo.buflisted = false
  end,
})

-- Wrap and spell for prose filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Lir: disable line numbers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lir",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

-- Equalize splits on resize
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Immediately quit command-line window
vim.api.nvim_create_autocmd("CmdWinEnter", {
  callback = function()
    vim.cmd("quit")
  end,
})

-- Highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Java: refresh code lens on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.java",
  callback = function()
    vim.lsp.codelens.refresh()
  end,
})

-- illuminatedWord highlight link
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd("hi link illuminatedWord LspReferenceText")
  end,
})

-- Cursor toggle on insert enter/leave
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    vim.opt.cursorline = false
    vim.opt.cursorcolumn = false
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function()
    vim.opt.cursorline = true
    vim.opt.cursorcolumn = true
  end,
})

-- Auto-save on insert leave
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "silent! update",
})

-- Strip trailing whitespace on save (excluding markdown)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local excluded = { markdown = true, ["mkd.markdown"] = true }
    if not excluded[vim.bo.filetype] then
      utils.zap()
    end
  end,
})

-- Auto-create parent directories on write
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Close location/quickfix on quit
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    if vim.bo.filetype ~= "qf" then
      vim.cmd("silent! lclose")
      vim.cmd("silent! cclose")
    end
  end,
})

-- Close completion preview on done
vim.api.nvim_create_autocmd("CompleteDone", {
  callback = function()
    vim.cmd("pclose")
  end,
})

-- Terminal settings
local term_group = vim.api.nvim_create_augroup("nvim_terminal", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  group = term_group,
  pattern = "*",
  callback = function()
    vim.bo.bufhidden = "wipe"
    vim.wo.winhighlight = "Normal:Normal"
  end,
})
vim.api.nvim_create_autocmd("TermClose", {
  group = term_group,
  pattern = "*",
  callback = function(args)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == args.buf then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end
    pcall(vim.api.nvim_buf_delete, args.buf, { force = true })
  end,
})

-- FZF terminal escape
vim.api.nvim_create_autocmd("FileType", {
  pattern = "fzf",
  callback = function()
    vim.keymap.set("t", "<Esc>", "<C-c>", { buffer = true })
  end,
})

-- ArgWrap settings for JavaScript
local argwrap_group = vim.api.nvim_create_augroup("MyArgWrapCmds", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = argwrap_group,
  pattern = { "javascript", "javascript.jsx" },
  callback = function()
    vim.b.argwrap_tail_comma = 1
    vim.b.argwrap_padded_braces = "[{"
    vim.b.argwrap_tail_comma_braces = "[{"
  end,
})

-- QuickFix folding
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "quickfix",
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldlevel = 0
  end,
})

-- Scala filetype for .sbt
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.sbt",
  command = "setlocal filetype=scala",
})

-- Window equalize keymap per buffer
local arrowkeys_group = vim.api.nvim_create_augroup("ArrowKeys", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "BufLeave" }, {
  group = arrowkeys_group,
  pattern = "*",
  callback = function()
    vim.keymap.set("n", "<leader>=", ':execute "wincmd ="<CR>', { buffer = true })
  end,
})

-- Lir git status highlight links (from vimrc:958-963)
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "LirGitStatusBracket", { link = "Comment" })
    vim.api.nvim_set_hl(0, "LirGitStatusIndex", { link = "Special" })
    vim.api.nvim_set_hl(0, "LirGitStatusWorktree", { link = "WarningMsg" })
    vim.api.nvim_set_hl(0, "LirGitStatusUnmerged", { link = "ErrorMsg" })
    vim.api.nvim_set_hl(0, "LirGitStatusUntracked", { link = "Comment" })
    vim.api.nvim_set_hl(0, "LirGitStatusIgnored", { link = "Comment" })
  end,
})
-- Also set them immediately
vim.api.nvim_set_hl(0, "LirGitStatusBracket", { link = "Comment" })
vim.api.nvim_set_hl(0, "LirGitStatusIndex", { link = "Special" })
vim.api.nvim_set_hl(0, "LirGitStatusWorktree", { link = "WarningMsg" })
vim.api.nvim_set_hl(0, "LirGitStatusUnmerged", { link = "ErrorMsg" })
vim.api.nvim_set_hl(0, "LirGitStatusUntracked", { link = "Comment" })
vim.api.nvim_set_hl(0, "LirGitStatusIgnored", { link = "Comment" })
