local map = vim.keymap.set
local utils = require("config.utils")

-- Visual indentation (reselect after indent)
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Maintain cursor position when yanking visual selection
map("v", "y", "myy`y")
map("v", "Y", "myY`y")

-- Keep it centered
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Same when moving up and down
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Ctrl-o: go back in jumplist, realign
map("n", "<C-o>", "<C-o>zzzv")

-- Join lines with M (J is remapped to ArgWrap)
map("n", "M", "J")

-- Navigate line with H L
map("n", "H", "^")
map("n", "L", "$")

-- Make j/k respect wrapped lines
map("n", "j", "gj")
map("n", "k", "gk")
map("n", "gj", "j")
map("n", "gk", "k")

-- Y yank to end of line
map("n", "Y", "y$")

-- Backspace deletes selection in visual mode
map("v", "<BS>", '"_xi')

-- Open file under cursor in vsplit
map("n", "gf", ":rightbelow wincmd f<CR>")

-- do not override register after paste in select mode
map("x", "p", 'pgv"' .. "'" .. "y`>")

-- Repeat last macro on visual selection
map("v", ".", ":norm.<CR>")

-- Folds
map("n", "<C-.>", "za", { expr = false })

-- Avoid unintentional switches to Ex mode
map("n", "Q", ":normal n.<CR>")

-- Select pasted text
map("n", "gp", "'`[' . strpart(getregtype(), 0, 1) . '`]'", { expr = true })

-- Fix mixed indent
map("n", "<leader>i", ":%retab!<CR>")

-- Open last buffer
map("n", "<leader><enter>", "<C-^>")

-- Only window
map("n", "<leader>o", ":only<CR>")

-- Count occurrences of word under cursor
map("n", "<leader>*", "*<C-O>:%s///gn<CR>")

-- Git shortcuts
map("n", "<C-g>b", ":Git blame<CR>")
map("n", "<C-g>B", ":Git browse<CR>")
map("n", "<C-g>s", ":Git status<CR>")
map("n", "<C-g>d", ":Gvdiffsplit<CR>")
map("n", "<C-g>P", ":Git push<CR>")
map("n", "<C-g>L", ":Git pull<CR>")

-- vim-move mappings
map("v", "<C-j>", "<Plug>MoveBlockDown")
map("n", "<C-j>", "<Plug>MoveLineDown")
map("v", "<C-k>", "<Plug>MoveBlockUp")
map("n", "<C-k>", "<Plug>MoveLineUp")

-- Metals diagnostics
map("n", "<localleader>a", '<cmd>lua require"metals".open_all_diagnostics()<CR>', { silent = true })

-- Diagnostics navigation
map("n", "[e", "<cmd>lua vim.diagnostic.goto_prev()<CR>", { silent = true })
map("n", "]e", "<cmd>lua vim.diagnostic.goto_next()<CR>", { silent = true })
map("n", "<leader>e", "<cmd>lua vim.diagnostic.setloclist()<CR>", { silent = true })

-- Strip whitespace
map("n", "<localleader>w", function() utils.zap() end, { silent = true })

-- Dismiss notifications
map("n", "<Backspace>n", '<cmd>lua require("notify").dismiss()<CR>', { silent = true })

-- Search and replace word under cursor
map("n", "<leader>r", [[:%s/\V\<<C-r>=luaeval("require('config.utils').escape_pattern(vim.fn.expand('<cword>'))")<CR>\>//c<Left><Left>]])
map("v", "<leader>r", [[:<C-u>%s/\V<C-r>=luaeval("require('config.utils').escape_pattern(require('config.utils').get_visual_selection())")<CR>//c<Left><Left>]])

-- Align current paragraph
map("n", "<leader>F", function() utils.align() end)
map("v", "<leader>F", "=")

-- Open config files
map("n", "ze", ":e $HOME/.zshrc<CR>", { silent = true })
map("n", "<localleader>e", ":e $MYVIMRC<CR>", { silent = true })
map("n", "<localleader>r", ":so %<CR>", { silent = true })

-- Clear search highlighting
map("n", "<C-L>", ':nohlsearch<C-R>=has("diff")?"<Bar>diffupdate":""<CR><CR><C-L>', { silent = true })

-- Readline-style command-line bindings
map("c", "<C-A>", "<Home>")
map("c", "<C-B>", "<C-Left>")
map("c", "<C-G>", "<C-Right>")
map("c", "<C-D>", [[getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"]], { expr = true })
map("c", "<C-F>", [[getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"]], { expr = true })

-- Kill double/single quotes
map("n", '<C-s>"', [[:%s/\V\"/'<CR><C-L>]])
map("n", "<C-s>'", [[:%s/\V\'/\"<CR><C-L>]])

-- Save all / save current / quit
map("n", "<leader>s", ":wa<CR>", { silent = true })
map("n", "<leader>S", ":update<CR>", { silent = true })
map("n", "<leader>q", ":confirm q<CR>")
map("n", "<leader>Q", ":confirm qall<CR>")

-- Duplicate line
map("n", "<leader>D", '"xyy"xp')

-- Case conversion in insert mode
map("i", "<C-g>u", "<Esc>guawA")
map("i", "<C-g>~", "<Esc>gUawA")
map("i", "<C-g>U", "<Esc>gUUA")
map("i", "<C-g>t", [[<Esc>:s/\v<(.)(\\w*)/\u\1\L\2/g<CR>A]])

-- Escape from insert mode with Ctrl-C
map("i", "<C-c>", "<ESC>")

-- Delete word backwards in insert mode
map("i", "<C-Delete>", "<C-w>")

-- Emacs-style insert mode
map("i", "<C-E>", "<C-o>$")
map("i", "<C-Q>", "<C-o>^")
map("i", "<C-B>", "<Left>")
map("i", "<C-F>", "<Right>")
map("i", "<C-D>", "<Delete>")

-- Command line editing (emacs style)
map("c", "<C-A>", "<Home>")
map("c", "<C-B>", "<Left>")
map("c", "<C-D>", "<Delete>")
map("c", "<C-F>", [[(getcmdpos()<(len(getcmdline())+1)) && (getcmdtype()==":") ? "\<Right>" : "\<C-F>"]], { expr = true })

-- ` is more precise than '
map("n", "'", "`")

-- snoremap <BS> in select mode
map("s", "<BS>", "<BS>i")

-- Tab/S-Tab in popupmenu
map("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
map("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

-- Git conflict markers
map("n", "[g", ":set nohls<CR>/<<<<<<<<CR>:set hls<CR>")
map("n", "]g", ":set nohls<CR>?<<<<<<<<CR>:set hls<CR>")
map("n", "[=", ":set nohls<CR>/=======<CR>:set hls<CR>")
map("n", "]=", ":set nohls<CR>/=======<CR>:set hls<CR>")
map("n", "[G", ":set nohls<CR>?>>>>>>><CR>:set hls<CR>")
map("n", "]G", ":set nohls<CR>?>>>>>>><CR>:set hls<CR>")

-- ArgWrap (J remapped to ArgWrap, M is join)
map("n", "J", ":ArgWrap<CR>", { silent = true })

-- Arrow keys resize windows
map("n", "<Left>", ":vertical resize -1<CR>")
map("n", "<Right>", ":vertical resize +1<CR>")
map("n", "<Up>", ":resize -1<CR>")
map("n", "<Down>", ":resize +1<CR>")

-- Close tag
map("i", "<localleader>/", "</<C-x><C-o>")

-- Close qf/preview/loc windows
map("", "<localleader>q", ":cclose <BAR> pclose <BAR> lclose<CR>")

-- Ctrl+Enter maximize window
map("n", "<C-Enter>", ":WindowsMaximizeHorizontally<CR>")

-- Window navigation with leader+arrow
map("n", "<leader><Up>", "<C-W><Up>")
map("n", "<leader><Left>", "<C-W><Left>")
map("n", "<leader><Right>", "<C-W><Right>")
map("n", "<leader><Down>", "<C-W><Down>")

-- Telescope workspace symbols
map("n", "<localleader>wd", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>")
map("n", "<localleader>ww", "<cmd>Telescope lsp_document_symbols<CR>")

-- Snacks dashboard
map("n", "<C-;>", ":lua Snacks.dashboard.open()<CR>")

-- Leader leader/backspace scrolling
map("n", "<leader><leader>", "<C-D>")
map("n", "<leader><BS>", "<C-U>")

-- Yank and paste below
map("n", "yp", "Yp")

-- Ctrl+M = Enter
map("", "<C-M>", "<CR>")

-- Scratch buffer
map("n", "<localleader>s", ":Scratch<CR>")

-- Multiline fix
map("n", "<localleader>m", [[:%s/\V\\n\\t/<C-V><C-M>/g<CR>]])

-- Terminal escape
map("t", "<Esc>", [[<C-\><C-n>]])

-- Mouse: Shift+click for visual block
map("n", "<S-LeftMouse>", "<4-LeftMouse>")
map("n", "<S-LeftDrag>", "<LeftDrag>")

-- Window cycling (from after/plugin/nav.lua)
local function get_counter_clockwise_windows()
  local current_win = vim.api.nvim_get_current_win()
  local windows = vim.api.nvim_list_wins()
  local ordered_windows = {}
  local current_index = 0
  for i, win in ipairs(windows) do
    if win == current_win then
      current_index = i
      break
    end
  end
  for i = 1, #windows do
    local index = (current_index - i) % #windows
    if index == 0 then
      index = #windows
    end
    table.insert(ordered_windows, windows[index])
  end
  return ordered_windows
end

local function cycle_windows_counter_clockwise()
  local windows = get_counter_clockwise_windows()
  if #windows > 0 then
    vim.api.nvim_set_current_win(windows[1])
  end
end

local function cycle_windows_clockwise()
  local current_win = vim.api.nvim_get_current_win()
  local windows = vim.api.nvim_list_wins()
  local current_index = 0
  for i, win in ipairs(windows) do
    if win == current_win then
      current_index = i
      break
    end
  end
  local ordered_windows = {}
  for i = 1, #windows do
    table.insert(ordered_windows, windows[(current_index + i - 1) % #windows + 1])
  end
  if #ordered_windows > 0 then
    vim.api.nvim_set_current_win(ordered_windows[1])
  end
end

-- map("n", "<Tab>", cycle_windows_counter_clockwise, { noremap = true, silent = true })
-- map("n", "<S-Tab>", cycle_windows_clockwise, { noremap = true, silent = true })
