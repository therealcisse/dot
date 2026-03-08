local function handle_inactive_background()
  if vim.g.falcon_inactive == nil then
    vim.g.falcon_inactive = 1
  end
  if vim.g.falcon_background == nil then
    vim.g.falcon_background = 1
  end

  vim.api.nvim_set_hl(0, "NonText", { fg = "#000000", bg = "#000000" })
  vim.api.nvim_set_hl(0, "Normal", { fg = "#b4b4b9", bg = "#000000" })
  vim.api.nvim_set_hl(0, "InactiveWindow", { bg = "#000000" })
  vim.api.nvim_set_hl(0, "NormalNC", { fg = "#b4b4b9", bg = "#000000" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#000000", bg = "#000000" })
  vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#AAAAAA", bg = "#000000", italic = true, bold = true })
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "Red", bg = "#000000" })
  vim.api.nvim_set_hl(0, "SnacksDashboardDir", { link = "Text" })
  vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { link = "Comment" })
end

local function my_highlights()
  vim.api.nvim_set_hl(0, "HoverFloatBorder", { bg = "#000000" })
  vim.api.nvim_set_hl(0, "LspReferenceRead", { bold = true, fg = "LightYellow" })
  vim.api.nvim_set_hl(0, "LspReferenceText", { bold = true, fg = "LightYellow" })
  vim.api.nvim_set_hl(0, "LspReferenceWrite", { bold = true, fg = "LightYellow" })

  vim.api.nvim_set_hl(0, "SignColumn", { bg = "#000000" })
  vim.api.nvim_set_hl(0, "NonText", { fg = "#000000", bg = "#000000" })
  vim.api.nvim_set_hl(0, "LineNr", { bg = "#000000" })

  vim.api.nvim_set_hl(0, "VertSplit", { fg = "#ffffff" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { bold = true, bg = "#1A1A2A" })

  vim.api.nvim_set_hl(0, "Search", { fg = "#969896", bg = "#f0c674" })
  vim.api.nvim_set_hl(0, "IncSearch", { fg = "#282a2e", bg = "#de935f" })
  vim.api.nvim_set_hl(0, "PMenuSel", { fg = "#282a2e", bg = "#c5c8c6" })
  vim.api.nvim_set_hl(0, "Pmenu", { bg = "#0d0d1a", fg = "#ffffff" })
  vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#1a1a2a" })
  vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#3a3a4a" })

  -- nvim-cmp / blink.cmp completion items (actual highlight groups used)
  vim.api.nvim_set_hl(0, "CmpItemAbbr", { fg = "#c6c6c6", bg = "NONE" })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = "#569CD6", bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = "#569CD6", bg = "NONE" })
  vim.api.nvim_set_hl(0, "CmpItemKind", { fg = "#d16969", bg = "NONE" })
  vim.api.nvim_set_hl(0, "CmpItemMenu", { fg = "#6a6a8a", bg = "NONE" })

  -- blink.cmp menu
  vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "#000000", fg = "#c6c6c6" })
  vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = "#161622", fg = "#ffffff" })
  vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#2a2a3e", fg = "#e0e0e0", bold = true })
  vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "#000000", fg = "#c6c6c6" })
  vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { bg = "#161622", fg = "#ffffff" })
  vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { bg = "#161622", fg = "#c6c6c6" })
  vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { bg = "#161622", fg = "#ffffff" })

  vim.api.nvim_set_hl(0, "MatchParen", { fg = "orange", bold = true })

  vim.api.nvim_set_hl(0, "CursorLine", { bold = true, bg = "#1A1A2A" })
  vim.api.nvim_set_hl(0, "CursorLineSign", { bg = "#1A1A1A" })
  vim.api.nvim_set_hl(0, "CursorLineFold", { bg = "#1A1A2A" })

  vim.api.nvim_set_hl(0, "CompeDocumentation", { link = "NormalFloat" })
  vim.api.nvim_set_hl(0, "Conceal", {})

  vim.api.nvim_set_hl(0, "Floaterm", { bg = "black" })
  vim.api.nvim_set_hl(0, "FloatermNC", { bg = "black" })

  vim.api.nvim_set_hl(0, "javaConceptKind", { link = "javaTypeDef" })

  vim.api.nvim_set_hl(0, "ElCommand", { link = "Statusline" })
  vim.api.nvim_set_hl(0, "ElNormal", { link = "Statusline" })
  vim.api.nvim_set_hl(0, "ElVisual", { link = "Statusline" })
  vim.api.nvim_set_hl(0, "ElVisualLine", { link = "Statusline" })
  vim.api.nvim_set_hl(0, "ElVisualBlock", { link = "Statusline" })

  vim.api.nvim_set_hl(0, "Visual", { bg = "#3a3a3a", italic = true })
  vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#FF0000", bg = "#00FF00" })
end

local function set_colors()
  handle_inactive_background()
  my_highlights()
end

vim.g.loaded_falcon = 1
set_colors()

-- Re-apply on any future ColorScheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("custom_colors", { clear = true }),
  callback = set_colors,
})
