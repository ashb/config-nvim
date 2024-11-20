return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-symbols.nvim",
    },
    opts = {

      defaults = {
        prompt_prefix = "   ",
        selection_caret = " 󰄾 ",
        entry_prefix = "   ",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        border = true, -- # But we set the fg and bg theme the same!
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
      },
      pickers = {
        builtin = {
          include_extensions = true,
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      require "_local.telescope_extensions"
    end,
    cmd = { "Telescope" },
    keys = require("mappings").telescope,
  },
}
