local M = {}

function M.relative_to_current_file()
  local Path = require("plenary").path
  local dir = Path:new(vim.fn.expand "%:p:h"):make_relative()
  require("telescope.builtin").find_files { prompt_title = "Relative to " .. dir .. "/", cwd = dir }
end

function M.customize_config(conf)
  table.insert(conf.defaults.vimgrep_arguments, "--hidden")

  return vim.tbl_deep_extend("force", conf, {
    pickers = {
      find_files = {
        find_command = { "rg", "--files", "--hidden", "--glob=!**/.git/", "--glob=!**/node_modules/" },
      },
    },
  })
end

return M
