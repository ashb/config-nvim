local lspconfig = require "lspconfig"
local servers = { "ccls", "rust_analyzer", "tilt", "nil_ls" }

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("lspconfig.configs").tilt = {
  default_config = {
    cmd = { "tilt", "lsp", "start" },
    filetypes = { "tilt" },
    root_dir = lspconfig.util.root_pattern ".git",
  },
}

local function on_attach(_, bufnr)
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

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }
end

lspconfig.lua_ls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
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

lspconfig.basedpyright.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false

    on_attach(client, bufnr)
  end,
  filetypes = { "python" },
  before_init = function(_, cfg)
    local Path = require "plenary.path"
    local root = cfg.root_dir:gsub("/", Path.path.sep)
    local venv = Path:new(root, ".venv")
    local poetry_lock = Path:new(root, "poetry.lock")

    local pythonPath
    if poetry_lock:is_file() then
      pythonPath = vim.fn.system({ "poetry", "env", "info", "--executable" }):gsub("\n$", "")
    elseif venv:joinpath("bin"):is_dir() then
      pythonPath = tostring(venv:joinpath("bin", "python"))
    else
      pythonPath = tostring(venv:joinpath("Scripts", "python.exe"))
    end

    if pythonPath then
      cfg.settings.python = {pythonPath = pythonPath}
    end
  end,
  settings = {
    basedpyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
  },
}

lspconfig.ruff_lsp.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Use default format expre for `gq`/`gw` etc so that I can wrap comments normally
    vim.api.nvim_set_option_value("formatexpr", "", { buf = bufnr })
    on_attach(client, bufnr)
  end,
  filetypes = { "python" },
}

lspconfig.gopls.setup {
  capabilities = capabilities,
  on_attach = on_attach,
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

lspconfig.tsserver.setup {
  cmd = { "vtsls", "--stdio" },
  capabilities = capabilities,
  on_attach = on_attach,
}
