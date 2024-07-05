-- adds indentation guides (i.e. show a vertical "gutter"/bar to visually join up indents
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "User PersistedLoadPost", "BufReadPost", "BufNewFile" },
  dependencies = {
    "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git",
  },
  opts = function(_, opt)
    local highlight = {
      "RainbowDelimiterRed",
      "RainbowDelimiterYellow",
      "RainbowDelimiterBlue",
      "RainbowDelimiterOrange",
      "RainbowDelimiterGreen",
      "RainbowDelimiterViolet",
      "RainbowDelimiterCyan",
    }

    local hooks = require "ibl.hooks"
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
    return vim.tbl_deep_extend("force", opt, {
      scope = { char = "│", highlight = highlight },
      indent = { char = "│" },
    })
  end,
}
