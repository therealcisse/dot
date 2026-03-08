---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" or fname:match("^[%a+%.%-]+://") then return end

    local cwd = vim.uv.cwd() or ""
    local abs_cwd = vim.fn.fnamemodify(cwd, ":p")
    local abs_fname = vim.fn.fnamemodify(fname, ":p")

    -- If CWD contains /cmd/ and the file is under CWD, prefer CWD as root
    if abs_cwd:find("/cmd/", 1, true) and abs_fname:sub(1, #abs_cwd) == abs_cwd then
      on_dir(abs_cwd)
      return
    end

    local root = vim.fs.root(bufnr, { "go.mod", ".git" })
    if root then on_dir(root) end
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
}
