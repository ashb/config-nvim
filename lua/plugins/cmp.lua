-- auto completion and snippets related plugins
--
-- This gives LSP configs, plus customizations to the display
--

local function make_buffer_source_conditional(sources)
  local context = require "cmp.config.context"
  for _, s in ipairs(sources) do
    if s.name == "buffer" then
      local get_entries = s.get_entries
      s.get_entries = function(self, ctx)
        if context.in_treesitter_capture "comment" then
          return {}
        end
        return get_entries(self, ctx)
      end

      return
    end
  end
end

return {
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "lukas-reineke/cmp-under-comparator",
      {
        "windwp/nvim-autopairs",
        opts = {
          fast_wrap = {},
          disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
          require("nvim-autopairs").setup(opts)

          -- setup cmp for autopairs
          local cmp_autopairs = require "nvim-autopairs.completion.cmp"
          require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
      },
      "onsails/lspkind.nvim",
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require "cmp"

      make_buffer_source_conditional(cmp.core.sources)

      local defaults = require "cmp.config.default"()

      local unpack = table.unpack or unpack
      local comparators = { unpack(defaults.sorting.comparators) }
      for i, fn in ipairs(comparators) do
        -- We want to put __dunder__ methods just after the exact fn, or else at then end
        if fn == require("cmp.config.compare").exact or i == #comparators then
          table.insert(comparators, i + 1, require("cmp-under-comparator").under)
          break
        end
      end

      return {
        auto_brackets = {}, -- configure any filetype to auto add brackets
        completion = {
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
          col_offset = -3,
          side_padding = 0,
          completeopt = "menu,menuone,noinsert",
          keyword_length = 1,
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
          ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          -- Show completion window
          ["<C-Space>"] = cmp.mapping(
            cmp.mapping.complete {
              reason = cmp.ContextReason.Auto,
            },
            { "i", "c" }
          ),
          ["<C-e>"] = cmp.mapping.abort(),
          -- Accept suggestion. Mnemonic: "yes"
          ["<C-y>"] = cmp.mapping(
            cmp.mapping.confirm {
              behavior = cmp.ConfirmBehavior.Insert,
              select = true,
            },
            { "i", "c", desc = "Accept completion" }
          ),
        },
        sources = cmp.config.sources({
          {
            name = "nvim_lsp",
            -- Dont suggest Text from nvm_lsp
            entry_filter = function(entry)
              return require("cmp").lsp.CompletionItemKind.Text ~= entry:get_kind()
            end,
          },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = {
          unpack(defaults.sorting),
          comparators = comparators,
        },

        formatting = {
          fields = { "kind", "abbr", "menu" },
          -- Move the "kind" incon to the left of the item, and the source on the right hand side
          format = function(entry, vim_item)
            local kind = require("lspkind").cmp_format {
              mode = "symbol_text",
              maxwidth = 50,
              menu = {
                buffer = "󱋊 ",
                nvim_lsp = " ",
                luasnip = "󰩫 ",
                nvim_lua = "󰢱 ",
              },
            }(entry, vim_item)

            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = " " .. (strings[1] or "") .. " "

            return kind
          end,
        },
      }
    end,
    config = function(_, opts)
      require("cmp").setup(opts)

      -- Filetype specific overrides
      require("cmp").setup.filetype({ "gitcommit", "markdown" }, { completion = { autocomplete = false } })
    end,
  },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      {
        "nvim-cmp",
        dependencies = {
          "saadparwaiz1/cmp_luasnip",
        },
        opts = function(_, opts)
          opts.snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          }
          table.insert(opts.sources, { name = "luasnip" })
        end,
      },
    },
    cmd = { "LuaSnipListAvailable" },
    opts = {
      history = true,
      updateevents = "TextChanged,TextChangedI",
      delete_check_events = "InsertLeave",
      region_check_events = "InsertEnter",
    },
    keys = require("mappings").luasnip,
  },
}
