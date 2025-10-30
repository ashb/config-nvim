-- Override this to close the buffer too, otherwise it just closes the tab but doesn't delete the buffer
vim.keymap.set("n", "q", "<cmd>bwipeout<CR>", { buffer = true })
