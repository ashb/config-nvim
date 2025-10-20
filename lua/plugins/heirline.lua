local specs = {
  "rebelot/heirline.nvim",
  config = function()
    require("heirline").setup(require "configs.heirline")
  end,
  dependencies = {
    "lewis6991/gitsigns.nvim",
    "nvim-tree/nvim-web-devicons",
    "olimorris/onedarkpro.nvim", -- to be able to load the theme
  },
  event = "UIEnter",
}
return vim.env.SLINE == "heirline" and specs or {}
