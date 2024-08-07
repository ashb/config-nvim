return {
  "williamboman/mason.nvim",
  cmd = { "Mason", "MasonInstall" },
  opts = {
    ensure_installed = {
      -- lua
      "lua-language-server",
      "stylua",

      -- go
      "gopls",

      -- python
      "debugpy",
      "ruff",

      -- js/typescript
      "vtsls",

      -- rust
      -- "rust-analyzer", -- use rust-up for thisx
      "codelldb",

      -- c++ etc
      "ccls",
    },
  },
}

