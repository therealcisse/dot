-- :Scalafmt (from vimrc:299-318)
vim.api.nvim_create_user_command("Scalafmt", function()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  vim.cmd("write")
  local output = vim.fn.system("scala fmt " .. filepath)
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_err_writeln("scalafmt failed:\n" .. output)
    return
  end
  vim.cmd("edit")
  print("Buffer formatted with scalafmt")
end, { desc = "Format the current buffer with scalafmt" })

-- :Format (legacy LSP format command)
vim.api.nvim_create_user_command("Format", function()
  vim.lsp.buf.format()
end, { desc = "Format buffer with LSP" })

-- :HL - highlight group under cursor (from vimrc:774-800)
vim.api.nvim_create_user_command("HL", function()
  local syn_id = vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1)
  local hl_group = vim.fn.synIDattr(syn_id, "name")
  if hl_group ~= "" then
    local hl_def = vim.api.nvim_exec2("highlight " .. hl_group, { output = true })
    print("Highlight group: " .. hl_group)
    for _, line in ipairs(vim.split(hl_def.output, "\n")) do
      print(line)
    end
  else
    print("No highlight group found for the word under the cursor.")
  end
end, { desc = "Show highlight group under cursor" })

-- :CopyBuffer (from vimrc:858)
vim.api.nvim_create_user_command("CopyBuffer", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy buffer path to clipboard" })

-- :Jq (from vimrc:859)
vim.api.nvim_create_user_command("Jq", function(opts)
  vim.cmd(opts.line1 .. "," .. opts.line2 .. "!jq '.'")
end, { range = true, desc = "Format JSON with jq" })

-- :Scratch (from vimrc:862)
vim.api.nvim_create_user_command("Scratch", function()
  vim.cmd("vsplit")
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
  vim.bo.swapfile = false
end, { desc = "Open scratch buffer" })

-- :Tail (from vimrc:965-971)
vim.api.nvim_create_user_command("Tail", function()
  vim.opt.autoread = true
  vim.api.nvim_create_autocmd("CursorHold", {
    pattern = "*",
    callback = function()
      vim.cmd("checktime")
      vim.fn.feedkeys("G")
    end,
  })
  vim.cmd("normal! G")
end, { desc = "Tail the current file" })

-- :Root - cd to git root (from vimrc:582-591)
vim.api.nvim_create_user_command("Root", function()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not in git repo")
  else
    vim.cmd("lcd " .. root)
    print("Changed directory to: " .. root)
  end
end, { desc = "Change directory to git root" })

-- :EX - chmod +x current file (from vimrc:596-604)
vim.api.nvim_create_user_command("EX", function()
  local file = vim.fn.expand("%")
  if file == "" then
    vim.api.nvim_err_writeln("Save the file first")
    return
  end
  vim.cmd("write")
  vim.fn.system("chmod +x " .. vim.fn.expand("%"))
  vim.cmd("silent edit")
end, { desc = "Make current file executable" })

-- :Find (from autoload/commands.vim + plugin/commands.vim)
vim.api.nvim_create_user_command("Find", function(opts)
  vim.opt.errorformat:append("%f")
  vim.cmd("cexpr system('find " .. opts.args .. "')")
end, { nargs = "*", complete = "file", desc = "Find files" })

-- :OpenOnGitHub (from autoload/commands.vim)
vim.api.nvim_create_user_command("OpenOnGitHub", function(opts)
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.api.nvim_err_writeln("No filename")
    return
  end
  local git_dir = vim.fs.find(".git", { path = vim.fn.fnamemodify(file, ":h"), upward = true, type = "directory" })
  if #git_dir == 0 then
    vim.api.nvim_err_writeln("No .git directory found above " .. file)
    return
  end
  local root = vim.fn.fnamemodify(git_dir[1], ":h")
  local remotes = vim.fn.system("git --git-dir=" .. vim.fn.shellescape(git_dir[1]) .. " remote -v")
  local address = nil
  for _, remote in ipairs({ "github", "upstream", "upstream-rw", "origin" }) do
    local match = remotes:match(remote .. "%s+[git@github%.com:|https://github%.com/]([%w%-_%.]+/[%w%-_%.]+)")
    if match then
      address = match:gsub("%.git$", "")
      break
    end
  end
  if not address then
    vim.api.nvim_err_writeln("Could not determine GitHub remote")
    return
  end
  local relative = file:sub(#root + 1)
  local range_str = ""
  if opts.range > 0 then
    if opts.line1 == opts.line2 then
      range_str = "#L" .. opts.line1
    else
      range_str = "#L" .. opts.line1 .. "-L" .. opts.line2
    end
  end
  local url = "https://github.com/" .. address .. "/tree/master" .. relative .. range_str
  vim.ui.open(url)
end, { range = true, nargs = "*", complete = "file", desc = "Open file on GitHub" })

-- :Lint (from autoload/commands.vim)
vim.api.nvim_create_user_command("Lint", function()
  vim.cmd("compiler eslint")
  vim.cmd("Make")
end, { desc = "Run ESLint" })

-- :Typecheck (from autoload/commands.vim)
vim.api.nvim_create_user_command("Typecheck", function()
  vim.cmd("compiler tsc")
  vim.cmd("Make")
end, { desc = "Run TypeScript type checker" })

-- :Glow (from autoload/commands.vim)
vim.api.nvim_create_user_command("Glow", function(opts)
  if vim.fn.executable("glow") ~= 1 then
    vim.api.nvim_err_writeln("No glow executable found")
    return
  end
  local file = opts.args ~= "" and opts.args or vim.fn.expand("%")
  if file ~= "" then
    file = vim.fn.shellescape(file)
  end
  vim.cmd("!glow --local --pager " .. file)
end, { nargs = "?", complete = "file", desc = "Preview markdown with glow" })

-- :Marked (from autoload/commands.vim)
vim.api.nvim_create_user_command("Marked", function(opts)
  local files = opts.args ~= "" and vim.split(opts.args, " ") or { vim.fn.expand("%") }
  for _, file in ipairs(files) do
    vim.fn.system("xattr -d com.apple.quarantine " .. vim.fn.shellescape(file))
    vim.fn.system("open -a 'Marked 2.app' " .. vim.fn.shellescape(file))
  end
end, { nargs = "*", complete = "file", desc = "Open in Marked 2" })

-- :Preview (from autoload/commands.vim)
vim.api.nvim_create_user_command("Preview", function(opts)
  if vim.fn.executable("open") == 1 then
    vim.cmd("Marked " .. opts.args)
  elseif vim.fn.executable("glow") == 1 then
    vim.cmd("Glow " .. opts.args)
  else
    vim.api.nvim_err_writeln('No "open" or "glow" executable found')
  end
end, { nargs = "*", complete = "file", desc = "Preview markdown" })
