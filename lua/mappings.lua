local map = vim.keymap.set

-- Some global mappings, not plugin specific
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map("n", "<tab>", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
map("n", "<S-tab>", "<cmd>bprev<CR>", { desc = "Go to previous buffer" })

map("n", ",r", function()
  local Path = require("plenary").path
  local dir = Path:new(vim.fn.expand "%:p:h"):make_relative()
  require("telescope.builtin").find_files { prompt_title = "Relative to " .. dir .. "/", cwd = dir }
end, { desc = "Find files relative to the current buffer" })

map("n", ",g", function()
  local Path = require("plenary").path
  local dir = Path:new(vim.fn.expand "%:p:h"):make_relative()
  require("telescope.builtin").live_grep { prompt_title = "Live Grep relative to " .. dir .. "/", search_dir = { dir } }
end, { desc = "Grep relative to the current buffer" })

map("t", "<C-x>", "<C-\\><C-N>", { desc = "Escape terminal mode" })

-- These mappings control the size of splits (height/width)
map("n", "<M-,>", "<c-w>5<")
map("n", "<M-.>", "<c-w>5>")
map("n", "<M-t>", "<C-W>+")
map("n", "<M-s>", "<C-W>-")

-- Line number display
map("n", "cor", "<cmd>set relativenumber!<CR>", { desc = "Toggle Relative number" })
map("n", "con", "<cmd>set number!<CR>", { desc = "Toggle Line number" })

map("n", "cos", "<cmd>setl spell!<CR>", { desc = "Toggle spelling" })

map("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- Profling
map("n", "<leader>up", "<nop>", { desc = "Perf Profling" })
map("n", "<leader>ups", function()
  vim.cmd [[
        :profile start /tmp/nvim-profile.log
        :profile func *
        :profile file *
      ]]
end, { desc = "Profile Start" })
map("n", "<leader>upe", function()
  vim.cmd [[
        :profile stop
        :e /tmp/nvim-profile.log
      ]]
end, { desc = "Profile End" })

local M = {}

-- Focus the existing non-floating neotree, or else show one
local function FocusOrShowNeotree()
  if vim.bo.filetype == "neo-tree" then
    vim.api.nvim_win_close(0, false)
    return
  end
  local wins = vim.api.nvim_list_wins()
  for _, w in ipairs(wins) do
    local buf_nr = vim.api.nvim_win_get_buf(w)
    local ftype = vim.api.nvim_get_option_value("filetype", { buf = buf_nr })
    if ftype == "neo-tree" then
      -- Are we floating, or not?
      local pos = vim.api.nvim_buf_get_var(buf_nr, "neo_tree_position")
      local source = vim.api.nvim_buf_get_var(buf_nr, "neo_tree_source")
      if pos == "left" then
        if source == "filesystem" then
          require("neo-tree.command").execute { source_name = source, action = "focus", reveal = true }
        end
        vim.api.nvim_set_current_win(w)
        return
      end
    end
  end

  vim.cmd "Neotree reveal"
end

M.neotree = {
  { "<C-n>", FocusOrShowNeotree, desc = "NeoTree Show" },
}

local function PeekFoldOrShowLSPHover()
  local winid = require("ufo").peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end

M.lsp = {
  { "K", PeekFoldOrShowLSPHover, desc = "LSP Peek Fold/hover information" },
  { "<leader>ca", vim.lsp.buf.code_action, desc = "LSP Code Actions" },
}

M.ufo = {
  {
    "zR",
    function()
      require("ufo").openAllFolds()
    end,
    desc = "Folds Open All Folds",
  },
  {
    "zM",
    function()
      require("ufo").closeAllFolds()
    end,
    desc = "Folds Close All Folds",
  },
}

M.telescope = {
  { "<leader>fw", "<cmd>Telescope live_grep<CR>", desc = "Telescope live grep" },
  { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Telescope find buffers" },
  { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Telescope help page" },
  { "<leader>ma", "<cmd>Telescope marks<CR>", desc = "Telescope find marks" },
  { "<leader>fo", "<cmd>Telescope oldfiles only_cwd=true<CR>", desc = "Telescope find oldfiles" },
  { "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Telescope find in current buffer" },
  { "<leader>cm", "<cmd>Telescope git_commits<CR>", desc = "Telescope git commits" },
  { "<leader>gt", "<cmd>Telescope git_status<CR>", desc = "Telescope git status" },
  { "<leader>pt", "<cmd>Telescope terms<CR>", desc = "Telescope pick hidden term" },
  { "<leader>th", "<cmd>Telescope themes<CR>", desc = "Telescope nvchad themes" },
  {
    "<leader>fa",
    "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
    desc = "Telescope find all files",
  },

  { "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Telescope Find files in project" },
  { "<leader>r", "<cmd>Telescope resume<CR>", desc = "Telescope Resume last telescope" },
}

M.conform = {
  {
    "<leader>fm",
    function()
      require("conform").format { async = true, lsp_fallback = true }
    end,
    desc = "format files",
  },
}

M.toggleterm = {
  { "<M-i>", "<cmd>ToggleTerm direction=float<CR>", mode = { "t", "i", "n" } },
  { "<M-h>", "<cmd>ToggleTerm direction=horizontal<CR>", mode = { "t", "i", "n" } },
  {
    "<M-v>",
    function()
      local existing_vertical = require("toggleterm.terminal").find(function(t)
        return t.direction == "vertical"
      end)
      if existing_vertical ~= nil then
        existing_vertical:toggle()
        return
      end
      require("toggleterm").toggle(1, math.ceil(vim.o.columns * 0.3), ".", "vertical")
    end,
    mode = { "t", "i", "n" },
    desc = "Open terminal in vertical split",
  },
}

M.bufdelete = {
  { "<leader>x", "<cmd>Bwipeout<CR>", desc = "Clsoe buffer" },
}

M.glance = {
  { "gr", "<CMD>Glance references<CR>", desc = "Glance at references" },
  { "gi", "<CMD>Glance implementations<CR>", desc = "Glance at implementations" },
  { "gD", "<CMD>Glance definitions<CR>", desc = "Glance definition" },
  {
    "gd",
    function()
      -- Go to definition if one, show glances window if multiple
      require("glance").open("definitions", {
        hooks = {
          before_open = function(results, open, jump)
            if #results == 1 then
              jump(results[1]) -- argument is optional
            else
              open(results) -- argument is optional
            end
          end,
        },
      })
    end,
    desc = "Go to defitinion",
  },
  { "<space>D", "<CMD>Glance type_definitions<CR>", desc = "Glance type definition" },
}

M.trouble = {
  {
    "<leader>qf",
    "<cmd>Trouble diagnostics toggle<cr>",
    desc = "Diagnostics (Trouble)",
  },
  {
    "<leader>qF",
    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    desc = "Buffer Diagnostics (Trouble)",
  },
  {
    "<leader>cs",
    "<cmd>Trouble lsp_document_symbols focus=1 filter.buf=0<cr>",
    desc = "Buffer LSP symbols (Trouble)",
  },
}

M.luasnip = {
  {
    "<C-k>",
    function()
      local ls = require "luasnip"
      if ls.expand_or_jumpable() then
        ls.expand_or_jump()
      end
    end,
    desc = "Expand current snippet or jump",
    mode = { "s", "i" },
  },
  {
    "<C-j>",
    function()
      local ls = require "luasnip"
      if ls.jumpable(-1) then
        ls.jump(-1)
      end
    end,
    desc = "Jump to previous snippet placeholder",
    mode = { "s", "i" },
  },
  {
    "<C-l>",
    function()
      local ls = require "luasnip"
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end,
    desc = "Cycle between snippet choices",
    mode = "i",
  },
}

M.noice = {
  {
    "<S-Enter>",
    function()
      require("noice").redirect(vim.fn.getcmdline())
    end,
    mode = "c",
    desc = "Redirect command to nice split",
  },
}

M.increname = {
  {
    "<leader>n",
    function()
      return ":IncRename " .. vim.fn.expand "<cword>"
    end,
    expr = true,
    desc = "Rename symbols",
  },
  {
    "<F2>",
    ":IncRename ",
    desc = "Rename symbols",
  },
}

M.gitsigns = {
  { "<leader>rh", "<CMD>Gitsigns reset_hunk<CR>", desc = "Reset Hunk" },
  { "<leader>ph", "<CMD>Gitsigns preview_hunk<CR>", desc = "Preview Hunk" },
  { "<leader>gb", "<CMD>Gitsigns blame_line<CR>", desc = "Blame Line" },
}

return M
