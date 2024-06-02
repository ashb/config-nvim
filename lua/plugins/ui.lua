--[[
--
-- My UI plugins grouped together
--
--]]
-- @type LazySpec
local M = {

  {
    "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git",
    config = true,
    main = "rainbow-delimiters.setup",
    event = "UIEnter",
    dependencies = {
      "olimorris/onedarkpro.nvim",
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    keys = {
      { "ys", desc = "Surround Add a surrounding pair around a motion" },
      { "yS", desc = "Surround Add a surrounding pair around a motion, on new lines" },
      { "yss", desc = "Surround Add a surrounding pair around current lines" },
      { "ds", desc = "Surround Delete surrounding pair" },
      { "cs", desc = "Surround Change surrounding pair" },
      { "cS", desc = "Surround Change a surrounding pair, putting replacements on new lines" },
      { "S", desc = "Surround Add a surrounding pair around a visual selection", mode = "v" },
      { "gS", desc = "Surround Add a surrounding pair around a visual selection, on new lines", mode = "v" },
    },
    config = true,
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
}

return M
