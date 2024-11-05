return {
  'nvimtools/none-ls.nvim',
  version = '*',
  dependencies = {
    'jay-babu/mason-null-ls.nvim',
  },
  config = function()
    local null_ls = require 'null-ls'
    local h = require 'null-ls.helpers'

    local trim_whitespace = {
      method = null_ls.methods.FORMATTING,
      filetypes = {},
      generator = h.formatter_factory {
        command = 'awk',
        args = { '{ sub(/[ \t]+$/, ""); print }' },
        to_stdin = true,
      },
    }

    -- you can reuse a shared lspconfig on_attach callback here
    --    local oelint = {
    --        method = null_ls.methods.DIAGNOSTICS,
    --        filetypes = {"bitbake", "bb", "bbappend"},
    --        generator = null_ls.generator ({
    --            command = "oelint-adv",
    --            args = {"--exit-zero"},
    --            to_stdin = true,
    --            from_sterr = true,
    --            format = "line",
    --        }),
    --    }
    --
    --    null_ls.register(oelint)
    null_ls.register(trim_whitespace)

    null_ls.setup {
      root_dir = require('null-ls.utils').root_pattern('.null-ls-root', 'Makefile', '.git', 'pyproject.toml'),
      sources = {
        -- generic stuff
        null_ls.builtins.diagnostics.trail_space,

        -- python
        null_ls.builtins.formatting.isort.with {
          -- matches vscode recommendations
          extra_args = { '--profile', 'black' },
        },
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.pylint.with {
          prefer_local = '.venv/bin',
          extra_args = {
            '--disable',
            'C0114,C0115,C0116', -- missing doc-strings
          },
        },

        -- protobuf
        null_ls.builtins.diagnostics.buf.with {
          command = '/usr/bin/buf',
        },
        null_ls.builtins.formatting.buf.with {
          command = '/usr/bin/buf',
        },

        -- lua
        null_ls.builtins.formatting.stylua,

        -- qml
        null_ls.builtins.diagnostics.qmllint,

        -- markdown
        null_ls.builtins.formatting.markdownlint.with {
          extra_args = function(params)
            local uri = params.lsp_params.textDocument.uri
            if vim.endswith(vim.uri_to_fname(uri), 'notizen.md') then
              return { '--disable', 'MD012' }
            end
          end,
        },
        null_ls.builtins.diagnostics.markdownlint.with {
          extra_args = function(params)
            local uri = params.lsp_params.textDocument.uri
            if vim.endswith(vim.uri_to_fname(uri), 'notizen.md') then
              return { '--disable', 'MD012' }
            end
            return {}
          end,
        },

        -- others
        null_ls.builtins.diagnostics.yamllint,
      },

      -- on_attach = function(client, bufnr)
      --     if client.supports_method 'textDocument/formatting' then
      --         vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      --         vim.api.nvim_create_autocmd('BufWritePre', {
      --             group = augroup,
      --             buffer = bufnr,
      --             callback = function()
      --                 -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
      --                 -- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
      --                 vim.lsp.buf.formatting_sync()
      --             end,
      --         })
      --     end
      -- end,
      on_attach = function(client, bufnr)
        require('lsp-format').on_attach(client, bufnr)
      end,
    }

    -- install null-ls dependencies automatically
    require('mason-null-ls').setup {
      ensure_installed = {},
      automatic_installation = true,
      automatic_setup = true,
    }
  end,
}
