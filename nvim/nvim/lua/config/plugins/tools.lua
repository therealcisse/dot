return {
  -- Lir file navigator (inlined from trc.lir)
  {
    "tamago324/lir.nvim",
    dependencies = { "tamago324/lir-git-status.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      local actions = require("lir.actions")
      local mark_actions = require("lir.mark.actions")
      local clipboard_actions = require("lir.clipboard.actions")
      local icons = require("config.icons")

      require("lir").setup({
        show_hidden_files = true,
        ignore = { ".DS_Store", "node_modules" },
        devicons = { enable = true },
        mappings = {
          ["Enter"] = actions.edit,
          ["<C-M>"] = actions.edit,
          ["<C-s>"] = actions.split,
          ["v"] = actions.vsplit,
          ["<C-t>"] = actions.tabedit,
          ["-"] = actions.up,
          ["h"] = actions.up,
          ["q"] = actions.quit,
          ["A"] = actions.mkdir,
          ["a"] = actions.newfile,
          ["r"] = actions.rename,
          ["@"] = actions.cd,
          ["Y"] = actions.yank_path,
          ["i"] = actions.toggle_show_hidden,
          ["d"] = actions.delete,
          ["J"] = function()
            mark_actions.toggle_mark()
            vim.cmd("normal! j")
          end,
          ["c"] = clipboard_actions.copy,
          ["x"] = clipboard_actions.cut,
          ["p"] = clipboard_actions.paste,
        },
        float = {
          winblend = 0,
          curdir_window = { enable = false, highlight_dirname = true },
          win_opts = function()
            local width = math.floor(vim.o.columns * 0.7)
            local height = math.floor(vim.o.lines * 0.7)
            return { border = "rounded", width = width, height = height }
          end,
        },
        hide_cursor = false,
        on_init = function()
          vim.api.nvim_buf_set_keymap(
            0, "x", "J",
            ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>',
            { noremap = true, silent = true }
          )
          vim.opt_local.number = true
          vim.opt_local.relativenumber = true
        end,
      })

      require("lir.git_status").setup({ show_ignored = false })

      require("nvim-web-devicons").set_icon({
        lir_folder_icon = { icon = vim.trim(icons.documents.Folder), color = "#569CD6", name = "LirFolderNode" },
      })

      vim.keymap.set("n", "-", [[<Cmd>execute 'e ' .. expand('%:p:h')<CR>]], { noremap = true })
    end,
  },

  -- Toggleterm (inlined from trc.toggleterm)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        start_in_insert = true,
        insert_mappings = true,
        persist_mode = true,
        persist_size = true,
        direction = "horizontal",
        shell = "/opt/homebrew/bin/zsh",
        float_opts = {
          border = "curved",
          winblend = 3,
          highlights = { border = "Normal", background = "Normal" },
        },
      })

      function _G.set_terminal_keymaps()
        local opts = { noremap = true }
        vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

      function _LAZYGIT_TOGGLE() lazygit:toggle() end

      vim.api.nvim_create_user_command("Lazygit", function() _LAZYGIT_TOGGLE() end, {})
      vim.keymap.set("n", "<leader>gl", "<cmd>Lazygit<cr>")
      vim.keymap.set("n", "<leader>T", ":ToggleTerm direction=horizontal<CR>")
    end,
  },

  -- Telescope (inlined from trc.telescope.setup + trc.telescope.mappings)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-lua/popup.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-hop.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
      "nvim-telescope/telescope-github.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "Marskey/telescope-sg",
    },
    config = function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local action_layout = require("telescope.actions.layout")
      local themes = require("telescope.themes")
      local icons = require("config.icons")

      require("telescope").setup({
        defaults = {
          prompt_prefix = icons.ui.Telescope .. " ",
          selection_caret = " ",
          path_display = { "smart" },
          file_ignore_patterns = { ".git/", "node_modules/", "target/", "docs/", ".settings/" },
          winblend = 0,
          layout_strategy = "horizontal",
          layout_config = {
            width = 0.95, height = 0.85, prompt_position = "top",
            horizontal = {
              preview_width = function(_, cols, _)
                return cols > 200 and math.floor(cols * 0.4) or math.floor(cols * 0.6)
              end,
            },
            vertical = { width = 0.9, height = 0.95, preview_height = 0.5 },
            flex = { horizontal = { preview_width = 0.9 } },
          },
          selection_strategy = "reset",
          sorting_strategy = "descending",
          scroll_strategy = "cycle",
          color_devicons = true,
          mappings = {
            i = {
              ["<C-c>"] = actions.close,
              ["<esc>"] = actions.close,
              ["<C-x>"] = false,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-n>"] = "move_selection_next",
              ["<C-e>"] = actions.results_scrolling_down,
              ["<C-y>"] = actions.results_scrolling_up,
              ["<M-p>"] = action_layout.toggle_preview,
              ["<M-m>"] = action_layout.toggle_mirror,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-k>"] = actions.cycle_history_next,
              ["<C-j>"] = actions.cycle_history_prev,
              ["<c-g>s"] = actions.select_all,
              ["<c-g>a"] = actions.add_selection,
              ["<c-space>"] = function(prompt_bufnr)
                require("telescope").extensions.hop._hop_loop(prompt_bufnr, {
                  callback = actions.toggle_selection,
                  loop_callback = actions.send_selected_to_qflist,
                })
              end,
              ["<C-w>"] = function() vim.api.nvim_input("<c-s-w>") end,
            },
            n = {
              ["<C-e>"] = actions.results_scrolling_down,
              ["<C-y>"] = actions.results_scrolling_up,
            },
          },
          borderchars = { "", "", "", "", "", "", "", "" },
          file_previewer = require("telescope.previewers").vim_buffer_cat.new,
          grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
          qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
          history = {
            path = "~/.local/share/nvim/databases/telescope_history.sqlite3",
            limit = 100,
          },
        },
        pickers = {
          find_files = { theme = "ivy" },
          fd = { mappings = { n = { ["kj"] = "close" } } },
          git_branches = { mappings = { i = { ["<C-a>"] = false } } },
        },
        extensions = {
          fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" },
          ast_grep = { command = { "sg", "--json=stream" }, grep_open_files = false, lang = nil },
          live_grep_args = {
            auto_quoting = true,
            mappings = { i = {} },
            theme = themes.get_ivy({ sorting_strategy = "descending" }),
          },
          hop = {
            keys = { "a", "s", "d", "f", "g", "h", "j", "k", "l", ";" },
            sign_hl = { "WarningMsg", "Title" },
            line_hl = { "CursorLine", "Normal" },
            clear_selection_hl = false,
            trace_entry = true,
            reset_selection = true,
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({ hidden = false, sorting_strategy = "descending" }),
          },
        },
      })

      -- Load extensions
      require("telescope").load_extension("ui-select")
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("live_grep_args")
      require("telescope").load_extension("ast_grep")
      pcall(require("telescope").load_extension, "smart_history")
      pcall(require("telescope").load_extension, "frecency")

      -- Telescope keymaps (from trc.telescope.mappings)
      local sorters = require("telescope.sorters")
      local builtin = require("telescope.builtin")

      local live_grep_opts = {
        short_path = true,
        word_match = "-w",
        only_sort_text = true,
        layout_strategy = "vertical",
        sorter = sorters.get_fzy_sorter(),
      }

      vim.keymap.set("n", "<C-g>/", function()
        require("telescope").extensions.live_grep_args.live_grep_args(live_grep_opts)
      end)
      vim.keymap.set("n", "<leader>/", function()
        require("telescope").extensions.live_grep_args.live_grep_args(live_grep_opts)
      end)
      vim.keymap.set("n", "<C-g>]", function()
        require("telescope").extensions.ast_grep.ast_grep(live_grep_opts)
      end)
      vim.keymap.set("n", "<C-Y>", function()
        require("telescope").extensions.yaml_schema.yaml_schema()
      end)
      vim.keymap.set("n", "<C-p>", function() builtin.find_files() end)
      vim.keymap.set("n", "<leader>p", function() builtin.find_files() end)
      vim.keymap.set("n", "<leader>fs", function() builtin.find_files() end)
      vim.keymap.set("n", "<leader>fd", function() builtin.find_files() end)
      vim.keymap.set("n", "<leader>ep", function() builtin.find_files({ cwd = vim.fn.stdpath("config") .. "/lua/config/plugins" }) end)
      vim.keymap.set("n", "<leader>ec", function() builtin.find_files({ cwd = vim.fn.stdpath("config") }) end)
      vim.api.nvim_set_keymap("c", "<c-r><c-r>", "<Plug>(TelescopeFuzzyCommandSearch)", { noremap = false, nowait = true })
    end,
  },

  -- Yaml companion
  {
    "someone-stole-my-name/yaml-companion.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("yaml_schema")
    end,
  },

}
