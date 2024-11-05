-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd [[ let g:neo_tree_remove_legacy_commands = 1 ]]

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  config = function()
    require('lsp-format').setup {}
    require('lspconfig').gopls.setup { on_attach = require('lsp-format').on_attach }
  end,
}
