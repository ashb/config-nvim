vim.g.neo_tree_remove_legacy_commands = 1

local neo_opts = {
  close_if_last_window = true,
  window = {
    mappings = {
      ["o"] = { "toggle_node" },
    },
  },
  filesystem = {
    use_libuv_file_watcher = true,
    follow_current_file = {
      enabled = true,
    },
    filtered_items = {
      always_show = {
        ".gitignore",
        ".github",
        ".circleci",
      },
    },
    window = {
      mappings = {
        ["ga"] = "git_add_file",
        ["gu"] = "git_unstage_file",
      },
    },
  },
  document_symbols = {
    window = {
      popup = {
        position = { col = "100%", row = "2" },
        size = function(state)
          local root_name = vim.fn.fnamemodify(state.path, ":~")
          local root_len = string.len(root_name) + 4
          return {
            width = math.max(root_len, 50),
            height = vim.o.lines - 6,
          }
        end,
      },
    },
  },
  popup_border_style = "rounded",
  sources = { "filesystem", "buffers", "git_status", "document_symbols" },
  source_selector = { winbar = true },
  default_component_configs = {
    git_status = {
      symbols = {
        -- Change type
        added = "",
        deleted = "",
        modified = "",
        renamed = "➜",
        -- Status type
        untracked = "★",
        ignored = "◌",
        unstaged = "",
        staged = "✓",
        conflict = "",
      },
    },
  },

  -- Hide cursor in neotree windows
  event_handlers = {
    {
      event = "neo_tree_buffer_enter",
      handler = function()
        vim.cmd "highlight! Cursor blend=100"
      end,
    },
    {
      event = "neo_tree_buffer_leave",
      handler = function()
        vim.cmd "highlight! Cursor guibg=#5f87af blend=0"
      end,
    },
  },
}

return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    {
      "s1n7ax/nvim-window-picker",
      opts = {
        show_prompt = false,
        hint = "floating-big-letter",
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { "neo-tree", "neo-tree-popup", "notify", "incline", "noice" },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { "terminal", "quickfix" },
          },
        },
      },
    },
  },
  cmd = { "Neotree" },
  opts = neo_opts,
  keys = require("mappings").neotree,
}
