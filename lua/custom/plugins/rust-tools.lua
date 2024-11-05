return {
  'simrat39/rust-tools.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'neovim/nvim-lspconfig',
  },

  config = function()
    require('rust-tools').setup {
      tools = {
        inlay_hints = {
          highlight = 'InlayHint',
        },
      },
      on_attach = function(client, bufnr)
        require('lsp-format').on_attach(client, bufnr)
      end,
    }
  end,
}
