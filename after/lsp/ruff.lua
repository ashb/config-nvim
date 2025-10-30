return {
  root_dir = require("_local.python_support").root_dir,
  on_attach = function(client, bufnr)
    -- Use default format expre for `gq`/`gw` etc so that I can wrap comments normally
    vim.bo[bufnr].formatexpr = nil
  end,
  filetypes = { "python" },
  single_file_support = true,
  on_exit = function(code, _, _)
    print("Closing Ruff LSP exited with code: " .. code)
  end,
}
