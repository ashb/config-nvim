require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local del = vim.keymap.del

-- Neotree -- disable
del("n", "<leader>e")

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Focus the existing non-floating neotree, or else show one
local function FocusOrShowNeotree()
  if vim.bo.filetype == "neo-tree" then
    vim.api.nvim_win_close(0, false)
    return
  end
  local wins = vim.api.nvim_list_wins()
  for _, w in ipairs(wins) do
    local buf_nr = vim.api.nvim_win_get_buf(w)
    local ftype = vim.api.nvim_buf_get_option(buf_nr, "filetype")
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
map("n", "<C-n>", FocusOrShowNeotree, { desc = "NeoTree Show" })

map("n", ",r", function()
  require("configs.telescope").relative_to_current_file()
end, { desc = "Telescope Find files relative to the current buffer" })
map("n", "<C-p>", "<cmd> Telescope find_files <CR>", { desc = "Telescope Find files in project" })
map("n", "<leader>r", "<cmd>Telescope resume<CR>", { desc = "Telescope Resume last telescope" })

map("n", "cor", "<cmd>set relativenumber!<CR>", { desc = "Toggle Relative number" })
map("n", "con", "<cmd>set number!<CR>", { desc = "Toggle Line number" })

map("n", "K", function()
  local winid = require("ufo").peekFoldedLinesUnderCursor()
  if not winid then
    vim.lsp.buf.hover()
  end
end, { desc = "LSP Peek Fold/hover information" })

-- Disable the default C-c to copy the entire file!
map("n", "<C-c>", "<Nop>", { noremap = true, silent = true })
