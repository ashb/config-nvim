vim.g.mapleader = " "
vim.o.winborder = "rounded"

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  print "Cloning lazy.nvim from Github"
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

require "options"

-- load plugins
require("lazy").setup({
  -- This automatically loads all lua files under lua/plugins/ looking for specs!
  { import = "plugins" },
}, lazy_config)
