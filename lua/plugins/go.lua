return {
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
    },
    opts = {
      tag_options = 'json=', -- It has `omitempty` here by default, I don't want that
      diagnostic = false,
      textobjects = false, -- requires nvim-treesitter; track https://github.com/ray-x/go.nvim/issues/613
    },
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
}
