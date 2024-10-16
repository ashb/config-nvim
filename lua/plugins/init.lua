-- @type LazySpec
local M = {
  {
    -- Re-open the workspace based on current dir etc when running `nvim`
    "olimorris/persisted.nvim",
    lazy = false, -- make sure the plugin is always loaded at startup
    opts = {
      autoload = true,
      should_save = function()
        -- Do not save the session for these filetypes
        if vim.bo.filetype == "gitcommit" then
          return false
        end
        return true
      end,
    },
    config = function(_, opts)
      require("persisted").setup(opts)
      vim.schedule(function()
        require("telescope").load_extension "persisted"
      end)
    end,
  },
  {
    -- Lightweight yet powerful formatter plugin for Neovim
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        nix = { "nix" },
      },
      formatters = {
        nix = {
          inherit = false,
          stdin = false,
          command = "nix",
          args = { "fmt", "$FILENAME" },
        },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
    },
    keys = require("mappings").conform,
  },
  {
    -- Quickly toggle comments on lines/blocks
    "numToStr/Comment.nvim",
    opts = {
      toggler = { line = "<leader>/" },
    },
    keys = {
      { "<leader>/", mode = { "n" } },
      { "<leader>/", "<Plug>(comment_toggle_linewise_visual)", mode = { "v" } },
    },
  },

  {
    -- Surround words/lines with characters, i.e. "quote this word" or "change double quote to backticks"
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
}

return M
