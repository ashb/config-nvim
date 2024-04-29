local extra_pinned_filetypes = {
  "blame",
}

local pinned_buftypes = {
  "terminal",
}

local M = {
  get_auto_pin = function(bufnr)
    local buftype = vim.bo[bufnr].buftype
    local filetype = vim.bo[bufnr].filetype
    if vim.tbl_contains(pinned_buftypes, buftype) then
      -- Disable ctrl-6 to switch to alternate file on this buffer
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-^>", "<nop>", {})
      return "buftype"
    elseif vim.tbl_contains(extra_pinned_filetypes, filetype) then
      return "filetype"
    end
    return require("stickybuf").should_auto_pin(bufnr)
  end,
}


return M
