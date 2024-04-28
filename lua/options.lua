require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Have vim launched from an Neovim terminal use this nvim instance as the editor
-- And delete the buffer when the tab is closed, allowing `nvr` to continue
vim.env.GIT_EDITOR = "nvr --remote-tab-wait -c 'setlocal bufhidden=delete'"
