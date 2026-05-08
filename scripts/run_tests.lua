-- Run mini.test tests headlessly.
-- Usage: nvim --headless -u init.lua -l scripts/run_tests.lua

-- Ensure lazy.nvim plugins are on rtp so mini.test can be required
require("lazy").load { plugins = { "mini.test" } }

local MiniTest = require "mini.test"
MiniTest.setup()
MiniTest.run { collect = { find_files = function() return vim.fn.glob("tests/test_*.lua", true, true) end } }
