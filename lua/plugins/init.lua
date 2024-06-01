-- @type LazySpec
local M = {
  {
    "olimorris/persisted.nvim",
    lazy = false, -- make sure the plugin is always loaded at startup
    opts = {
      autoload = true,
    },
    config = function(_, opts)
      require("persisted").setup(opts)
      vim.schedule(function()
        require("telescope").load_extension "persisted"
      end)
    end,
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
    keys = {
      { "<leader>/", mode = { "n" } },
      { "<leader>/", "<Plug>(comment_toggle_linewise_visual)", mode = { "v" } },
    },
  },
}

return M
