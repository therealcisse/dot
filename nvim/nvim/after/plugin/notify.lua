-- if not pcall(require, "plenary") then
--   return
-- end
--
-- local log = require("plenary.log").new {
--   plugin = "notify",
--   level = "debug",
--   use_console = false,
-- }
--
-- vim.notify = function(msg, level, opts)
--   log.info(msg, level, opts)
--
--   require "notify"(msg, level, opts)
-- end

local status_ok, notify = pcall(require, "notify")
if not status_ok then
  return
end

local icons = require "trc.icons"

notify.setup {
  -- Animation style (see below for details)
  stages = "fade_in_slide_out",

  -- Function called when a new window is opened, use for changing win settings/config
  on_open = nil,

  -- Function called when a window is closed
  on_close = nil,

  -- Render function for notifications. See notify-render()
  render = "default",

  -- Default timeout for notifications
  timeout = 3 * 175,

  -- For stages that change opacity this is treated as the highlight behind the window
  -- Set this to either a highlight group or an RGB hex value e.g. "#000000"
  background_colour = "Normal",

  -- Minimum width for notification windows
  minimum_width = 10,

  -- Icons for the different levels
  icons = {
    ERROR = icons.diagnostics.Error,
    WARN = icons.diagnostics.Warning,
    INFO = icons.diagnostics.Information,
    DEBUG = icons.ui.Bug,
    TRACE = icons.ui.Pencil,
  },
}

vim.notify = notify
