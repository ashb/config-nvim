return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  -- Only run this for CSS and JS plugins
  {
    "NvChad/nvim-colorizer.lua",
    enabled = false,
    opts = {
      filetypes = { "css", "javascript" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- lua
        "lua-language-server",
        "stylua",

        -- go
        "gopls",

        -- python
        "debugpy",
        "ruff",

        -- typescript
        -- "typescript-language-server", -- installed via nix

        -- rust
        "rust-analyzer",
        "codelldb",

        -- c++ etc
        "ccls",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- defaults
        "vim",
        "lua",

        "python",
        "go",
        "rust",
        "yaml",
        "just",

        -- web dev
        "html",
        "css",
        "javascript",
        "typescript",
        -- "tsx",
        "json",
        --
      },
    },
    dependencies = {
      -- Justfile support for treesitter
      {
        "IndianBoy42/tree-sitter-just",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        build = function()
          require("nvim-treesitter.parsers").get_parser_configs().just = {
            install_info = {
              url = "https://github.com/IndianBoy42/tree-sitter-just", -- local path or git repo
              files = { "src/parser.c", "src/scanner.cc" },
              branch = "main",
              use_makefile = true, -- this may be necessary on MacOS (try if you see compiler errors)
            },
            maintainers = { "@IndianBoy42" },
          }
          vim.cmd.TSInstall "just"
        end,
      },
    },
  },

  {
    -- replace with neo tree
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      {
        "s1n7ax/nvim-window-picker",
        opts = {
          hint = "floating-big-letter",
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { "neo-tree", "neo-tree-popup", "notify", "incline" },
              -- if the buffer type is one of following, the window will be ignored
              buftype = { "terminal", "quickfix" },
            },
          },
        },
      },
    },
    cmd = { "Neotree" },
    opts = function()
      return require "configs.neo-tree"
    end,
  },

  -- Prety notifications (reload, LSP messages etc)
  {
    "rcarriga/nvim-notify",
    cmd = { "Notifications" },
    event = "VeryLazy",
    opts = {
      stages = "fade",
      render = "compact",
      minimum_width = 10,
      -- timeout = 5000,
    },
    config = function(_, opts)
      local notify = require "notify"
      notify.setup(opts)
      vim.notify = notify
      require("telescope").load_extension "notify"
    end,
  },

  -- Pretty quick fix
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleRefresh", "TroubleToggle" },
    config = function()
      dofile(vim.g.base46_cache .. "trouble")
      require("trouble").setup()
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    -- event = "VeryLazy",
    keys = {
      { "ys", desc = "Surround Add a surrounding pair around a motion" },
      { "yS", desc = "Surround Add a surrounding pair around a motion, on new lines" },
      { "yss", desc = "Surround Add a surrounding pair around current lines" },
      { "ds", desc = "Surround Delete surrounding pair" },
      { "cs", desc = "Surround Change surrounding pair" },
      { "cS", desc = "Surround Change a surrounding pair, putting replacements on new lines" },
      { "S", mode = "v", desc = "Surround Add a surrounding pair around a visual selection" },
      { "gS", mode = "v", desc = "Surround Add a surrounding pair around a visual selection, on new lines" },
    },
    config = true,
  },

  {
    "kevinhwang91/nvim-ufo",
    event = "BufRead",
    ft = { "go", "gomod", "python", "lua" },
    dependencies = {
      { "kevinhwang91/promise-async" },
      {
        "luukvbaal/statuscol.nvim",
        config = function()
          local builtin = require "statuscol.builtin"
          require("statuscol").setup {
            -- foldfunc = "builtin",
            -- setopt = true,
            relculright = true,
            segments = {
              { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
              { text = { "%s" }, click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            },
          }
        end,
      },
    },
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        { desc = "Folds Open All Folds" },
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        { desc = "Folds Close All Folds" },
      },
    },
    opts = function(_, _)
      -- Fold options
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      -- To show number of folded lines
      return require "configs.ufo"
    end,
  },

  -- Custom per-buffer status lines (shows current search, filename etc)
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    opts = function()
      return require "configs.incline"
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function()
      local upstream_conf = require "nvchad.configs.telescope"
      return require("configs.telescope").customize_config(upstream_conf)
    end,
  },

  -- Ensure that some windows are pinned to specific file types (no files in terminal splits etc.)
  {
    "stevearc/stickybuf.nvim",
    event = "VeryLazy",
    opts = function()
      return require "configs.stickybuf"
    end,
  },

  -- Richer git blame view
  {
    "FabijanZulj/blame.nvim",
    config = true,
    cmd = { "BlameToggle" },
  },

  -- "Peek" at impl/definition etc instead of go straight ther
  {
    "dnlhc/glance.nvim",
    cmd = { "Glance" },
    opts = { border = { enable = true } },
    -- Keymaps defined inside configs.lspconfig
  },

  -- Incremental renaming
  {
    "smjonas/inc-rename.nvim",
    config = true,
    cmd = { "IncRename" }
    -- Keymaps defined inside configs.lspconfig
  },

  --[[
  --      UI OVERHAULS
  --]]

  -- Have select menus (code action for instance) show up as a nice popup at the cursor location
  {
    "ray-x/guihua.lua",
    event = "VeryLazy",
    init = function()
      vim.ui.select = require("guihua.gui").select
    end,
  },

  -- Better messages and command prompts!
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = function()
      return require "configs.noice"
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },

  {
    "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git",
    event = "UIEnter",
  },

  -- Tweak indent-blankline config for to use rainbow colors for scope indent colors
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = function(_, opt)
      local highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      }

      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

      return vim.tbl_deep_extend("force", opt, {
        scope = { highlight = highlight },
      })
    end,
  },
}
