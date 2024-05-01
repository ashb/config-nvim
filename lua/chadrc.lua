-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

local string = require "string"

local separators = {}
local function loadSeparators()
  if not separators then
    return
  end
  local config = require("nvconfig").ui.statusline
  local sep_style = config.separator_style

  local default_sep_icons = {
    default = { left = "", right = "" },
    round = { left = "", right = "" },
    block = { left = "█", right = "█" },
    arrow = { left = "", right = "" },
  }

  separators = (type(sep_style) == "table" and sep_style) or default_sep_icons[sep_style]
end

---@type ChadrcConfig
local M = {}


M.base46 = {
  integrations = {
    "rainbowdelimiters",
  }
}

M.ui = {
  theme = "onedark",

  hl_override = {
    Label = { fg = "purple" },

    Comment = { italic = true },
    ["@comment"] = { italic = true },

    IncSearch = { link = "CurSearch" },
    -- Darnken the search term
    Search = { bg = { "yellow", -40 } },

    ["@diff.minus.diff"] = { link = "DiffRemoved" },
    ["@diff.plus.diff"] = { link = "DiffAdded" },
  },
  hl_add = {
    -- Make current search stand out form other search results
    CurSearch = { bg = "purple", fg = "black", link = "" },
  },

  -- Disable NvChad's signature help in favour of Noice's
  lsp = { signature = false },

  term = {
    float = {
      row = 0.15,
      col = 0.125,
      width = 0.7,
      height = 0.75,
    },
  },
  tabufline = {
    order = { "treeOffset", "buffers", "tabs", "btns" },
    modules = {
      -- Override this module to look at neo-tree instead of nvim-tree
      treeOffset = function()
        local function getNvimTreeWidth()
          for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].ft == "neo-tree" then
              return vim.api.nvim_win_get_width(win) + 1
            end
          end
          return 0
        end
        return "%#NvimTreeNormal#" .. string.rep(" ", getNvimTreeWidth())
      end,
    },
  },

  statusline = {
    modules = {
      -- Default, plus LN and
      cursor = function()
        loadSeparators()
        local sep_l = separators["left"]
        local default = "%#St_pos_sep#" .. sep_l .. "%#St_pos_icon# %#St_pos_text# %p %% "
        -- Add cusror position to the default percenatage
        return default .. "%l %-3c"
      end,

      -- Show relative file path, not just basename
      file = function()
        loadSeparators()
        local icon = " 󰈚 "
        local ft = vim.bo.filetype
        local name
        local sep_r = separators["right"]

        if vim.tbl_contains({ "help", "terminal" }, ft) then
          -- For these file types, show the name of the previous/alt file instead
          name = vim.fn.expand "#:."
        else
          name = vim.fn.expand "%:."
        end

        if name == "" then
          name = "Empty "
        else
          local devicons_present, devicons = pcall(require, "nvim-web-devicons")

          if devicons_present then
            local ft_icon = devicons.get_icon(name)
            icon = (ft_icon ~= nil and " " .. ft_icon) or icon
          end

          name = " " .. name .. " "
        end

        return "%#St_file_info#" .. icon .. name .. "%#St_file_sep#" .. sep_r
      end,
    },
  },
}

return M
