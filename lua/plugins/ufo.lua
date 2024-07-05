-- The goal of nvim-ufo is to make Neovim's fold look modern and keep high performance.
--
-- Key thing I have here is <S-k> to peek at the currently closed fold.
local M = {}

-- To show number of folded lines
M.fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = (" 󰁂%d "):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0
  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      -- str width returned from truncate() may less than 2nd argument, need padding
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, { suffix, "MoreMsg" })
  return newVirtText
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "nvcheatsheet", "neo-tree", "notify" },
  callback = function()
    vim.opt_local.foldenable = false
    require("ufo").detach()
  end,
})

--return M
return {

  "kevinhwang91/nvim-ufo",
  event = "BufRead",
  ft = { "go", "gomod", "python", "lua" },
  dependencies = {
    { "kevinhwang91/promise-async" },
    {
      -- Clickable status column handlers
      "luukvbaal/statuscol.nvim",
      config = function()
        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
          -- foldfunc = "builtin",
          -- setopt = true,
          relculright = true,
          segments = {
            { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
            { text = { "%s" },                  click = "v:lua.ScSa" },
            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
          },
        })
      end,
    },
  },
  keys = require 'mappings'.ufo,
  opts = M,
  config = function(_, opts)
    -- Fold options -- for UFO
    vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
    vim.o.foldcolumn = "1" -- '0' is not bad
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    require('ufo').setup(opts)
  end
}
