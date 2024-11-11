--[[
--
-- A small helper for colorschemes.
--
-- This just abstracts away exact colorschemes from the individual plugins to one place
--
--]]

-- TOOD: Should I use mini.colors for oklab/oklsh colorspace conversion?

local M = {}

---Desaturate or saturate a color by a given percentage
---@param color string|number The color, as hex string or 32bit integer
---@param percent number The percentage to desaturate or saturate the color.
--                Negative values desaturate the color, positive values saturate it
---@return string hex color value
M.desaturate = function(color, percent)
  return require "onedarkpro.lib.color"(color):saturate(-percent):to_css()
end

---Make a given color darker
---
---It does a simple adjustment of the Lightness channel in the HSL space
---@param color string|number The color, as hex string or 32bit integer
---@param percent number Adjustment (+ve = darker). Float [-100,100].
---@return string hex color value
function M.darker(color, percent)
  return require "onedarkpro.lib.color"(color):darker(percent):to_css()
end

-- lazy load function
local function get_colors()
  local onedark = require("onedarkpro.helpers").get_colors()
  return onedark
end

return setmetatable(M, {
  __index = function(t, k)
    -- Lazy load colors dict
    if k == "theme" then
      t[k] = get_colors()
      return t[k]
    end
  end,
})
