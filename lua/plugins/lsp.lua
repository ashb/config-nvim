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
  -- Show more than one diagnostic on current line
  {
    -- This on needs to be loaded before nvim-lspconfig else it doesn't seem to work :shrug:
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = { "LspAttach" },
    config = function()
      require("lsp_lines").setup()
      vim.diagnostic.config { virtual_lines = { only_current_line = true } }
    end,
  },
  -- And since we have the above, hide the virtual text one the current line
  {
    "luozhiya/lsp-virtual-improved.nvim",
    event = { "LspAttach" },
    config = function()
      require("lsp-virtual-improved").setup()
      vim.diagnostic.config { virtual_text = false, virtual_improved = { prefix = "", current_line = "hide" } }
    end,
  },
  -- "Peek" at impl/definition etc instead of go straight ther
  {
    "dnlhc/glance.nvim",
    cmd = { "Glance" },
    opts = { border = { enable = true } },
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
