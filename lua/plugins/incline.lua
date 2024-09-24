-- FLoating status windows in top-right of each split
--
-- I like the way default splits show up in neovim, but I want a little indication of what file is open in each split.

local colorscheme = require "colorscheme"
local opts = {
  window = {
    margin = { horizontal = 0 },
    padding = 0,
  },
  -- https://github.com/b0o/incline.nvim/issues/69
  debounce_threshold = {
    falling = 75,
    rising = 75,
  },
}

---@class InclineRenderProps
---@field buf number
---@field win number
---@field focused boolean

---@param props InclineRenderProps
local function getGitDiff(props)
  local icons = { removed = " ", changed = " ", added = " " }
  icons["changed"] = icons.modified
  local signs = vim.b[props.buf].gitsigns_status_dict
  local labels = {}
  if signs == nil then
    return nil
  end
  for name, icon in pairs(icons) do
    if tonumber(signs[name]) and signs[name] > 0 then
      table.insert(labels, { icon .. signs[name] .. " ", group = "Diff" .. name })
    end
  end
  if #labels > 0 then
    table.insert(labels, { "┊ " })
    return { labels }
  else
    return nil
  end
end

---@param props InclineRenderProps
local function getDiagnosticLabel(props)
  local icons = { error = "", warn = "", info = "", hint = "󰛨" }
  local label = {}

  for severity, icon in pairs(icons) do
    local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
    if n > 0 then
      table.insert(label, { icon .. n .. " ", group = "DiagnosticSign" .. severity })
    end
  end
  if #label > 0 then
    table.insert(label, { "┊ " })
    return { label }
  else
    return nil
  end
end

---@param props InclineRenderProps
function opts.render(props)
  local separators = require("feline").separators
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
  local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
  local modified = vim.bo[props.buf].modified and "bold,italic" or nil

  local helpers = require "incline.helpers"
  local sep_color = colorscheme.theme.black

  local unfocused_color = function(hex)
    if props.focused then
      return hex
    else
      return colorscheme.desaturate(hex, 75)
    end
  end
  local bg = unfocused_color "#44406e"

  local fname_bg = unfocused_color(ft_color or colorscheme.theme.skyblue)
  local fname_fg = helpers.contrast_color(fname_bg)

  ---@class table
  local buffer = vim.tbl_filter(function(v)
    -- Filter out "empty" values
    return (type(v) == "string" and v ~= "") or (type(v) == "table" and not vim.tbl_isempty(v)) or v
  end, {
    getDiagnosticLabel(props),
    getGitDiff(props),
    ft_icon and {
      " ",
      ft_icon,
      " ",
      guibg = fname_bg,
      guifg = fname_fg,
    },
    filename ~= "" and {
      filename .. " ",
      gui = modified,
      guibg = fname_bg,
      guifg = fname_fg,
    },
  })
  -- Window number component
  if #buffer > 0 then
    buffer[#buffer + 1] = { separators.slant_right, guifg = buffer[#buffer].guibg }
  end
  buffer[#buffer + 1] = { "  " .. vim.api.nvim_win_get_number(props.win) .. " ", group = "DevIconWindows" }
  buffer.guibg = bg

  -- Make the left most separator the same color as the item before it
  local part = buffer[1]
  local leftBorder = { "", guibg = sep_color, guifg = part.guibg }
  if part.guibg == nil then
    leftBorder.guifg = part.guifg or bg
  end
  table.insert(buffer, 1, leftBorder)

  return buffer
end

return {
  "b0o/incline.nvim",
  opts = opts,
  event = "UIEnter",
  dependencies = {
    -- We use feline for the separators (since we already use this for status line)
    "freddiehaddad/feline.nvim",
  },
}
