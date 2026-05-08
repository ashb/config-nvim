local MiniTest = require "mini.test"
local new_set = MiniTest.new_set
local expect = MiniTest.expect

local child = MiniTest.new_child_neovim()

local T = new_set {
  hooks = {
    pre_once = function()
      child.start { "-u", "scripts/minimal_init.lua" }
    end,
    pre_case = function()
      child.lua [[_G._tmp_roots = {}]]
    end,
    post_case = function()
      child.lua [[
        for _, root in ipairs(_G._tmp_roots) do
          vim.fn.delete(root, "rf")
        end
      ]]
    end,
    post_once = function()
      child.stop()
    end,
  },
}

local function make_tree(spec)
  return child.lua_get(("(function() " .. [[
    local spec = %s
    local root = vim.fn.tempname()
    vim.fn.mkdir(root, "p")
    _G._tmp_roots[#_G._tmp_roots + 1] = root
    for path, content in pairs(spec) do
      local full = root .. "/" .. path
      if content == true then
        vim.fn.mkdir(full, "p")
      else
        vim.fn.mkdir(vim.fs.dirname(full), "p")
        local f = io.open(full, "w"); f:write(content); f:close()
      end
    end
    return root
  ]] .. "end)()"):format(vim.inspect(spec)))
end

-- Start async find_src_roots in the child (fire-and-forget), then sleep so
-- the child's event loop is free to run the uv callbacks, then read the result.
local function find_src_roots(root, max_depth)
  child.lua_notify(([[
    _G._fsr_result = nil
    require("_local.python_support").find_src_roots(%s, function(r)
      table.sort(r)
      _G._fsr_result = r
    end, %s)
  ]]):format(vim.inspect(root), max_depth or "nil"))
  vim.uv.sleep(100)
  child.api.nvim_eval "1" -- poke event loop to flush any vim.schedule callbacks
  return child.lua_get "_G._fsr_result"
end

-- find_src_roots -------------------------------------------------------------

T["find_src_roots"] = new_set()

T["find_src_roots"]["finds src next to pyproject.toml at depth 1"] = function()
  local root = make_tree {
    ["pkg-a/pyproject.toml"] = "",
    ["pkg-a/src/mod/__init__.py"] = "",
  }
  expect.equality(find_src_roots(root), { root .. "/pkg-a/src" })
end

T["find_src_roots"]["finds src at depth 2 (packages/foo/src)"] = function()
  local root = make_tree {
    ["packages/foo/pyproject.toml"] = "",
    ["packages/foo/src/foo/__init__.py"] = "",
    ["packages/bar/pyproject.toml"] = "",
    ["packages/bar/src/bar/__init__.py"] = "",
  }
  expect.equality(find_src_roots(root), {
    root .. "/packages/bar/src",
    root .. "/packages/foo/src",
  })
end

T["find_src_roots"]["finds src at depth 3 (providers/apache/beam/src)"] = function()
  local root = make_tree {
    ["providers/apache/beam/pyproject.toml"] = "",
    ["providers/apache/beam/src/beam/__init__.py"] = "",
  }
  expect.equality(find_src_roots(root), { root .. "/providers/apache/beam/src" })
end

T["find_src_roots"]["ignores src without sibling pyproject.toml"] = function()
  local root = make_tree { ["stray/src/something.py"] = "" }
  expect.equality(find_src_roots(root), {})
end

T["find_src_roots"]["skips .venv and .git directories"] = function()
  local root = make_tree {
    [".venv/pyproject.toml"] = "",
    [".venv/src/x.py"] = "",
    [".git/pyproject.toml"] = "",
    [".git/src/x.py"] = "",
    ["real/pyproject.toml"] = "",
    ["real/src/x.py"] = "",
  }
  expect.equality(find_src_roots(root), { root .. "/real/src" })
end

T["find_src_roots"]["respects max_depth"] = function()
  local root = make_tree {
    ["a/pyproject.toml"] = "",
    ["a/src/mod.py"] = "",
    ["deep/nested/pkg/pyproject.toml"] = "",
    ["deep/nested/pkg/src/mod.py"] = "",
  }
  expect.equality(find_src_roots(root, 2), { root .. "/a/src" })
  expect.equality(find_src_roots(root, 4), {
    root .. "/a/src",
    root .. "/deep/nested/pkg/src",
  })
end

T["find_src_roots"]["returns src at root level when pyproject.toml is a sibling"] = function()
  local root = make_tree {
    ["pyproject.toml"] = "",
    ["src/mylib/__init__.py"] = "",
  }
  expect.equality(find_src_roots(root), { root .. "/src" })
end

-- is_uv_workspace ------------------------------------------------------------

T["is_uv_workspace"] = new_set()

T["is_uv_workspace"]["returns true when workspace section present"] = function()
  local root = make_tree { ["pyproject.toml"] = "[tool.uv.workspace]\nmembers = [\"packages/*\"]\n" }
  expect.equality(child.lua_get('require("_local.python_support").is_uv_workspace(' .. vim.inspect(root) .. ")"), true)
end

T["is_uv_workspace"]["returns false for plain pyproject.toml"] = function()
  local root = make_tree { ["pyproject.toml"] = "[project]\nname = \"foo\"\n" }
  expect.equality(child.lua_get('require("_local.python_support").is_uv_workspace(' .. vim.inspect(root) .. ")"), false)
end

T["is_uv_workspace"]["returns false when no pyproject.toml exists"] = function()
  local root = make_tree { [".keep"] = "" }
  expect.equality(child.lua_get('require("_local.python_support").is_uv_workspace(' .. vim.inspect(root) .. ")"), false)
end

T["is_uv_workspace"]["does not match partial key names"] = function()
  local root = make_tree { ["pyproject.toml"] = "[tool.uv.workspace-extra]\nfoo = \"bar\"\n" }
  expect.equality(child.lua_get('require("_local.python_support").is_uv_workspace(' .. vim.inspect(root) .. ")"), false)
end

return T
