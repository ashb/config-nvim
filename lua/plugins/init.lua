-- @type LazySpec
local M = {
  {
    "olimorris/persisted.nvim",
    lazy = false, -- make sure the plugin is always loaded at startup
    opts = {
      autoload = true,
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
    keys = require("mappings").conform,
  },
  {
    "numToStr/Comment.nvim",
    opts = {
      toggler = { line = "<leader>/" },
    },
    keys = { { "<leader>/" } },
  },
}

return M
