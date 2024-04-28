local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "tsserver", "ccls", "rust_analyzer" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- Neovim uses LuaJit (5.1 with 5.2 backports)
lspconfig.lua_ls.manager.config.settings.Lua.runtime = { version = "Lua 5.2" }

lspconfig.pyright.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false

    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
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
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    -- Disable hover in favor of Pyright. Otherwise I end up with a "No information available" toast as well as the Pyright hover!
    client.server_capabilities.hoverProvider = false

    -- nvchad disables these by default! https://github.com/NvChad/NvChad/issues/1933
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true

    -- Use default format expre for `gq`/`gw` etc so that I can wrap comments normally
    vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")
  end,
  capabilities = capabilities,
  filetypes = { "python" },
}

lspconfig.gopls.setup {
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    -- nvchad disables these by default! https://github.com/NvChad/NvChad/issues/1933
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true
  end,
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
