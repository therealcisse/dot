-- Go fold functions (from after/ftplugin/go.vim)

local start_new_important_fold = { "^func", "^struct" }
local is_comment = "^// "

---@param str string
---@param patterns string|string[]
---@return boolean
local function matches(str, patterns)
  if type(patterns) == "string" then
    return str:find(patterns) ~= nil
  elseif type(patterns) == "table" then
    for _, pat in ipairs(patterns) do
      if matches(str, pat) then
        return true
      end
    end
  end
  return false
end

---@param lnum? integer
---@return string
function _G._go_folder(lnum)
  lnum = lnum or vim.v.lnum
  local line = vim.fn.getline(lnum)
  local next_line = vim.fn.getline(lnum + 1)
  local prev_line = vim.fn.getline(lnum - 1)

  if matches(line, is_comment) then
    if matches(prev_line, "^$") then
      return ">1"
    end
    if matches(next_line, start_new_important_fold) then
      return "<1"
    end
    return "1"
  end

  if matches(line, start_new_important_fold) then
    return ">1"
  end

  return "="
end

---@param fold_start? integer
---@param fold_end? integer
---@return string
function _G._go_text(fold_start, fold_end)
  fold_start = fold_start or vim.v.foldstart
  fold_end = fold_end or vim.v.foldend

  local start_line = vim.fn.getline(fold_start)

  if matches(start_line, is_comment) then
    local lines = vim.fn.getline(fold_start, fold_end)
    local cleaned = {}
    for _, v in ipairs(lines) do
      table.insert(cleaned, (v:gsub("^// ", "")))
    end
    return table.concat(cleaned, " ")
  end

  return vim.fn.foldtext()
end

vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua._go_folder()"
vim.opt_local.foldtext = "v:lua._go_text()"
vim.opt_local.foldlevel = 1
vim.opt_local.expandtab = false
