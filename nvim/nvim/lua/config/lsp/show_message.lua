-- Custom window/showMessage handler (floating window)

local message_buf = vim.api.nvim_create_buf(false, true)

---@param messages string[]
local function create_little_window(messages)
  local msg_lines = #messages

  local msg_width = 0
  for _, v in ipairs(messages) do
    msg_width = math.max(msg_width, #v + 1)
  end

  local ui = vim.api.nvim_list_uis()[1]
  local ui_width = ui.width

  local win_height = math.max(1, math.min(50, msg_lines))
  local win_width = math.min(150, msg_width) + 5

  return vim.api.nvim_open_win(message_buf, false, {
    relative = "editor",
    style = "minimal",
    height = win_height,
    width = win_width,
    row = 1,
    col = ui_width - win_width - 2,
    border = "rounded",
  })
end

---@param _ any
---@param result { type: integer, message: string }
---@param ctx { client_id: integer }
---@return table
return function(_, result, ctx)
  local client_id = ctx.client_id
  local message_type = result.type
  local client_message = result.message
  local client = vim.lsp.get_client_by_id(client_id)
  local client_name = client and client.name or string.format("id=%d", client_id)

  local messages = {}

  if not client then
    error(string.format("LSP[%s] client has shut down after sending the message", client_name))
  end
  if message_type ~= vim.lsp.protocol.MessageType.Error then
    local message_type_name = vim.lsp.protocol.MessageType[message_type]
    table.insert(messages, string.format("LSP %s %s", client_name, message_type_name))
    for _, text in ipairs(vim.split(client_message, "\n")) do
      table.insert(messages, "  " .. text .. "  ")
    end
  end

  vim.api.nvim_buf_set_lines(message_buf, 0, -1, false, messages)

  local win_id = create_little_window(messages)
  vim.api.nvim_create_autocmd("CursorMoved", {
    once = true,
    callback = function()
      pcall(vim.api.nvim_win_close, win_id, true)
    end,
  })

  return result
end
