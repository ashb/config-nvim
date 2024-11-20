-- From https://gist.github.com/bluss/761455e123fbdbf481be9ec0b0bdce58

local M = {}

-- live grep in the listed paths
---@param paths table: list of directories
---@param opts table?
function M.live_grep_paths(paths, opts)
  opts = opts or {}
  require("telescope.builtin").live_grep(vim.tbl_deep_extend("force", {
    prompt_title = "Live Grep Paths",
    search_dirs = paths,
  }, opts))
end

local shorten_path_opts = { path_display = { shorten = { len = 2, exclude = { -1, -2, -3 } } } }

---@param str string
---@param pfx string
---@return boolean
local function has_prefix(str, pfx)
  local len = #pfx
  return str:sub(1, len) == pfx
end

---@param str string
---@param pfx string
---@param sub string
---@return string
local function sub_prefix(str, pfx, sub)
  local plen = #pfx
  return sub .. str:sub(plen + 1)
end

---@param opt1 table?
---@param opt2 table?
---@return table
local function combine_opts(opt1, opt2)
  if opt1 == nil or vim.tbl_isempty(opt1) then
    return opt2 or {}
  elseif opt2 == nil or vim.tbl_isempty(opt2) then
    return opt1 or {}
  end
  return vim.tbl_deep_extend("force", opt1, opt2)
end

---@param opts table
function M.sub_homedir_path_display_func(opts)
  local tutils = require "telescope.utils"
  local homedir = vim.fn.expand "~"
  ---@param inner_opts table
  ---@param path string
  return function(inner_opts, path)
    if has_prefix(path, homedir) then
      path = sub_prefix(path, homedir, "~")
    end
    local copts
    if opts.path_display then
      copts = combine_opts(inner_opts, opts)
    else
      copts = opts
    end
    return tutils.transform_path(copts, path)
  end
end

function M.live_grep_pypath()
  local py_paths = require("_local/python_support").get_py_path()

  M.live_grep_paths(py_paths, {
    prompt_title = "Live Grep Python Env",

    -- shorten home directory to ~
    path_display = M.sub_homedir_path_display_func(shorten_path_opts),
    additional_args = { "-u" },
  })
end

function M.find_files_pypath(opts)
  local py_paths = require("_local/python_support").get_py_path()

  local og = (
    combine_opts({
      prompt_title = "Find Files in Python Env",
      hidden = true,
      search_dirs = py_paths,
      -- shorten home directory to ~
      path_display = M.sub_homedir_path_display_func(shorten_path_opts),
      find_command = { "rg", "--color=never", "--files", "-g*.py", "-u" },
    }, opts)
  )
  require("telescope.builtin").find_files(og)
end

--{{{Register custom extension helper
--- A function for easier creation of custom telescope extensions
local function register_extension(name, picker)
  rawset(require("telescope").extensions, name, picker)
end
--}}}
--

register_extension("python", { find_files = M.find_files_pypath, live_grep = M.live_grep_pypath })

return M
