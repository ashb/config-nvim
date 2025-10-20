local root_pattern = require("lspconfig.util").root_pattern

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

vim.lsp.config.tilt = {
  cmd = { "tilt", "lsp", "start" },
  filetypes = { "tilt" },
  root_dir = root_pattern ".git",
}

local function on_attach(_, bufnr)
  vim.diagnostic.config {
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "󰅙",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "󰋼",
        [vim.diagnostic.severity.HINT] = "󰌵",
      },
    },
  }
  local mappings = require "mappings"
  -- Remove LSP specific default keymappings
  for _, plugin in ipairs { mappings.glances } do
    for _, mapping in ipairs(plugin) do
      local mode = "n"

      if mapping[#mapping + 1].mode ~= nil then
        mode = mapping[#mapping + 1].mode
      end
      pcall(vim.keymap.del, mode, mapping[1], { buffer = bufnr })
    end
  end
end

vim.lsp.config("*", {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- lsps with default config
local servers = { "ccls", "rust_analyzer", "tilt", "nil_ls", "pyrefly", "vtsls" }
for _, lsp in ipairs(servers) do
  if vim.fn.executable(vim.lsp.config[lsp].cmd[1]) == 1 then
    vim.lsp.enable(lsp)
  end
end

vim.lsp.config("jdtls", {
  filetypes = { "java", "gradle" },
  root_dir = root_pattern("gradlew", ".git", "mvnw"),
})
vim.lsp.enable "jdtls"

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      -- Neovim uses LuaJit (5.1 with 5.2 backports)
      version = "Lua 5.2",
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
})
vim.lsp.enable "lua_ls"

local root_pyproject_func = root_pattern "pyproject.toml"

vim.lsp.config( 'basedpyright', {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false

    on_attach(client, bufnr)
  end,
  single_file_support = true,
  root_dir = function(fname)
    return root_pyproject_func(fname) or vim.fn.getcwd()
  end,
  filetypes = { "python" },
  on_init = function(client, _)
    if root_pyproject_func(vim.fn.getcwd()) then
      -- nothing
    else
      print "No pyproject: basedpyright linter disabled"
      require("_local.python_support").silence_basedpyright()
    end

    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = {
        -- Don't show hint as virtual text, reportUnusedParam from basedpyright is too noisy
        severity = { min = vim.diagnostic.severity.INFO },
      },
    })
  end,

  -- For basedpyright to pick up the right python environment, we want to set settings.python.pythonPath  to the
  -- path to the current python executable (in the virtual environment) when the lsp activates for a project.
  -- NOTE: that if you set venv this overrides pythonPath and it doesn't work, I think, - venv must not be set
  -- in pyproject.toml or pyrightconfig.json
  on_new_config = function(new_config, new_root_dir)
    -- configure basedpyright's python.pythonPath to be the python executable path for the environment
    local root = root_pyproject_func(new_root_dir)
    if root then
      --
      local success, py_path = pcall(function()
        local pysupport = require "_local.python_support"
        return pysupport.get_local_python_location(new_root_dir)
      end)
      if success and py_path then
        new_config.settings.python.pythonPath = py_path
        -- note, one could set extraPaths instead, but those are counted as 'in' the project
      end
      if not success then
        vim.notify("Error: " .. tostring(py_path), vim.log.levels.WARN)
      end
    else
      -- pass
    end
  end,
  settings = {
    python = {},
    basedpyright = {
      disableOrganizeImports = true, -- Using Ruff's import organizer
      analysis = {
        typeCheckingMode = "standard",

        diagnosticSeverityOverrides = {
          reportUnusedImport = false, -- We also have ruff reporting this as F401
          reportUndefinedVariable = false, -- F821
          reportUnusedVariable = false, -- Ditto as F841
          reportUnreachable = "error",
          reportAny = false,
          reportImplicitOverride = false,
          reportUnknownVariableType = false,
          reportUninitializedInstanceVariable = false,
          reportMissingTypeArgument = false, -- Don't complain about `list` usage in types etc.
          reportUnknownParameterType = false, -- ditto
          reportUnknownArgumentType = "info",
          reportDeprecated = false,
          reportUnnecessaryIsInstance = false, -- `isinstance()` inside a typed is type-time vs runtime check
          reportUnusedCallResult = false, -- Too many python functions return values and it's common to not use them
          reportImplicitStringConcatenation = false, -- Let ruff deal with this
          reportMissingImports = "unused", -- Make these lower priority
          reportImportCycles = false, -- Too noisy, imports are due to `if TYPE_CHECKING`, not runtime cycles.
        },
      },
    },
  },
})

vim.lsp.config('ruff', {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    -- Use default format expre for `gq`/`gw` etc so that I can wrap comments normally
    vim.bo[bufnr].formatexpr = nil
  end,
  filetypes = { "python" },
})
vim.lsp.enable "ruff"

vim.lsp.config("gopls", {
  cmd = { "gopls", "serve" },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})
vim.lsp.enable "gopls"
