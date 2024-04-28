vim.g.neo_tree_remove_legacy_commands = 1

local neo_opts = {
  close_if_last_window = true,
  window = {
    mappings = {
      ["o"] = { "toggle_node" },
    },
  },
  filesystem = {
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
      },
    },
  },
  popup_border_style = "rounded",
  sources = { "filesystem", "buffers", "git_status", "document_symbols" },
  source_selector = { winbar = true },
  use_libuv_file_watcher = true,
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
}

return neo_opts
