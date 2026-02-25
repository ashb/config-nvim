local function script_path(path)
  local str = path or debug.getinfo(2, "S").source:sub(2)
  return str:match "^(.+)/[^/]+"
end

-- Remove the global winborder from the modal opacity backdrop
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lazy_backdrop",
  callback = function(ctx)
    local win = vim.fn.win_findbuf(ctx.buf)[1]
    vim.api.nvim_win_set_config(win, { border = "none" })
  end,
})

return {
  defaults = { lazy = true },
  install = { colorscheme = { "tokyonight" } },

  checker = { enabled = true, concurrency = #vim.loop.cpu_info(), notify = false },
  change_detection = { notify = false },

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
