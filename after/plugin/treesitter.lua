local _grammar_loaded = {}
local function load_nix_grammar(nix_pack_dir, lang)
  if not nix_pack_dir or _grammar_loaded[lang] then return end
  _grammar_loaded[lang] = true
  local dir = nix_pack_dir .. "/pack/myNeovimPackages/start/vimplugin-treesitter-grammar-" .. lang
  if vim.uv.fs_stat(dir) then
    vim.opt.rtp:append(dir)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local nix_pack_dir = require("options").nix_pack_dir
    local ft = vim.bo[args.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft) or ft
    -- Injection-heavy formats: load all grammars upfront so embedded code blocks highlight correctly.
    if ft == "markdown" or ft == "rst" then
      for _, dir in ipairs(vim.fn.glob(nix_pack_dir .. "/pack/myNeovimPackages/start/vimplugin-treesitter-grammar-*", false, true)) do
        load_nix_grammar(nix_pack_dir, dir:match("grammar%-(.-)$"))
      end
    else
      load_nix_grammar(nix_pack_dir, lang)
    end
    pcall(vim.treesitter.start, args.buf)
  end,
})
