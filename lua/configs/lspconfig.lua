local lspconfig = require "lspconfig"
local servers = { "tsserver", "ccls", "rust_analyzer", "tilt" }

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("lspconfig.configs").tilt = {
  default_config = {
    cmd = { "tilt", "lsp", "start" },
    filetypes = { "tilt" },
    root_dir = lspconfig.util.root_pattern ".git",
  },
}

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
  }
end

lspconfig.lua_ls.setup {
  capabilities = capabilities,
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
}

lspconfig.pyright.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false

    -- on_attach(client, bufnr)
  end,
  filetypes = { "python" },
  before_init = function(_, cfg)
    local Path = require "plenary.path"
    local root = cfg.root_dir:gsub("/", Path.path.sep)
    local venv = Path:new(root, ".venv")
    local poetry_lock = Path:new(root, "poetry.lock")
    if poetry_lock:is_file() then
      cfg.settings.python.pythonPath = vim.fn.system({ "poetry", "env", "info", "--executable" }):gsub("\n$", "")
    elseif venv:joinpath("bin"):is_dir() then
      cfg.settings.python.pythonPath = tostring(venv:joinpath("bin", "python"))
    else
      cfg.settings.python.pythonPath = tostring(venv:joinpath("Scripts", "python.exe"))
    end
  end,
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
  },
}

lspconfig.ruff_lsp.setup {
  capabilities = capabilities,
  on_attach = function(_, bufnr)
    -- Use default format expre for `gq`/`gw` etc so that I can wrap comments normally
    vim.api.nvim_set_option_value("formatexpr", "", { buf = bufnr })
  end,
  filetypes = { "python" },
}

lspconfig.gopls.setup {
  capabilities = capabilities,
  cmd = { "gopls", "serve" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
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
}
