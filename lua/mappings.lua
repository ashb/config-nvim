local map = vim.keymap.set

-- Some global mappings, not plugin specific
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map("n", "<tab>", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
map("n", "<S-tab>", "<cmd>bprev<CR>", { desc = "Go to previous buffer" })

map("n", ",r", function()
  local dir = vim.fn.fnamemodify(vim.fn.expand "%:p:h", ":.")
  Snacks.picker.files { cwd = dir, title = "Relative to " .. dir .. "/" }
end, { desc = "Find files relative to the current buffer" })

map("n", ",g", function()
  local dir = vim.fn.fnamemodify(vim.fn.expand "%:p:h", ":.")
  Snacks.picker.grep { cwd = dir, title = "Live Grep relative to " .. dir .. "/" }
end, { desc = "Grep relative to the current buffer" })

map("t", "<C-x>", "<C-\\><C-N>", { desc = "Escape terminal mode" })

-- These mappings control the size of splits (height/width)
map("n", "<M-,>", "<c-w>5<")
map("n", "<M-.>", "<c-w>5>")
map("n", "<M-t>", "<C-W>+")
map("n", "<M-s>", "<C-W>-")

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

M.lsp = {
  { "<leader>ca", vim.lsp.buf.code_action, desc = "LSP Code Actions" },
  { "<leader>wa", vim.lsp.buf.add_workspace_folder, desc = "Add folder" },
  { "<leader>wr", vim.lsp.buf.remove_workspace_folder, desc = "remove folder" },
  {
    "<leader>wl",
    function()
      require("guihua.gui").new_list_view {
        border = "rounded",
        title = " LSP Workspace Folders ",
        prompt = false,
        width_ratio = 0.4,
        rect = { height = 10 },
        items = vim.lsp.buf.list_workspace_folders(),
        on_move = function() end,
      }
    end,
    desc = "List folders",
  },
}

local function snackPicker(picker)
  return function()
    Snacks.picker[picker]()
  end
end

M.snacks = {
  { "<C-p>", snackPicker "smart", desc = "Picker Smart Find Files" },
  { "<leader>r", snackPicker "resume", desc = "Picker Resume last" },
  { "<leader>fw", snackPicker "grep", desc = "Pick Live grep" },
  { "<leader>fh", snackPicker "help", desc = "Pick help page" },
  { "<leader>fb", snackPicker "buffers", desc = "Find buffers" },
  { "<leader>gt", snackPicker "git_status", desc = "Git status" },
  {
    "<leader>fa",
    function()
      Snacks.picker.files { hidden = true, ignored = true, follow = true }
    end,
    desc = "Find all files",
  },

  {
    "<leader>.",
    function()
      Snacks.scratch()
    end,
    desc = "Toggle Scratch Buffer",
  },
  {
    "<M-i>",
    function()
      Snacks.terminal.toggle(nil, { env = { __snacks_term = "float" }, win = { position = "float" } })
    end,
    mode = { "t", "i", "n" },
    desc = "Toggle floating terminal",
  },
  {
    "<M-v>",
    function()
      Snacks.terminal.toggle(nil, {
        env = { __snacks_term = "vertical" },
        win = { position = "right", width = math.ceil(vim.o.columns * 0.3) },
      })
    end,
    mode = { "t", "i", "n" },
    desc = "Toggle vertical terminal",
  },
  {
    "<M-h>",
    function()
      Snacks.terminal.toggle(nil, { env = { __snacks_term = "horizontal" }, win = { position = "bottom" } })
    end,
    mode = { "t", "i", "n" },
    desc = "Toggle horizontal terminal",
  },
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

M.bufdelete = {
  { "<leader>x", "<cmd>Bwipeout<CR>", desc = "Close buffer" },
}

M.glance = {
  { "grr", "<CMD>Glance references<CR>", desc = "Glance at references" },
  { "gri", "<CMD>Glance implementations<CR>", desc = "Glance at implementations" },
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
    "<cmd>Trouble symbols focus=1 filter.buf=0<cr>",
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
