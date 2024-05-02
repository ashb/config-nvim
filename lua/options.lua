require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Have vim launched from an Neovim terminal use this nvim instance as the editor
-- And delete the buffer when the tab is closed, allowing `nvr` to continue
vim.env.GIT_EDITOR = "nvr --remote-tab-wait -c 'setlocal bufhidden=delete'"


vim.api.nvim_create_augroup("custom_buffer", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter","BufWinEnter","BufRead","BufNewFile"}, {
  pattern = { "Tiltfile" },
  callback = function()
    vim.bo["ft"] = "tilt"
    vim.treesitter.language.register('python', 'tilt')
  end,
  group = "custom_buffer",
})
