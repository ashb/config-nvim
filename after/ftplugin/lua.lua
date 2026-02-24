-- lua_ls is enabled here (not in lspconfig.lua with the other servers) because
-- lazydev must be loaded first. lazydev hooks lua_ls's workspace/configuration
-- handler, and if lua_ls starts before that hook is in place, lazydev's first
-- settings push can overwrite lua_ls's static config (including diagnostics.globals).
require("lazydev")
vim.lsp.enable("lua_ls")
