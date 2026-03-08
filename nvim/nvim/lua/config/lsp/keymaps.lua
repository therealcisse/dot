-- LSP keymaps via LspAttach (replaces M.on_attach + filetype_attach)

local augroup_format = vim.api.nvim_create_augroup("my_lsp_format", { clear = true })

local function autocmd_format(async)
  vim.api.nvim_clear_autocmds({ buffer = 0, group = augroup_format })
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = 0,
    callback = function()
      vim.lsp.buf.format({ async = async })
    end,
  })
end

-- Per-server format-on-save
local format_on_save = {
  terraformls = function() autocmd_format(false) end,
  tflint = function() autocmd_format(false) end,
  hls = function() autocmd_format(false) end,
  clangd = function() autocmd_format(true) end,
}

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    local map = function(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Capabilities-based settings
    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end
    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition)
    map("n", "gD", vim.lsp.buf.declaration)
    map("n", "gT", vim.lsp.buf.type_definition)
    map("n", "gi", function()
      -- Custom implementation that filters Go mock files
      local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
      vim.lsp.buf_request(0, "textDocument/implementation", params, function(err, result, ctx, cfg)
        local ft = vim.bo[ctx.bufnr].filetype
        if ft == "go" and result then
          local filtered = vim.tbl_filter(function(v)
            return not string.find(v.uri, "mock_")
          end, result)
          if #filtered > 0 then result = filtered end
        end
        vim.lsp.handlers["textDocument/implementation"](err, result, ctx, cfg)
        vim.cmd("normal! zz")
      end)
    end)

    -- Telescope LSP pickers
    map("n", "<localleader>gr", function() require("telescope.builtin").lsp_references() end)
    map("n", "gI", function() require("telescope.builtin").lsp_implementations() end)

    -- Actions
    map("n", "<localleader>rn", vim.lsp.buf.rename)
    map("n", "<localleader>ca", vim.lsp.buf.code_action)
    map("n", "<leader>e", vim.diagnostic.open_float)
    map("i", "<c-s>s", vim.lsp.buf.signature_help)

    -- Per-server format-on-save
    local fmt_fn = format_on_save[client.name]
    if fmt_fn then fmt_fn() end
  end,
})

-- Global LSP keymaps (not buffer-local)
vim.keymap.set("n", "K", function()
  vim.lsp.buf.hover({ border = "rounded" })
end)
vim.keymap.set("n", "<leader>h", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)

vim.keymap.set("n", "<leader>k", function()
  vim.lsp.codelens.run()
end)
