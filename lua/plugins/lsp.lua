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
}

return specs
