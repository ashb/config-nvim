-- Colorscheme
return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- Ensure it loads first
    config = function(_, opts)
      opts.colors.darkest_black = require "onedarkpro.lib.color"("#1b1f27"):darker(1):to_css()
      require("onedarkpro").setup(opts)
      -- Set it now (for loading), and also set it again afterwards so the buffline etc doesn't get confused on reload
      vim.cmd.colorscheme "onedark"
      vim.schedule_wrap(vim.cmd.colorscheme) "onedark"
    end,
    lazy = false,
    opts = {
      -- Disable the filetype specific sematic tokens (`@variable.python`) etc
      filetypes = {
        all = false,
      },

      highlight_inactive_windows = false,
      highlights = {
        ViModeNormal = { bg = "${green}", fg = "${bg}" },
        ViModeInsert = { bg = "${blue}", fg = "${bg}" },
        ViModeCommand = { bg = "${purple}", fg = "${bg}" },
        ViModeVisual = { bg = "${yellow}", fg = "${bg}" },
        ViModeReplace = { bg = "${red}", fg = "${bg}" },

        CurSearch = { bg = "${violet}", fg = "${bg}" },
        NeoTreeDirectoryIcon = { fg = "${blue}" },
        NeoTreeRootName = { fg = "${white}", bold = true, italic = true },
        NeoTreeCursorLine = { bg = "${black2}" },

        NormalFloat = { bg = "${darkest_black}" },
        FloatBorder = { fg = "${blue}" },

        TelescopeBorder = { fg = "${darker_black}", bg = "${darker_black}" },
        TelescopePromptBorder = { fg = "${black2}", bg = "${black2}" },
        TelescopePromptNormal = { fg = "${white}", bg = "${black2}" },
        TelescopeResultsTitle = { fg = "${darker_black}", bg = "${darker_black}" },
        TelescopePromptPrefix = { fg = "${red}", bg = "${black2}" },
        TelescopeNormal = { bg = "${darker_black}" },
        TelescopePreviewTitle = { fg = "${black}", bg = "${green}" },
        TelescopePromptTitle = { fg = "${black}", bg = "${red}" },
        TelescopeSelection = { bg = "${black2}", fg = "${white}" },
        TelescopeResultsDiffAdd = { fg = "${green}" },
        TelescopeResultsDiffChange = { fg = "${yellow}" },
        TelescopeResultsDiffDelete = { fg = "${red}" },

        TelescopeMatching = { bg = "${bg3}", fg = "${blue}" },

        Include = { fg = "${base0D}" },

        ["@variable"] = { fg = "${white}" },
        ["@variable.builtin"] = { fg = "${base09}" },
        ["@keyword.exception"] = { fg = "${base08}" },
        ["@keyword.repeat"] = { fg = "${base0A}" },
        ["@keyword.import"] = { link = "Include" },
        ["@punctuation.delimiter"] = { fg = "${base0F}" },
        ["@constant"] = { fg = "${base06}" },
        ["@constant.builtin"] = { fg = "${base09}" },

        ["@markup.heading"] = { fg = "${base0D}" },
        ["@markup.raw"] = { fg = "${base09}" },
        ["@markup.link"] = { fg = "${base08}" },
        ["@markup.link.url"] = { fg = "${base09}", underline = true },
        ["@markup.link.label"] = { fg = "${base0C}" },
        ["@markup.list"] = { fg = "${base08}" },
        ["@markup.strong"] = { bold = true },
        ["@markup.underline"] = { underline = true },
        ["@markup.italic"] = { italic = true },
        ["@markup.strikethrough"] = { strikethrough = true },
        ["@markup.quote"] = { bg = "${black2}" },
      },
      styles = {
        comments = "italic",
      },
      colors = {
        bg = "#1e222a", --  nvim bg -- darken it
        darker_black = "#1b1f27",
        darkest_black = 'require "onedarkpro.lib.color"("#1b1f27"):darker(1):to_css()',
        black = "#1e222a",
        black2 = "#252931",
        violet = "require('onedarkpro.helpers').lighten('purple', 7, 'onedark')",
        skyblue = "require('onedarkpro.helpers').lighten('blue', 7, 'onedark')",
        bg2 = "require('onedarkpro.helpers').lighten('bg', 2, 'onedark')",
        bg3 = "require('onedarkpro.helpers').lighten('bg', 4, 'onedark')",
        fg2 = "require('onedarkpro.helpers').lighten('fg', 3, 'onedark')",
        fg3 = "require('onedarkpro.helpers').lighten('fg', 6, 'onedark')",
        light_gray = "require('onedarkpro.helpers').lighten('gray', 10, 'onedark')",
        statusline_bg = "#22262e",

        base00 = "#1e222a",
        base01 = "#353b45",
        base02 = "#3e4451",
        base03 = "#545862",
        base04 = "#565c64",
        base05 = "#abb2bf",
        base06 = "#b6bdca",
        base07 = "#c8ccd4",
        base08 = "#e06c75",
        base09 = "#d19a66",
        base0A = "#e5c07b",
        base0B = "#98c379",
        base0C = "#56b6c2",
        base0D = "#61afef",
        base0E = "#c678dd",
        base0F = "#be5046",
      },
    },
  },
}
