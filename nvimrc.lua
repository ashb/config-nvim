-- This file is only needed if this repo is not checked out to the neovim 
-- standard config path (`~/.config/nvim` on linux/macos). 
--
-- If you want your config to live somewhere else, then:
--
--   `export VIMINIT="source ~/path/to/config-nvim/nvimrc.lua`
local function script_path(path)
  local str = path or debug.getinfo(2, "S").source:sub(2)
  return str:match "^(.+)/[^/]+"
end

local this_dir = script_path()
local parent_dir = script_path(this_dir)

vim.env.XDG_CONFIG_HOME = parent_dir
vim.opt.rtp:prepend(this_dir)

-- Set XDG_CONFIG_HOME for this vim to our path so that lazy.nvim can have `stdpath("config")` point to in
-- here

dofile(this_dir .. "/init.lua")
vim.env.XDG_CONFIG_HOME = nil
