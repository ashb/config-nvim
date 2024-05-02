local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "tsserver", "ccls", "rust_analyzer", "tilt" }

require 'lspconfig.configs'.tilt = {
  default_config = {
  cmd = { "tilt", "lsp", "start" },
  filetypes = { "tilt" },
    root_dir = lspconfig.util.root_pattern(".git"),
  }
}


local on_attach = function(client, bufnr)
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  require("nvchad.configs.lspconfig").on_attach(client, bufnr)

  -- Remove nvchad's "<spc>ra" hotkey
  pcall(vim.keymap.del, "n", "<leader>rn", { buffer = bufnr })

  local keys = {
    -- Set up our glances-specific key maps for this buffer (replace the ones NvChad sets)
    { "gr", "<CMD>Glance references<CR>", opts "Glance references" },
    { "gi", "<CMD>Glance implementations<CR>", opts "Glance implementations" },
    { "gD", "<CMD>Glance definitions<CR>", opts "Glance definition" },
    { "<space>D", "<CMD>Glance type_definitions<CR>", opts "Glance type definition" },

    -- Incremenetal rename/preview as you type
    {
      "<F2>",
      function()
        -- Load it now
        require "inc_rename"
        return ":IncRename " .. vim.fn.expand "<cword>"
      end,
      { expr = true },
      opts "LSP Rename",
    },
    {
      "<leader>l",
      "<CMD>Neotree document_symbols float selector=false toggle<CR>",
      opts "Document symbols",
    },
  }

  for _, key in pairs(keys) do
    -- Remove the existing mapping if any
    pcall(vim.keymap.del, "n", key[1], key[3])
    vim.keymap.set("n", key[1], key[2], key[3])
  end
end

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
  on_init = on_init,
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
  on_init = on_init,
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
  on_init = on_init,
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
