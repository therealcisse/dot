return {
  -- Surround
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({ move_cursor = "begin" })
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    config = function()
      local npairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      local cond = require("nvim-autopairs.conds")

      npairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string", "source" },
          javascript = { "string", "template_string" },
          java = false,
        },
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
        fast_wrap = {
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'", "`" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
          offset = 0,
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "PmenuSel",
          highlight_grey = "LineNr",
        },
      })

      npairs.add_rule(
        Rule("|", "|"):with_pair(cond.invert(cond.not_filetypes({ "rust", "zig", "ruby" })))
      )
    end,
  },

  -- Comment
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        opleader = { line = "gc", block = "gb" },
        mappings = { basic = true, extra = true },
        toggler = { line = "gcc", block = "gbc" },
        pre_hook = nil,
        post_hook = nil,
        ignore = nil,
      })
      require("Comment.ft").set("lua", { "--%s", "--[[%s]]" })
    end,
  },

  -- Pounce
  {
    "rlane/pounce.nvim",
    config = function()
      require("pounce").setup({
        accept_keys = "JFKDLSAHGNUVRBYTMICEOXWPQZ",
        accept_best_key = "<enter>",
        multi_window = true,
        debug = false,
      })

      local map = vim.keymap.set
      map("n", "gs", function() require("pounce").pounce({}) end)
      map("n", "gS", function() require("pounce").pounce({ input = { reg = "/" } }) end)
      map("x", "gs", function() require("pounce").pounce({}) end)
      map("o", "gs", function() require("pounce").pounce({}) end)
    end,
  },

  -- Matchparen
  {
    "monkoose/matchparen.nvim",
    branch = "main",
    config = function()
      require("matchparen").setup({
        enabled = true,
        hl_group = "MatchParen",
      })
    end,
  },
  -- vim-matchup matchparen offscreen
  { "andymass/vim-matchup", init = function() vim.g.matchup_matchparen_offscreen = {} end },

  -- LuaSnip
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")
      local types = require("luasnip.util.types")

      ls.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
        ext_opts = {
          [types.choiceNode] = {
            active = { virt_text = { { " <- Current Choice", "NonTest" } } },
          },
        },
      })

      -- Load ft snippets from config.snips
      for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/config/snips/ft/*.lua", true)) do
        loadfile(ft_path)()
      end

      vim.keymap.set({ "i", "s" }, "<c-k>", function()
        if ls.expand_or_jumpable() then ls.expand_or_jump() end
      end, { silent = true })

      vim.keymap.set({ "i", "s" }, "<c-j>", function()
        if ls.jumpable(-1) then ls.jump(-1) end
      end, { silent = true })

      vim.keymap.set("i", "<c-l>", function()
        if ls.choice_active() then ls.change_choice(1) end
      end)

      vim.keymap.set("i", "<c-u>", require("luasnip.extras.select_choice"))
    end,
  },

  -- Blink.cmp
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    version = "v1.*",
    lazy = false,
    opts = {
      enabled = function()
        return not vim.tbl_contains({ "markdown" }, vim.bo.filetype)
          and vim.bo.buftype ~= "prompt"
          and vim.b.completion ~= false
      end,
      keymap = {
        preset = "default",
        ["<C-y>"] = { function(cmp) cmp.show({}) end },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-e>"] = { "select_and_accept", "fallback" },
        ["<C-j>"] = { "snippet_forward", "fallback" },
        ["<C-k>"] = { "snippet_backward", "fallback" },
      },
      snippets = { preset = "luasnip" },
      completion = {
        trigger = { show_on_keyword = true },
        list = { selection = { auto_insert = true, preselect = true } },
        menu = {
          draw = {
            treesitter = { "lsp" },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
          auto_show = false,
          scrollbar = false,
          border = "rounded",
        },
        documentation = {
          auto_show_delay_ms = 500,
          auto_show = true,
          treesitter_highlighting = true,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = true, show_with_menu = false },
      },
      cmdline = {
        completion = { menu = { auto_show = false } },
        keymap = {
          ["<C-e>"] = { "accept" },
          ["<CR>"] = { "accept_and_enter", "fallback" },
        },
        sources = function()
          local type = vim.fn.getcmdtype()
          if type == "/" or type == "?" then return { "buffer" } end
          if type == ":" then return { "cmdline" } end
          return {}
        end,
      },
      sources = {
        default = function(_)
          local success, node = pcall(vim.treesitter.get_node)
          if vim.bo.filetype == "lua" then
            return { "lsp", "path" }
          elseif success and node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
            return { "buffer" }
          else
            return { "lsp", "path", "snippets", "buffer" }
          end
        end,
        providers = {
          lsp = {
            name = "lsp",
            enabled = true,
            module = "blink.cmp.sources.lsp",
            fallbacks = { "snippets", "luasnip", "buffer" },
            score_offset = 70,
          },
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            score_offset = 3,
            fallbacks = { "snippets", "luasnip", "buffer" },
            opts = {
              trailing_slash = false,
              label_trailing_slash = true,
              get_cwd = function(context)
                return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
              end,
              show_hidden_files_by_default = true,
            },
          },
          buffer = {
            name = "Buffer",
            enabled = true,
            max_items = 3,
            module = "blink.cmp.sources.buffer",
            min_keyword_length = 4,
          },
          snippets = {
            name = "snippets",
            enabled = true,
            max_items = 3,
            module = "blink.cmp.sources.snippets",
            min_keyword_length = 4,
            score_offset = 80,
          },
        },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
        kind_icons = {
          Copilot = "",
          Text = "", Method = "", Function = "", Constructor = "",
          Field = "", Variable = "", Property = "",
          Class = "", Interface = "", Struct = "", Module = "",
          Unit = "", Value = "", Enum = "", EnumMember = "",
          Keyword = "", Constant = "",
          Snippet = "", Color = "", File = "", Reference = "",
          Folder = "", Event = "", Operator = "", TypeParameter = "",
        },
      },
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },
    },
  },

  -- Render-markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
    ft = { "markdown" },
    config = function()
      require("render-markdown").setup({
        enabled = true,
        file_types = { "markdown" },
        latex = { enabled = false },
        indent = { enabled = false, per_level = 2, skip_level = 1, skip_heading = false },
        sign = { enabled = true, highlight = "RenderMarkdownSign" },
        link = {
          enabled = true,
          footnote = { superscript = true, prefix = "", suffix = "" },
          image = " ", email = " ", hyperlink = " ",
          highlight = "RenderMarkdownLink",
          wiki = { icon = " ", highlight = "RenderMarkdownWikiLink" },
          custom = {
            web = { pattern = "^http", icon = " " },
            youtube = { pattern = "youtube%.com", icon = " " },
            github = { pattern = "github%.com", icon = " " },
            neovim = { pattern = "neovim%.io", icon = " " },
            stackoverflow = { pattern = "stackoverflow%.com", icon = " " },
            discord = { pattern = "discord%.com", icon = " " },
            reddit = { pattern = "reddit%.com", icon = " " },
          },
        },
        pipe_table = {
          enabled = true, preset = "none", style = "full", cell = "padded",
          padding = 1, min_width = 0,
          border = { "", "", "", "", "", "", "", "", "", "", "" },
          alignment_indicator = "",
          head = "RenderMarkdownTableHead",
          row = "RenderMarkdownTableRow",
          filler = "RenderMarkdownTableFill",
        },
        quote = { enabled = true, icon = "", repeat_linebreak = false, highlight = "RenderMarkdownQuote" },
        checkbox = {
          enabled = true, position = "inline",
          unchecked = { icon = " ", highlight = "RenderMarkdownUnchecked", scope_highlight = nil },
          checked = { icon = " ", highlight = "RenderMarkdownChecked", scope_highlight = nil },
          custom = {
            todo = { raw = "[-]", rendered = " ", highlight = "RenderMarkdownTodo", scope_highlight = nil },
          },
        },
      })
    end,
  },

  -- Spectre
  {
    "windwp/nvim-spectre",
    config = function()
      vim.keymap.set("n", "<leader>S", function() require("spectre").toggle() end, { desc = "Toggle Spectre" })
      vim.keymap.set("n", "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, { desc = "Search current word" })
      vim.keymap.set("v", "<leader>sw", function() require("spectre").open_visual() end, { desc = "Search current word" })
      vim.keymap.set("n", "<leader>sp", function() require("spectre").open_file_search({ select_word = true }) end, { desc = "Search on current file" })
    end,
  },

  -- Dial (increment/decrement)
  "monaqa/dial.nvim",

  -- Text manipulation
  "godlygeek/tabular",
  "tpope/vim-repeat",
  "tpope/vim-abolish",
  "tpope/vim-characterize",
  { "tpope/vim-dispatch", cmd = { "Dispatch", "Make" } },
  { "AndrewRadev/splitjoin.vim", keys = { "gJ", "gS" } },
  { "FooSoft/vim-argwrap", cmd = { "ArgWrap" } },
  "matze/vim-move",
  {
    "vim-scripts/ReplaceWithRegister",
    keys = {
      { "mr", "<Plug>ReplaceWithRegisterOperator", { "n", "v" }, desc = "ReplaceWithRegisterOperator" },
    },
  },
  { "gbprod/stay-in-place.nvim", config = function() require("stay-in-place").setup({}) end },

  -- Text objects
  { "kana/vim-textobj-entire", dependencies = { "kana/vim-textobj-user" } },
  { "kana/vim-textobj-indent", dependencies = { "kana/vim-textobj-user" } },
  { "kana/vim-textobj-line", dependencies = { "kana/vim-textobj-user" } },
  { "coderifous/textobj-word-column.vim", dependencies = { "kana/vim-textobj-user" } },
  { "mattn/vim-textobj-url", dependencies = { "kana/vim-textobj-user" } },

  -- Treesitter hint textobject
  {
    "mfussenegger/nvim-ts-hint-textobject",
    config = function()
      vim.cmd([[omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>]])
      vim.cmd([[vnoremap <silent> m :lua require('tsht').nodes()<CR>]])
    end,
  },

  -- Search enhancements
  {
    "haya14busa/vim-asterisk",
    config = function()
      vim.cmd([[map *  <Plug>(asterisk-z*)]])
      vim.cmd([[map g* <Plug>(asterisk-gz*)]])
      vim.cmd([[map #  <Plug>(asterisk-z#)]])
      vim.cmd([[map g# <Plug>(asterisk-gz#)]])
    end,
  },
  "google/vim-searchindex",

  -- Zen mode
  {
    "folke/zen-mode.nvim",
    dependencies = { "folke/twilight.nvim" },
    config = function()
      require("zen-mode").setup({
        window = {
          backdrop = 1, height = 0.9, width = 0.85,
          options = { signcolumn = "no", number = false, relativenumber = false },
        },
        plugins = {
          gitsigns = { enabled = false },
          tmux = { enabled = false },
          twilight = { enabled = true },
        },
      })
      require("twilight").setup({ context = -1, treesitter = false })
    end,
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    event = "BufReadPre",
    cmd = { "TroubleToggle", "Trouble" },
    config = function()
      require("trouble").setup({ auto_open = false, use_diagnostic_signs = true })
    end,
  },

  -- Goto preview
  {
    "rmagatti/goto-preview",
    config = function()
      require("goto-preview").setup({})
    end,
  },

  -- Last place
  {
    "ethanholz/nvim-lastplace",
    event = "BufRead",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
        lastplace_open_folds = true,
      })
    end,
  },

  -- Grapple (file tagging)
  {
    "cbochs/grapple.nvim",
    opts = { scope = "git", icons = true, status = false },
    keys = {
      { "<leader>g", "<cmd>Grapple toggle<cr>", desc = "Tag a file" },
      { "<c-e>", "<cmd>Grapple toggle_tags<cr>", desc = "Toggle tags menu" },
      { "<c-h>", "<cmd>Grapple select index=1<cr>", desc = "Select first tag" },
      { "<c-t>", "<cmd>Grapple select index=2<cr>", desc = "Select second tag" },
      { "<c-n>", "<cmd>Grapple select index=3<cr>", desc = "Select third tag" },
      { "<c-s>", "<cmd>Grapple select index=4<cr>", desc = "Select fourth tag" },
      { "<c-s-n>", "<cmd>Grapple cycle_tags next<cr>", desc = "Go to next tag" },
      { "<c-s-p>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Go to previous tag" },
    },
    dependencies = { { "nvim-tree/nvim-web-devicons", lazy = true } },
  },

  -- Quickfix enhancements
  "romainl/vim-qf",

  -- Better virtual text
  { "isaksamsten/better-virtual-text.nvim" },

  -- Mini.nvim
  { "echasnovski/mini.nvim", version = false },

  -- Bufdelete
  { "famiu/bufdelete.nvim", cmd = "Bdelete" },

  -- Startuptime

  -- Auto mkdir
  "DataWraith/auto_mkdir",
  "tpope/vim-unimpaired",
  "tommcdo/vim-lion",
  "tpope/vim-eunuch",
}
