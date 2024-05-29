
local function script_path(path)
  local str = path or debug.getinfo(2, "S").source:sub(2)
  return str:match "^(.+)/[^/]+"
end

return {
  defaults = { lazy = true },
  install = { colorscheme = { "tokyonight" } },

  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  performance = {
    rtp = {
      paths = {
        -- Ensure that our non-standard nvim config dir is in the runtimepath still!
        vim.fn.fnamemodify(script_path(), ":p:h:h:h"),
      },
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}
