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

vim.lsp.config("ruff", {
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
