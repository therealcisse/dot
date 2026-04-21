return {
  -- Colorscheme
  {
    "tiagovla/tokyodark.nvim",
    opts = {},
    config = function(_, opts)
      vim.cmd([[colorscheme tokyodark]])
    end,
  },

  -- Statusline (lualine)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- stylua: ignore
      local colors = {
        blue   = "#80a0ff",
        cyan   = "#79dac8",
        black  = "#080808",
        white  = "#c6c6c6",
        red    = "#ff5189",
        violet = "#d183e8",
        grey   = "#303030",
      }

      local bubbles_theme = {
        normal = {
          a = { fg = colors.black, bg = colors.violet },
          b = { fg = colors.white, bg = colors.grey },
          c = { fg = colors.white },
        },
        insert = { a = { fg = colors.black, bg = colors.blue } },
        visual = { a = { fg = colors.black, bg = colors.cyan } },
        replace = { a = { fg = colors.black, bg = colors.red } },
        inactive = {
          a = { fg = colors.white, bg = colors.black },
          b = { fg = colors.white, bg = colors.black },
          c = { fg = colors.white },
        },
      }

      require("lualine").setup({
        options = {
          theme = bubbles_theme,
          component_separators = "",
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
          lualine_b = { "filename", "branch" },
          lualine_c = { "%=" },
          lualine_x = { "diagnostics" },
          lualine_y = { "filetype", "progress" },
          lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
        },
        inactive_sections = {
          lualine_a = { "filename" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "location" },
        },
        tabline = {},
        extensions = {},
      })
    end,
  },

  -- Noice (cmdline, messages)
  {
    "folke/noice.nvim",
    event = "VimEnter",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("noice").setup({
        cmdline = {
          enabled = true,
          format = {
            cmdline = { icon = ">" },
            search_down = { icon = "search v" },
            search_up = { icon = "search ^" },
            filter = { icon = "$" },
            lua = { icon = "lua" },
            help = { icon = "?" },
          },
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        notify = { enabled = false },
        messages = { enabled = false },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = false,
        },
      })
    end,
  },

  -- Snacks
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      indent = { enabled = true },
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            { icon = " ", key = "n", desc = "New File", action = ":enew" },
          },
        },
        sections = {
          { section = "header" },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          { section = "keys", gap = 1, padding = 1 },
        },
      },
      notifier = { enabled = true, timeout = 3000 },
      quickfile = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = true },
      styles = {
        notification = { wo = { wrap = true } },
        terminal = {
          bo = { filetype = "snacks_terminal" },
          wo = { winbar = " Terminal ", winhighlight = "Normal:Normal,FloatBorder:FloatBorder" },
          border = "rounded",
        },
      },
    },
    keys = {
      { "<c-/>", function() Snacks.terminal("zsh", { win = { border = "rounded" } }) end, desc = "Toggle Terminal" },
      { "<leader>T", function() Snacks.terminal({ "zsh" }, { win = { position = "bottom", height = 0.25, border = "rounded" } }) end, desc = "Horizontal Terminal" },
      { "<leader>gl", function() Snacks.terminal("lazygit", { win = { border = "rounded" } }) end, desc = "Lazygit" },
      {
        "<leader>N",
        desc = "Neovim News",
        function()
          Snacks.win({
            file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
            width = 0.6,
            height = 0.6,
            wo = { spell = false, wrap = false, signcolumn = "yes", statuscolumn = " ", conceallevel = 3 },
          })
        end,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          _G.dd = function(...) Snacks.debug.inspect(...) end
          _G.bt = function() Snacks.debug.backtrace() end
          vim.print = _G.dd

          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle
            .option("background", { off = "light", on = "dark", name = "Dark Background" })
            :map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
        end,
      })
    end,
  },

  -- Winbar
  {
    "fgheng/winbar.nvim",
    config = function()
      require("winbar").setup({
        enabled = true,
        show_file_path = true,
        show_symbols = true,
        colors = { path = "", file_name = "", symbols = "" },
        icons = { file_icon_default = "", seperator = ">", editor_state = "", lock_icon = "" },
        exclude_filetype = {
          "scratch", "help", "startify", "dashboard", "packer",
          "neogitstatus", "NvimTree", "Trouble", "alpha",
          "Outline", "spectre_panel", "toggleterm", "qf",
        },
      })
    end,
  },

  -- Dressing
  { "stevearc/dressing.nvim", event = "User PackerDefered" },

  -- Colorizer
  "norcalli/nvim-colorizer.lua",

  -- Windows (auto-resize)
  {
    "anuvyklack/windows.nvim",
    dependencies = { "anuvyklack/middleclass", "anuvyklack/animation.nvim" },
    config = function()
      vim.o.winwidth = 10
      vim.o.winminwidth = 10
      vim.o.equalalways = false

      require("windows").setup({
        autowidth = {
          enable = false,
          winwidth = 5,
          filetype = { help = 2 },
        },
        ignore = {
          buftype = { "quickfix" },
          filetype = { "undotree", "gundo", "NvimTree", "neo-tree", "Outline" },
        },
        animation = {
          enable = true,
          duration = 300,
          fps = 30,
          easing = "in_out_sine", ---@diagnostic disable-line
        },
      })
    end,
  },
  { "anuvyklack/animation.nvim" },

  -- Neoscroll
  {
    "karb94/neoscroll.nvim",
    opts = {},
    enabled = true,
    config = function()
      local neoscroll = require("neoscroll")

      local keymap = {
        ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 100 }) end,
        ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 100 }) end,
        ["<C-y>"] = function() neoscroll.scroll(-0.1, { move_cursor = false, duration = 50 }) end,
        ["<C-e>"] = function() neoscroll.scroll(0.1, { move_cursor = false, duration = 50 }) end,
        ["zt"] = function() neoscroll.zt({ half_win_duration = 150 }) end,
        ["zz"] = function() neoscroll.zz({ half_win_duration = 150 }) end,
        ["zb"] = function() neoscroll.zb({ half_win_duration = 150 }) end,
      }

      local modes = { "n", "v", "x" }
      for key, func in pairs(keymap) do
        vim.keymap.set(modes, key, func)
      end

      neoscroll.setup({
        pre_hook = function(info) if info == "cursorline" then vim.wo.cursorline = false end end,
        post_hook = function(info) if info == "cursorline" then vim.wo.cursorline = true end end,
      })
    end,
  },

  -- Devicons
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup({})
    end,
  },

}
