--[[
--
-- My UI plugins grouped together
--
--]]
-- @type LazySpec
local M = {

  {
    -- Color each delimiter different. Useful to find matching open/close bracket/brace/parenthesis etc when there are many
    "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git",
    config = true,
    main = "rainbow-delimiters.setup",
    event = "UIEnter",
    dependencies = {
      "olimorris/onedarkpro.nvim",
    },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "famiu/bufdelete.nvim",
    },
    opts = {
      options = {
        themeable = true,
        close_command = "Bdelete %d",
        separator_style = "slant",
        hover = {
          enabled = true,
          delay = 50,
          reveal = { "close" },
        },
      },
    },
    event = "UIEnter",
  },
  {
    -- Delete buffers while keeping layout
    "famiu/bufdelete.nvim",
    cmd = { "Bdelete", "Bwipeout" },
    keys = require("mappings").bufdelete,
  },
  -- Pet tab next/previous history
  {
    "tiagovla/scope.nvim",
    event = "UIEnter",
    cmd = { "ScopeMoveBuf" },
    config = function()
      require("scope").setup()
      require("telescope").load_extension "scope"
    end,
  },

  -- Scope breadcumbs at the top of the split -- current class, function etc.
  { "Bekaboo/dropbar.nvim", event = "BufWinEnter", config = true },

  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
      modes = {
        symbols = {
          desc = "document symbols (custom filtering)",
          mode = "lsp_document_symbols",
          win = {
            type = "float",
            relative = "cursor",
            anchor = "NW",
            -- position = { 0, 0 },
            border = "rounded",
            size = { width = 0.3, height = 0.3 },
          },
          pinned = true,
          filter = {
            any = {
              ["not"] = { kind = "Variable" },
              ft = { "help", "markdown" },
            },
          },
          keys = {
            ["<cr>"] = "jump_close",
            ["<esc>"] = "close",
          },
        },
      },
    },
    keys = require("mappings").trouble,
  },
  {
    "folke/which-key.nvim",
    -- fix for https://github.com/folke/which-key.nvim/pull/974 -- not yet tagged in a release
    version = "7ea0fe4fea8770ef1b3896a49e72c79f889ab230",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>w", group = "LSP workspace" },
        { "<leader>u", group = "Toggles" },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    config = true,
    event = "User FilePost",
    opts = {
      on_attach = function(bufnr)
        local keys = require("mappings").gitsigns

        local map = vim.keymap.set
        local function set(tbl)
          tbl = vim.tbl_extend("keep", tbl, { buffer = bufnr })

          local mode = tbl["mode"] or "n"
          local lhs, rhs = tbl[1], tbl[2]
          tbl["mode"] = nil
          tbl[1] = nil
          tbl[2] = nil
          map(mode, lhs, rhs, tbl)
        end

        for _, k in ipairs(keys) do
          set(k)
        end
      end,
    },
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      persist_mode = false,
      persist_size = true,
      highlights = {
        NormalFloat = { link = "NormalFloat" },
        FloatBorder = { link = "FloatBorder" },
      },
      float_opts = {
        border = "curved",
        height = function()
          return math.ceil(vim.o.lines * 0.7)
        end,
        width = function()
          return math.ceil(vim.o.columns * 0.7)
        end,
      },
    },
    keys = require("mappings").toggleterm,
  },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        names = false,
      },
    },
    cmd = { "ColorizerToggle", "ColorizerAttachToBuffer" },
  },

  -- Have select menus (code action for instance) show up as a nice popup at the cursor location
  {
    "ray-x/guihua.lua",
    event = "VeryLazy",
    opts = {
      list_sel_hl = "PmenuSel",
      list_bg = "Pmenu",
    },
    init = function()
      vim.ui.select = require("guihua.gui").select
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufWinEnter" },
    opts = {
      keywords = {
        -- Disable the "INFO" default alt.
        NOTE = { alt = {} },
      },
    },
  },

  -- Pretty display of Markdown files inline in the buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    cmd = { "RenderMarkdown" },
  },

  -- Automatically resize buffers proportionaly when window size changes
  { "kwkarlwang/bufresize.nvim" },

  {
    "s1n7ax/nvim-window-picker",
    opts = {
      show_prompt = false,
      hint = "floating-big-letter",
      filter_rules = {
        include_current_win = false,
        autoselect_one = true,
        -- filter using buffer options
        bo = {
          -- if the file type is one of following, the window will be ignored
          filetype = { "neo-tree", "neo-tree-popup", "notify", "incline", "noice" },
          -- if the buffer type is one of following, the window will be ignored
          buftype = { "terminal", "quickfix" },
        },
      },
    },
  },
  -- Smarter folding
  {
    "chrisgrieser/nvim-origami",
    event = "VeryLazy",
    ---@module 'origami'
    ---@type Origami.config
    opts = {
      foldtext = {
        lineCount = {
          template = "󰁂 %d",
          hlgroup = "MoreMsg",
        },
      },
      autoFold = {
        enabled = true,
      },
    },
    dependencies = {
      -- Clickable status column handlers
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
    init = function()
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldcolumn = "1"
      -- recommended: disable vim's auto-folding
      vim.opt.fillchars:append [[fold: ,foldopen:,foldsep: ,foldclose:]]
    end,
  },

  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      dashboard = {
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            -- stdpath("config") is wrong because XDG_CONFIG_HOME is unset after startup (see nvimrc.lua)
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.opt.rtp:get()[1]})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      gh = {
        enabled = true,
      },
      picker = {
        matcher = {
          cwd_bonus = true, -- give bonus for matching files in the cwd
          frecency = true, -- frecency bonus
          history_bonus = true, -- give more weight to chronological order
        },
        win = {
          input = {
            keys = {
              ["<PageDown>"] = { "list_scroll_down", mode = { "i", "n" } },
              ["<PageUp>"] = { "list_scroll_up", mode = { "i", "n" } },
            },
          },
        },
        debug = {
          scores = false, -- show scores in the list
        },
      },
      scope = {},
      toggle = {},
      indent = {
        scope = {
          hl = {
            "RainbowDelimiterRed",
            "RainbowDelimiterYellow",
            "RainbowDelimiterBlue",
            "RainbowDelimiterOrange",
            "RainbowDelimiterGreen",
            "RainbowDelimiterViolet",
            "RainbowDelimiterCyan",
          },
        },
      },
      words = {},
    },
    keys = require("mappings").snacks,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          Snacks.toggle.option("spell", { name = "Spelling" }):map "<leader>us"
          Snacks.toggle.option("relativenumber", { name = "Relative number" }):map "<leader>ur"
          Snacks.toggle.option("number", { name = "Line numbers" }):map "<leader>un"
          Snacks.toggle.treesitter():map "<leader>uT"
          Snacks.toggle.indent():map "<leader>ug"
        end,
      })
    end,
  },
}

return M
