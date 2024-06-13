vim.wo.statuscolumn = ""
vim.wo.signcolumn = "no"

-- Don't let anything else use this split!
-- Toggleterm does some stuff after creating the split, so we need to delay this
vim.schedule(function()
  vim.wo.winfixbuf = true
end)

-- Define a function to open file under cursor in an existing split
local function open_file_in_split()
  local file, cfile, line = "", "", ""
  -- Check if there's a file name under the cursor
  cfile = vim.fn.expand "<cfile>"
  if cfile == "" then
    return
  end
  local line_content = vim.fn.getline "."

  -- Try matching different patterns:
  -- file:line
  file, line = line_content:match "([^:]+):(%d+)"
  -- file @ line
  if not file then
    file, line = line_content:match "([^%s]+)%s*@%s*(%d+)"
  end
  -- file line line
  if not file then
    file, line = line_content:match "([^%s]+)%s+line%s+(%d+)"
  end
  if not file then
    file = cfile
  end

  local Path = require "plenary.path"

  file = Path:new(file)
  if not file:is_absolute() then
    local focused_term = require("toggleterm.terminal").find(function(term)
      return term:is_focused()
    end)
    if focused_term and focused_term.dir then
      -- This is not perfect way of making relative path absolute, but eh.
      file = Path:new(focused_term.dir) / file
    end
  end
  file = tostring(file)

  -- Open the file in the existing split and go to the specified line
  vim.cmd("wincmd w | edit " .. file)
  local lineNo = tonumber(line)
  if lineNo ~= nil then
    vim.cmd("" .. lineNo)
  end
end

-- Map 'gf' in terminal mode to call the function
vim.keymap.set("n", "gf", open_file_in_split, { buffer = true })
