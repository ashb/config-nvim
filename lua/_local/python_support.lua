-- From https://gist.github.com/bluss/761455e123fbdbf481be9ec0b0bdce58

-- helper functions for python

local M = {}

function M.silence_basedpyright()
  local function filter_diagnostics(diagnostic)
    if diagnostic.source == "basedpyright" then
      return false
    end
    return true
  end

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(function(_, result, ctx, config)
    result.diagnostics = vim.tbl_filter(filter_diagnostics, result.diagnostics)
    vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
  end, {})
end

-- python-preference system causes it to find system python outside projects,
-- but inside a project it still picks the current project's venv python
local _uv_command = { "uv", "run", "-q", "--no-sync", "--python-preference=system", "python" }

-- Get local python (python in virtualenv with preference, else system python)
---@return table: python command arguments
function M.get_local_python_cmd()
  if vim.fn.executable "uv" > 0 then
    return vim.list_slice(_uv_command) -- copy
  else
    return { "python3" }
  end
end

local function get_python_finder_cmd()
  return vim.list_extend(
    M.get_local_python_cmd(),
    { "-c", "import sys; import json; print(json.dumps(sys.executable))" }
  )
end

local function _system_get_output(cmd, cwd)
  local proc = vim.system(cmd, { cwd = cwd, timeout = 15000, text = false, env = { UV_NO_ENV_FILE = "1" } })
  local ret = proc:wait()
  if ret.stderr then
    vim.notify(ret.stderr, vim.log.levels.WARN)
  end
  return ret.stdout
end

function M.get_local_python_location(cwd)
  local cmd = get_python_finder_cmd()
  if #cmd > 1 then
    local out = _system_get_output(cmd, cwd)
    local decoded = vim.json.decode(out)
    return vim.fn.trim(decoded)
  else
    return cmd[1]
  end
end

local function nonempty(elt)
  if elt and #elt > 0 then
    return true
  else
    return false
  end
end

-- Get local python's sys.path
function M.get_py_path(cwd)
  local cmd =
    vim.list_extend(M.get_local_python_cmd(), { "-c", "import json; import sys; print(json.dumps(sys.path))" })
  local out = _system_get_output(cmd, cwd)
  local decoded_list = vim.json.decode(out)
  local non_empty = vim.tbl_filter(nonempty, decoded_list or {})
  local ret = vim.tbl_filter(function(elt)
    return vim.fn.isdirectory(elt) > 0
  end, non_empty)
  return ret
end

return M
