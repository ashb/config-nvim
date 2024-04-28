local helpers = require "incline.helpers"
local colors = require "base46.colors"

local M = {
  window = {
    margin = { horizontal = 0 },
    padding = 0,
  },
}

---@class InclineRenderProps
---@field buf number
---@field win number
---@field focused boolean

---@param props InclineRenderProps
local function searchTerm(props)
  if not props.focused then
    return nil
  end

  local count = vim.fn.searchcount { recompute = 1, maxcount = -1 }
  local contents = vim.fn.getreg "/"
  if string.len(contents) == 0 or vim.v.hlsearch == 0 then
    return nil
  end

  return {
    {
      "  ",
      group = "dkoStatusKey",
    },
    {
      (" %s "):format(contents),
      group = "IncSearch",
    },
    {
      (" %d/%d "):format(count.current, count.total),
      group = "dkoStatusValue",
    },
    { "┊ " },
  }
end

---@param props InclineRenderProps
local function getGitDiff(props)
  local icons = { removed = "", changed = "", added = "" }
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
M.render = function(props)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
  local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
  local modified = vim.bo[props.buf].modified and "bold,italic" or "bold"

  local theme = require("base46").get_theme_tb "base_30"

  local sep_color = theme.black

  local unfocused_color = function(hex)
    if props.focused then
      return hex
    else
      return colors.change_hex_saturation(hex, -75)
    end
  end
  local bg = unfocused_color "#44406e"

  ---@class table
  local buffer = vim.tbl_filter(function(v)
    return v ~= "" or (type(v) == "table" and not vim.tbl_isempty(v))
  end, {
    searchTerm(props),
    getDiagnosticLabel(props),
    getGitDiff(props),
    ft_icon and {
      " ",
      ft_icon,
      " ",
      guibg = unfocused_color(ft_color),
      guifg = unfocused_color(helpers.contrast_color(ft_color)),
    } or "",
    { filename .. " ", gui = modified },
    { "┊  " .. vim.api.nvim_win_get_number(props.win), group = "DevIconWindows" },
  })
  buffer.guibg = bg

  -- Make the left most separator the same color as the item before it
  local function getLeftMostPart(parts)
    for _, part in ipairs(parts) do
      if not vim.tbl_isempty(part) then
        return part
      end
    end
  end

  local part = getLeftMostPart(buffer)
  if part.guibg == nil then
    table.insert(buffer, 1, { "", guibg = sep_color, guifg = part.guifg or bg })
  else
    table.insert(buffer, 1, { "", guibg = sep_color, guifg = part.guibg })
  end

  return buffer
end

return M
