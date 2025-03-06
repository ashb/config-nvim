-- Ui overhaul -- improces cmd line (`:`) and moves a lot of messages to popup windows
local opts = {
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = true, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true, -- add a border to hover docs and signature help
  },

  views = {
    cmdline_popup = {
      border = {
        style = "none",
        padding = { 1, 3 },
      },
      filter_options = {},
      win_options = {
        winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
      },
    },
  },

  routes = {
    {
      filter = {
        any = {
          -- Skip the "file written" (aka Saved!) notifications
          {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          -- Undo/redo messages
          {
            event = "msg_show",
            kind = "",
            find = "^%d [^%s]+ lines?",
          },

          {
            event = "msg_show",
            kind = "",
            find = "^%d lines? [^%s]+",
          },

          {
            event = "msg_show",
            kind = "",
            find = "^%d change; before #%d",
          },
          -- JDTLS (Java Lang server) is very chatty!
          {
            event = "lsp",
            kind = "progress",
            find = "jdtls",
          },
        },
      },
      opts = { skip = true },
    },
  },
}

-- @type LazySpec
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = opts,
    keys = require("mappings").noice,
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        opts = {
          render = "compact",
          timeout = 1250,
          minimum_width = 10,
        },
      },
    },
  },
}
