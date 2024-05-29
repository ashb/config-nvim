local Layout = require("nui.layout")
local Popup = require("nui.popup")

local function make_popup(options)
  local TSLayout = require("telescope.pickers.layout")

  local popup = Popup(options)
  function popup.border:change_title(title)
    popup.border.set_text(popup.border, "top", title)
  end

  return TSLayout.Window(popup)
end


local opts = {
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
}

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-symbols.nvim",
    },
    opts = opts,
    cmd = { "Telescope" },
    keys = require("mappings").telescope,
  },
}
