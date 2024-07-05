-- TreeSitter is the language/grammar support -- aka syntax highlighting.
--
-- It is better than the native/built language support as it's shared across many editors, and it doesn't use regexes to parse!


return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {

      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = { enable = true },


      ensure_installed = {
        -- defaults
        "vim",
        "vimdoc",
        "lua",

        "python",
        "go",
        "rust",
        "yaml",
        "just",

        -- web dev
        "html",
        "css",
        "javascript",
        "typescript",
        -- "tsx",
        "json",
        --
      },
    },
    dependencies = {
      -- Justfile support for treesitter
      {
        "IndianBoy42/tree-sitter-just",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        build = function()
          require("nvim-treesitter.parsers").get_parser_configs().just = {
            install_info = {
              url = "https://github.com/IndianBoy42/tree-sitter-just", -- local path or git repo
              files = { "src/parser.c", "src/scanner.cc" },
              branch = "main",
              use_makefile = true, -- this may be necessary on MacOS (try if you see compiler errors)
            },
            maintainers = { "@IndianBoy42" },
          }
          vim.cmd.TSInstall("just")
        end,
      },
    },
  },
}
