vim.wo.statuscolumn = ""
vim.wo.signcolumn = "no"

-- Don't let anything else use this split!
-- Toggleterm does some stuff after creating the split, so we need to delay this
vim.schedule(function()
  vim.wo.winfixbuf = true
end)

-- Define a function to open file under cursor in an existing split
local function open_file_in_split()
  local file, line = "", ""
  -- Check if there's a file name under the cursor
  file = vim.fn.expand "<cfile>"
  if file == "" then
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

  -- Open the file in the existing split and go to the specified line
  vim.cmd("wincmd w | edit " .. file)
  local lineNo = tonumber(line)
  if lineNo ~= nil then
    vim.cmd("" .. lineNo)
  end
end

-- Map 'gf' in terminal mode to call the function
vim.keymap.set("n", "gf", open_file_in_split, { buffer = true })
