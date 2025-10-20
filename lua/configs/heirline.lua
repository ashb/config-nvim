local conditions = require "heirline.conditions"
local utils = require "heirline.utils"
local heirline = require "heirline"

local SEPARATORS = require("_local.ui").SEPARATORS
local color = require "_local.colorscheme"

local comps = {}

local log = require "_local.log"

comps.Align = { provider = "%=" }
comps.LazyStatus = {
  provider = function()
    if require("lazy.status").has_updates() then
      return " " .. require("lazy.status").updates() .. " "
    else
      return "   "
    end
  end,
  hl = { fg = color.theme.bg, bg = "skyblue", bold = true },
  on_click = {
    callback = function()
      vim.cmd.Lazy()
    end,
    name = "_stlLazy",
  },
}

comps.Filename = {
  provider = function(component)
    local ft = vim.bo.filetype
    local fname
    local icon = nil
    if vim.tbl_contains({ "help", "toggleterm", "neo-tree", "TelescopePrompt" }, ft) then
      fname = vim.fn.expand "#:."
      if ft == "neo-tree" then
        local winid = require("neo-tree").get_prior_window()
        if winid ~= -1 then
          local bufid = vim.api.nvim_win_get_buf(winid)
          fname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufid), ":.")
          ft = vim.bo[bufid].filetype
        else
          -- On initial open of NeoTree, get_prior_window doesn't work, so use this fallback
          icon = require("nvim-web-devicons").get_icon(vim.fn.fnamemodify(fname, ":t"), nil, { default = true })
        end
      end
    else
      fname = vim.fn.expand "%:."
    end
    if icon == nil then
      icon = require("nvim-web-devicons").get_icon_by_filetype(ft, { default = true })
    end
    return icon .. " " .. fname
  end,
  hl = { fg = color.theme.bg, bg = color.theme.fg3 },
}

comps.AutoFormat = {
  -- Show if conform is autoformattting the buffer or not
  provider = function()
    local icon = vim.b.disable_autoformat and "󰉥" or "󰉿"
    return "%0@v:lua.FelineClickHandlers.Autoformat@" .. icon .. "%X"
  end,
  on_click = {
    callback = function()
      vim.b.disable_autoformat = not vim.b.disable_autoformat
      vim.cmd.redrawstatus()
    end,
    name = "_stlToggleAutoformat",
  },

  hl = function()
    local hl = { fg = color.theme.base08, bg = color.theme.base01 }
    if not vim.b.disable_autoformat then
      hl.fg = color.darker(color.theme.green, 10)
    end
    return hl
  end,
}

comps.GitBranch = {
  provider = function()
    -- Show the branch name from the current buffer, or the CWD
    local branch = vim.b.gitsigns_head or vim.g.gitsigns_head or ""
    local s
    if #branch > 0 then
      s = string.format("  %s ", branch)
    else
      s = string.format(" %s ", "Untracked")
    end
    return s
  end,
  on_click = {
    callback = function()
      vim.cmd.Telescope "git_branches"
    end,
    name = "_stlGitBranch",
  },
  hl = { fg = color.theme.bg, bg = color.theme.light_gray },
}

comps.ViMode = {
  static = {
    -- stylua: ignore
    mode_names = {
      ['n']      = 'NORMAL',
      ['no']     = 'O-PENDING',
      ['nov']    = 'O-PENDING',
      ['noV']    = 'O-PENDING',
      ['no\22'] = 'O-PENDING',
      ['niI']    = 'NORMAL',
      ['niR']    = 'NORMAL',
      ['niV']    = 'NORMAL',
      ['nt']     = 'NORMAL',
      ['ntT']    = 'NORMAL',
      ['v']      = 'VISUAL',
      ['vs']     = 'VISUAL',
      ['V']      = 'V-LINE',
      ['Vs']     = 'V-LINE',
      ['\22']    = 'V-BLOCK',
      ['\22s']   = 'V-BLOCK',
      ['s']      = 'SELECT',
      ['S']      = 'S-LINE',
      ['\19']    = 'S-BLOCK',
      ['i']      = 'INSERT',
      ['ic']     = 'INSERT',
      ['ix']     = 'INSERT',
      ['R']      = 'REPLACE',
      ['Rc']     = 'REPLACE',
      ['Rx']     = 'REPLACE',
      ['Rv']     = 'V-REPLACE',
      ['Rvc']    = 'V-REPLACE',
      ['Rvx']    = 'V-REPLACE',
      ['c']      = 'COMMAND',
      ['cv']     = 'EX',
      ['ce']     = 'EX',
      ['r']      = 'REPLACE',
      ['rm']     = 'MORE',
      ['r?']     = 'CONFIRM',
      ['!']      = 'SHELL',
      ['t']      = 'TERMINAL',
    },

    -- table to map mode to highlight suffixes
    mode_to_highlight = {
      ["VISUAL"] = "Visual",
      ["V-BLOCK"] = "Visual",
      ["V-LINE"] = "Visual",
      ["SELECT"] = "Visual",
      ["S-LINE"] = "Visual",
      ["S-BLOCK"] = "Visual",
      ["REPLACE"] = "Replace",
      ["V-REPLACE"] = "Replace",
      ["INSERT"] = "Insert",
      ["COMMAND"] = "Command",
      ["EX"] = "Command",
      ["MORE"] = "Command",
      ["CONFIRM"] = "Command",
      ["TERMINAL"] = "Terminal",
      ["NORMAL"] = "Normal",
    },
  },

  provider = function(self)
    local mode = vim.api.nvim_get_mode().mode
    mode = self.mode_names[mode] or mode
    log.fmt_info("ViMode.provider mode=%s", mode)
    return " " .. mode .. " "
  end,
  hl = function(self)
    local mode = vim.api.nvim_get_mode().mode
    mode = self.mode_names[mode] or mode
    log.fmt_info("ViMode.hl mode=%s", mode)
    -- print("Mode is " .. self._mode)
    -- print("hlgroup is " .. (self.mode_to_highlight[self._mode] or "normal"))
    local hl_suffix = self.mode_to_highlight[mode] or "NORMAL"
    return "ViMode" .. hl_suffix
  end,
  -- Re-evaluate the component only on ModeChanged event!
  -- Also allows the statusline to be re-evaluated when entering operator-pending mode
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
      vim.cmd "redrawstatus"
    end),
  },
}

comps.Cursor = {
  static = {
    format = "%d %d ",
  },
  provider = function(self)
    local line = vim.fn.line "."
    local col = vim.fn.col "."

    return self.format:format(line, col)
  end,
  hl = { fg = "bg", bg = "blue" },
  update = {
    "CursorMoved",
  },
}

local function colors()
  return {
    bright_bg = utils.get_highlight("Folded").bg,
    bright_fg = utils.get_highlight("Folded").fg,
    red = utils.get_highlight("DiagnosticError").fg,
    dark_red = utils.get_highlight("DiffDelete").bg,
    green = utils.get_highlight("String").fg,
    blue = utils.get_highlight("Function").fg,
    gray = utils.get_highlight("NonText").fg,
    orange = utils.get_highlight("Constant").fg,
    purple = utils.get_highlight("Statement").fg,
    cyan = utils.get_highlight("Special").fg,
    diag_warn = utils.get_highlight("DiagnosticWarn").fg,
    diag_error = utils.get_highlight("DiagnosticError").fg,
    diag_hint = utils.get_highlight("DiagnosticHint").fg,
    diag_info = utils.get_highlight("DiagnosticInfo").fg,
    git_del = utils.get_highlight("diffDeleted").fg,
    git_add = utils.get_highlight("diffAdded").fg,
    git_change = utils.get_highlight("diffChanged").fg,
  }
end

local surrond_color = function(self)
  local surrounded = self[2][1]
  if surrounded.init then
    surrounded:init()
  end

  if type(surrounded.hl) == "function" then
    local hl = surrounded:hl()
    return hl and hl.bg or "none"
  end
  return surrounded.hl.bg
end

local _left_sep = { SEPARATORS.slant_left_2, SEPARATORS.slant_right }
local function left_surround(comp, right_only)
  local sep = _left_sep
  if right_only then
    sep = { "", sep[2] }
  end
  return utils.surround(sep, surrond_color, comp)
end

local _right_sep = { SEPARATORS.slant_right_2, SEPARATORS.slant_left }
local function right_surround(comp, opts)
  local sep = _right_sep

  opts = opts or {}
  if opts.left_only then
    sep = { sep[1], "" }
  end
  local provider = comp.provider

  return utils.clone(comp, {
    provider = function(self)
      local provoider_str = type(provider) == "function" and provider(self) or provider
      return sep[1] .. provoider_str .. sep[2]
    end,
  })
end

local M = {
  statusline = {
    left_surround(comps.LazyStatus, true),
    left_surround(comps.Filename),
    left_surround(comps.AutoFormat),
    left_surround(comps.GitBranch),
    comps.Align,
    right_surround(comps.ViMode),
    right_surround(comps.Cursor, { left_only = true }),
  },
  opts = {
    colors = colors,
  },
}
vim.api.nvim_create_augroup("Heirline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    utils.on_colorscheme(colors)
  end,
  group = "Heirline",
})

return M
