-- LSP and completion related plugins!

local specs = {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lspconfig"
    end,
    keys = require("mappings").lsp,
  },
  -- "Peek" at impl/definition etc instead of go straight ther
  {
    "dnlhc/glance.nvim",
    cmd = { "Glance" },
    -- https://github.com/DNLHC/glance.nvim/pull/91/commits
    commit = "806fc2d1f42e53764c91d100cdd5b9edf9c7ab1b",
    opts = {
      border = { enable = true },
      use_trouble_qf = true,
    },
    keys = require("mappings").glance,
  },

  {
    "smjonas/inc-rename.nvim",
    cmd = { "IncRename" },
    keys = require("mappings").increname,
    config = true,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = {
      "DrKJeff16/wezterm-types",
    },
    opts = {
      library = {
        -- Load the wezterm types when the `wezterm` module is required
        -- Needs `DrKJeff16/wezterm-types` to be installed
        { path = "wezterm-types", mods = { "wezterm" } },
      },
    },
  },
}

return specs
