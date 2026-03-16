return {
  -- LSP
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim", opts = {} },
  { "folke/lazydev.nvim", ft = "lua", opts = {
    library = { { path = "luvit-meta/library", words = { "vim%.uv" } } },
  }},
  "justinsgithub/wezterm-types",
  "b0o/schemastore.nvim",

  -- LSP lines
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- Auto-install missing parsers (only once, not every startup)
      local parsers = {
        "bash", "yaml", "markdown", "markdown_inline", "hcl", "lua", "regex",
        "scala", "go", "html", "javascript", "java", "json", "python", "tsx", "nix",
      }
      for _, parser in ipairs(parsers) do
        if not pcall(vim.treesitter.query.get, parser, "highlights") then
          vim.cmd.TSInstall(parser)
        end
      end

      local indent_disable = {
        dart = true, python = true, css = true, html = true,
        gdscript = true, gdscript3 = true, gd = true, Dockerfile = true,
        scala = true, sbt = true,
      }

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true }),
        pattern = "*",
        callback = function(event)
          local lang = event.match
          pcall(vim.treesitter.start, event.buf, lang)
          if not indent_disable[lang] then
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Incremental selection
      vim.keymap.set("n", "<c-space>", function()
        require("nvim-treesitter.incremental_selection").init_selection()
      end, { desc = "Init treesitter selection" })
      vim.keymap.set("v", "<c-space>", function()
        require("nvim-treesitter.incremental_selection").node_incremental()
      end, { desc = "Increment treesitter selection" })
      vim.keymap.set("v", "<M-space>", function()
        require("nvim-treesitter.incremental_selection").node_decremental()
      end, { desc = "Decrement treesitter selection" })
      vim.keymap.set("v", "<c-s>", function()
        require("nvim-treesitter.incremental_selection").scope_incremental()
      end, { desc = "Scope incremental selection" })

      vim.cmd([[highlight IncludedC guibg=#373b41]])

      vim.keymap.set("n", "<leader>tp", ":InspectTree<CR>", { desc = "Treesitter inspect tree" })
    end,
  },
  "nvim-treesitter/nvim-treesitter-textobjects",

  -- Metals (Scala)
  {
    "scalameta/nvim-metals",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-neotest/nvim-nio" },
    ft = { "scala", "sbt", "java" },
    config = function()
      local metals = require("metals")
      local metals_config = metals.bare_config()

      local jdk17_path = vim.fn.system("jenv prefix 17"):gsub("%s+", "")

      metals_config.settings = {
        javaHome = jdk17_path,
        serverProperties = {
          "--add-opens=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED",
          "--add-opens=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED",
          "--add-opens=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED",
          "--add-opens=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED",
          "--add-opens=jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED",
          "--add-opens=jdk.compiler/com.sun.tools.javac.model=ALL-UNNAMED",
          "--add-opens=jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED",
          "--add-opens=jdk.compiler/com.sun.tools.javac.processing=ALL-UNNAMED",
          "--add-opens=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED",
          "--add-opens=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED",
        },
        autoImportBuild = "initial",
        showImplicitArguments = false,
        showInferredType = false,
        excludedPackages = {
          "akka.actor.typed.javadsl",
          "com.github.swagger.akka.javadsl",
        },
        superMethodLensesEnabled = false,
        inlayHints = {
          implicitArguments = { enable = false },
          implicitConversions = { enable = false },
          typeParameters = { enable = false },
          inferredTypes = { enable = false },
          hintsInPatternMatch = { enable = false },
        },
        enableSemanticHighlighting = false,
      }

      metals_config.init_options.statusBarProvider = "on"

      -- Capabilities from blink.cmp, with didChangeWatchedFiles disabled
      local caps = require("blink.cmp").get_lsp_capabilities()
      caps.workspace = caps.workspace or {}
      caps.workspace.didChangeWatchedFiles = { dynamicRegistration = false }
      metals_config.capabilities = caps

      -- No on_attach needed (LspAttach autocmd handles keymaps globally)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nvim-metals", { clear = true }),
        pattern = { "scala", "sbt", "java" },
        callback = function()
          metals.initialize_or_attach(metals_config)
        end,
      })
    end,
  },

  -- Terraform
  {
    "hashivim/vim-terraform",
    config = function()
      vim.g.terraform_fmt_on_save = 1
      vim.g.terraform_align = 1
    end,
  },

  -- Language syntax plugins
  { "mtdl9/vim-log-highlighting" },
  "ekalinin/Dockerfile.vim",
  { "neoclide/jsonc.vim", ft = { "jsonc" } },
  "mustache/vim-mustache-handlebars",

  { "elzr/vim-json", ft = "json" },
  { "goodell/vim-mscgen", ft = "mscgen" },
  "Glench/Vim-Jinja2-Syntax",
  { "ziglang/zig.vim", ft = "zig" },
  { "dmmulroy/tsc.nvim" },
  { "nanotee/sqls.nvim" },
  "jelera/vim-javascript-syntax",
  "othree/javascript-libraries-syntax.vim",
  "leafgarland/typescript-vim",
  "peitalin/vim-jsx-typescript",
  { "vim-scripts/JavaScript-Indent", ft = "javascript" },
  { "pangloss/vim-javascript", ft = { "javascript", "html" } },

  "simrat39/rust-tools.nvim",
  "NoahTheDuke/vim-just",
  { "Vigemus/iron.nvim" },
}
