-- Customized status bar at bottom of main window

-- For the `v:lua.` to work, it either needs to be a lua global, or `require`. For brevity I've gone with global
FelineClickHandlers = {
  Lazy = function()
    vim.cmd.Lazy()
  end,
  Git = function()
    vim.cmd.Telescope "git_branches"
  end,
  Cursor = function()
    vim.o.relativenumber = not vim.o.relativenumber
  end,
  Autoformat = function()
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    vim.cmd.redrawstatus()
  end,
}

local function config(_, opts)
  local separators = require("feline.defaults").statusline.separators.default_value
  local file = require "feline.providers.file"
  local vi_mode = require "feline.providers.vi_mode"
  local feline = require "feline"

  -- Status bar click handlers need to be _Vim_ functions, not lua ones
  vim.cmd [[
    function! _ClickStatusBar(minwid, clicks, button, mods)
      Lazy
    endfunction
  ]]

  local c = {
    -- left
    vim_status = {
      provider = function()
        if require("lazy.status").has_updates() then
          return "%0@v:lua.FelineClickHandlers.Lazy@ " .. require("lazy.status").updates() .. " %X"
        else
          return "  "
        end
      end,
      hl = { fg = "bg", bg = "skyblue" },
      right_sep = {
        always_visible = true,
        str = separators.slant_right,
        hl = { fg = "skyblue", bg = "bg" },
      },
    },

    file_name = {
      provider = function(component)
        local ft = vim.bo.filetype
        -- For these file types, show the name of the previous/alt file instead
        if vim.tbl_contains({ "help", "toggleterm", "neo-tree", "TelescopePrompt" }, ft) then
          local filename = vim.fn.expand "#:."
          if ft == "neo-tree" then
            local winid = require("neo-tree").get_prior_window()
            if winid ~= -1 then
              local bufid = vim.api.nvim_win_get_buf(winid)
              filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufid), ":.")
            end
          else
          end
          local icon, _ = require("nvim-web-devicons").get_icon_color(filename, nil, { default = true })
          return string.format("%s %s", icon, filename)
        end
        return require("feline.providers.file").file_info(
          component,
          { colored_icon = false, type = "relative", file_readonly_icon = "󰌾" }
        )
      end,
      hl = { fg = "bg", bg = "fg3" },
      left_sep = {
        always_visible = true,
        str = separators.slant_right,
        hl = { fg = "bg", bg = "fg3" },
      },
      right_sep = {
        always_visible = true,
        str = separators.slant_right,
        hl = { fg = "fg3", bg = "bg" },
      },
    },

    autoformat = {

      -- Show if conform is autoformattting the buffer or not
      provider = function()
        local icon = vim.b.disable_autoformat and "󰉥" or "󰉿"
        return "%0@v:lua.FelineClickHandlers.Autoformat@" .. icon .. "%X"
      end,

      hl = function()
        local hl = { fg = "base08", bg = "base01" }
        if not vim.b.disable_autoformat then
          local color = require "_local/colorscheme"
          hl.fg = color.darker(color.theme.green, 10)
        end
        return hl
      end,
      left_sep = {
        always_visible = true,
        str = separators.slant_right,
        hl = { fg = "bg", bg = "base01" },
      },
      right_sep = {
        always_visible = true,
        str = separators.slant_right,
        hl = { fg = "base01", bg = "bg" },
      },
    },

    git_branch = {
      provider = function()
        -- Show the branch name from the current buffer, or the CWD
        local branch = vim.b.gitsigns_head or vim.g.gitsigns_head or ""
        local s
        if #branch > 0 then
          s = string.format("%%0@v:lua.FelineClickHandlers.Git@  %s %%X", branch)
        else
          s = string.format(" %s ", "Untracked")
        end
        return s
      end,
      hl = { fg = "bg", bg = "light_gray" },
      left_sep = {
        always_visible = true,
        str = separators.slant_right,
        hl = { fg = "bg", bg = "light_gray" },
      },
      right_sep = {
        always_visible = true,
        str = separators.slant_right,
        hl = { fg = "light_gray", bg = "bg" },
      },
    },
    -- right
    vi_mode = {
      provider = function()
        return string.format(" %s ", vi_mode.get_vim_mode())
      end,
      hl = function()
        return { fg = "bg", bg = vi_mode.get_mode_color() }
      end,
      left_sep = {
        always_visible = true,
        str = separators.slant_left,
        hl = function()
          return { fg = vi_mode.get_mode_color(), bg = "none" }
        end,
      },
      right_sep = {
        always_visible = true,
        str = separators.slant_left,
        hl = function()
          return { fg = "bg", bg = vi_mode.get_mode_color() }
        end,
      },
    },

    macro = {
      provider = function()
        local s
        local recording_register = vim.fn.reg_recording()
        if #recording_register == 0 then
          s = ""
        else
          s = string.format(" Recording @%s ", recording_register)
        end
        return s
      end,
      hl = { fg = "bg", bg = "fg_gutter" },
      left_sep = {
        always_visible = true,
        str = separators.slant_left,
        hl = function()
          return { fg = "fg_gutter", bg = "bg" }
        end,
      },
    },

    search_count = {
      provider = function()
        if vim.v.hlsearch == 0 then
          return ""
        end

        local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 250 })
        if not ok then
          return ""
        end
        if next(result) == nil then
          return ""
        end

        local denominator = math.min(result.total, result.maxcount)
        return string.format(" [%d/%d] ", result.current, denominator)
      end,
      hl = { fg = "bg", bg = "white" },
      left_sep = {
        always_visible = true,
        str = separators.slant_left,
        hl = function()
          return { fg = "white", bg = "fg_gutter" }
        end,
      },
      right_sep = {
        always_visible = true,
        str = separators.slant_left,
        hl = { fg = "bg", bg = "white" },
      },
    },

    cursor_position = {
      provider = {
        name = "position",
        opts = {
          format = "%0@v:lua.FelineClickHandlers.Cursor@{line} {col}%X",
        },
      },
      hl = { fg = "bg", bg = "blue" },
      left_sep = {
        always_visible = true,
        str = string.format("%s%s", separators.slant_left, separators.block),
        hl = function()
          return { fg = "blue", bg = "bg" }
        end,
      },
      right_sep = {
        always_visible = true,
        str = " ",
        hl = { fg = "bg", bg = "blue" },
      },
    },

    scroll_bar = {
      provider = {
        name = "scroll_bar",
        opts = { reverse = true },
      },
      hl = { fg = "blue_dim", bg = "blue" },
    },

    -- inactive statusline
    in_file_info = {
      provider = function()
        if vim.api.nvim_buf_get_name(0) ~= "" then
          return file.file_info({}, { colored_icon = false })
        else
          return file.file_type({}, { colored_icon = false, case = "lowercase" })
        end
      end,
      hl = { fg = "bg", bg = "blue" },
      left_sep = {
        always_visible = true,
        str = string.format("%s%s", separators.slant_left, separators.block),
        hl = { fg = "blue", bg = "none" },
      },
      right_sep = {
        always_visible = true,
        str = " ",
        hl = { fg = "bg", bg = "blue" },
      },
    },
  }

  local active = {
    { -- left
      c.vim_status,
      c.file_name,
      c.autoformat,
      c.git_branch,
      c.lsp,
    },
    { -- right
      c.vi_mode,
      c.macro,
      c.search_count,
      c.cursor_position,
      c.scroll_bar,
    },
  }

  local inactive = {
    { -- left
    },
    { -- right
      c.in_file_info,
    },
  }

  opts.components = { active = active, inactive = inactive }

  feline.setup(opts)
  feline.use_theme(require("_local/colorscheme").theme)
end

local specs = {
  {
    "freddiehaddad/feline.nvim",
    config = config,
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      -- update statusbar when there's a plugin update
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyCheck",
        callback = function()
          vim.opt.statusline = vim.opt.statusline
        end,
      })
    end,
    opts = {
      force_inactive = { filetypes = { "^dapui_*", "^neotest*", "^qf$" } },
      disable = { filetypes = {} },
    },
    event = "UIEnter",
  },
}

return specs
