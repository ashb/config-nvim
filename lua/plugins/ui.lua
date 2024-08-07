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
  { "tiagovla/scope.nvim", event = "UIEnter", cmd = { "ScopeMoveBuf" }, config = true },

  -- Scope breadcumbs at the top of the split -- current class, function etc.
  { "Bekaboo/dropbar.nvim", event = "BufWinEnter", config = true },

  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    config = true,
    keys = require("mappings").trouble,
  },
  {
    "folke/which-key.nvim",
    version = "*",
    event = "VeryLazy",
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
}

return M
