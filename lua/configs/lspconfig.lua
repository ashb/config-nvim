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

  local opts = { buffer = bufnr }
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
end

vim.lsp.config("*", {
  capabilities = capabilities,
  on_attach = on_attach,
})

local servers = {
  "basedpyright",
  "ccls",
  "gopls",
  "nil_ls",
  "ruff",
  "rust_analyzer",
  "tilt",
  "vtsls",
  "jdtls",
  "lua_ls",
}
for _, server_name in ipairs(servers) do
  local cmd = vim.lsp.config[server_name].cmd or { server_name }

  if type(cmd) ~= "table" or vim.fn.executable(cmd[1]) == 1 then
    local existing_on_attach = (vim.lsp.config[server_name] or {}).on_attach
    if existing_on_attach then
      vim.lsp.config(server_name, {
        on_attach = function(...)
          existing_on_attach(...)
          on_attach(...)
        end,
      })
    end
    vim.lsp.enable(server_name)
  end
end
