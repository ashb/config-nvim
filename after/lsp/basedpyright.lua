local cfg = {
  single_file_support = true,
  filetypes = { "python" },
  root_dir = require("_local.python_support").root_dir,
  -- on_attach = function(client, _)
  --   vim.diagnostic.config({
  --     virtual_text = {
  --       -- Don't show hint as virtual text, reportUnusedParam from basedpyright is too noisy
  --       severity = { min = vim.diagnostic.severity.INFO },
  --     },
  --   }, vim.lsp.diagnostic.get_namespace(client.id))
  -- end,
  -- reuse_client = function()
  --   return true
  -- end,
  settings = {
    python = {},
    basedpyright = {
      disableOrganizeImports = true, -- Using Ruff's import organizer
      analysis = {
        typeCheckingMode = "standard",
        inlayHints = {
          variableTypes = false,
          functionReturnTypes = false,
        },

        diagnosticSeverityOverrides = {
          reportUnusedImport = false, -- We also have ruff reporting this as F401
          reportUndefinedVariable = false, -- F821
          reportUnusedVariable = false, -- Ditto as F841
          reportUnreachable = "error",
          reportAny = false,
          reportImplicitOverride = false,
          reportUnknownVariableType = false,
          reportUninitializedInstanceVariable = false,
          reportMissingTypeArgument = false, -- Don't complain about `list` usage in types etc.
          reportUnknownParameterType = false, -- ditto
          reportUnknownArgumentType = "info",
          reportDeprecated = false,
          reportUnnecessaryIsInstance = false, -- `isinstance()` inside a typed is type-time vs runtime check
          reportUnusedCallResult = false, -- Too many python functions return values and it's common to not use them
          reportImplicitStringConcatenation = false, -- Let ruff deal with this
          reportMissingImports = "unused", -- Make these lower priority
          reportImportCycles = false, -- Too noisy, imports are due to `if TYPE_CHECKING`, not runtime cycles.
        },
      },
    },
  },
}
return cfg
