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

function M.is_uv_workspace(dir)
  local path = dir .. "/pyproject.toml"
  local f = io.open(path, "r")
  if not f then
    return false
  end
  local content = f:read "*a"
  f:close()
  return content:find "%[tool%.uv%.workspace%]" ~= nil
end

local function find_nearest_pyproject(folder)
  return vim.fs.root(folder, "pyproject.toml")
end

local function find_outermost_pyproject(folder)
  local git_root = vim.fs.root(folder, ".git")
  local candidate = nil
  local search_from = folder
  while true do
    local found = vim.fs.root(search_from, "pyproject.toml")
    if not found then break end
    -- Don't walk above the git root (respects worktree boundaries)
    if git_root and not (found == git_root or vim.startswith(found, git_root .. "/")) then break end
    candidate = found
    if found == git_root then break end
    search_from = vim.fs.dirname(found)
  end
  return candidate
end

-- Root at the outermost pyproject.toml (for tools like ruff that handle monorepos)
function M.root_dir(bufnr, on_dir)
  local folder = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  local candidate = find_outermost_pyproject(folder)
  if candidate then
    on_dir(candidate)
  end
end

function M.workspace_aware_root_dir(bufnr, on_dir)
  local folder = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  local outermost = find_outermost_pyproject(folder)
  if outermost and M.is_uv_workspace(outermost) then
    on_dir(outermost)
  else
    local nearest = find_nearest_pyproject(folder)
    if nearest then
      on_dir(nearest)
    end
  end
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

local _skip_dirs = { [".git"] = true, [".venv"] = true, ["node_modules"] = true, ["__pycache__"] = true }

--- Find src-layout package roots under a project root. Calls callback(results) when done.
--- Walks up to max_depth levels looking for directories containing both
--- a pyproject.toml and a src/ subdirectory.
---@param root string Project root directory
---@param callback fun(results: string[])
---@param max_depth? integer How deep to recurse (default 4, enough for providers/apache/beam/src)
function M.find_src_roots(root, callback, max_depth)
  max_depth = max_depth or 4
  local results = {}
  local pending = 0

  local function done()
    pending = pending - 1
    if pending == 0 then
      callback(results)
    end
  end

  local function walk(dir, depth)
    if depth > max_depth then
      return
    end
    pending = pending + 1
    vim.uv.fs_scandir(dir, function(err, handle)
      if err or not handle then
        done()
        return
      end
      local subdirs = {}
      while true do
        local name, ftype = vim.uv.fs_scandir_next(handle)
        if not name then
          break
        end
        if ftype == "directory" and not _skip_dirs[name] then
          subdirs[#subdirs + 1] = name
        end
      end

      if #subdirs == 0 then
        done()
        return
      end

      local has_pyproject = false
      local src_child = nil
      local recurse_dirs = {}
      for _, name in ipairs(subdirs) do
        if name == "src" then
          src_child = dir .. "/" .. name
        else
          recurse_dirs[#recurse_dirs + 1] = dir .. "/" .. name
        end
      end

      local function finish_dir()
        if src_child and has_pyproject then
          results[#results + 1] = src_child
        end
        if depth < max_depth then
          for _, child in ipairs(recurse_dirs) do
            walk(child, depth + 1)
          end
        end
        done()
      end

      if src_child then
        pending = pending + 1
        vim.uv.fs_stat(dir .. "/pyproject.toml", function(stat_err, stat)
          has_pyproject = stat_err == nil and stat ~= nil
          done()
          finish_dir()
        end)
      else
        finish_dir()
      end
    end)
  end

  walk(root, 1)
  if pending == 0 then
    callback(results)
  end
end

return M
