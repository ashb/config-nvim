local g = vim.g
local o = vim.o
local opt = vim.opt

o.laststatus = 3 -- show a global status line as we use incline for per-window status
o.showmode = false

o.clipboard = "unnamedplus"
o.cursorline = true
o.cursorlineopt = "number"

-- Set this before Noice is loaded, otherwise we can't seem to override the cursor stlying
opt.guicursor:append "a:Cursor/lCursor"

-- Indenting
o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2

opt.fillchars = { eob = " " }
o.ignorecase = true
o.smartcase = true
o.mouse = "a"
o.mousemoveevent = true

-- Numbers
o.number = true
o.numberwidth = 2
o.ruler = false

opt.shortmess:append(
  "s", -- no "search hit TOP/BOTTOM"
  "I", -- disable nvim intro
  "c" -- no completion messages/search pattern messages
)

-- Ask certain operations to confirm instead of blocking
o.confirm = true

-- Always keep some lines below the cursor
o.scrolloff = 3

o.signcolumn = "yes"
o.splitbelow = true
o.splitright = true
o.timeoutlen = 400
o.undofile = true

-- interval for writing swap file to disk, also used by gitsigns
o.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

-- Show trailing space characters visually
o.list = true
opt.listchars = {
  trail = "•",
  tab = "󰌒 ",
}

-- g.mapleader = " "

-- disable some default providers
g["loaded_node_provider"] = 0
g["loaded_python3_provider"] = 0
g["loaded_perl_provider"] = 0
g["loaded_ruby_provider"] = 0

-- add binaries installed by mason.nvim to path
local is_windows = vim.fn.has "win32" ~= 0
vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH

-- Have vim launched from an Neovim terminal use this nvim instance as the editor
-- And delete the buffer when the tab is closed, allowing `nvr` to continue
vim.env.GIT_EDITOR = "nvr --remote-tab-wait -c 'setlocal bufhidden=delete'"

-- Store more stuff in sessions
opt.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "winpos",
}

vim.diagnostic.config {
  virtual_text = {
    prefix = "",
  },
  underline = true,
  -- update_in_insert = false,

  float = {
    border = "single",
  },
}

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})
