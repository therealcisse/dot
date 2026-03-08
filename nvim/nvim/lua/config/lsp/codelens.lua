-- CodeLens lightbulb sign support

local icons = require("config.icons")

local M = {}

local ns = vim.api.nvim_create_namespace("codelens_lightbulb")
local code_lens_action = {}

---@param bufnr integer
---@param line integer|nil
local function _update_sign(bufnr, line)
  local winid = vim.api.nvim_get_current_win()
  if code_lens_action[winid] == nil then
    code_lens_action[winid] = {}
  end

  -- Clear previous extmark for this window
  if code_lens_action[winid].extmark_id then
    vim.api.nvim_buf_del_extmark(bufnr, ns, code_lens_action[winid].extmark_id)
    code_lens_action[winid].extmark_id = nil
  end

  if line then
    local id = vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
      sign_text = icons.ui.Lightbulb,
      sign_hl_group = "DiagnosticSignHint",
      priority = 40,
    })
    code_lens_action[winid].extmark_id = id
  end
end

function M.setup()
  vim.api.nvim_set_hl(0, "LspCodeLens", { link = "DiagnosticHint" })
  vim.api.nvim_set_hl(0, "LspCodeLensText", { link = "DiagnosticInfo" })
  vim.api.nvim_set_hl(0, "LspCodeLensTextSign", { link = "DiagnosticSignInfo" })
  vim.api.nvim_set_hl(0, "LspCodeLensTextSeparator", { link = "Boolean" })
end

--- Handler for textDocument/codeLens, to be wired in vim.lsp.config('*')
---@param err any
---@param result table|nil
---@param ctx table
---@param cfg table|nil
function M.on_codelens(err, result, ctx, cfg)
  -- Call the built-in handler first
  vim.lsp.handlers["textDocument/codeLens"](err, result, ctx, cfg)

  if err or result == nil then
    return
  end

  local bufnr = ctx.bufnr or vim.api.nvim_get_current_buf()
  for _, v in pairs(result) do
    _update_sign(bufnr, v.range.start.line)
  end
end

---Run the closest codelens above the cursor
function M.run()
  if vim.o.modified then
    vim.cmd("w")
  end

  local buf = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1]

  local lenses = vim.deepcopy(vim.lsp.codelens.get(buf))

  lenses = vim.tbl_filter(function(v)
    return v.range.start.line < line
  end, lenses)

  table.sort(lenses, function(a, b)
    return a.range.start.line < b.range.start.line
  end)

  local _, lens = next(lenses)
  if not lens then return end

  local clients = vim.lsp.get_clients({ bufnr = buf })
  if #clients == 0 then return end
  local client = clients[1]

  client.request("workspace/executeCommand", lens.command, function(...)
    local result = vim.lsp.handlers["workspace/executeCommand"](...)
    vim.lsp.codelens.refresh()
    return result
  end, buf)
end

return M
