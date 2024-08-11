local M = {}

local lspconfig = require('lspconfig')

function M.setup()
  --local caps = vim.tbl_deep_extend(
    --'force',
    --vim.lsp.protocol.make_client_capabilities(),
    --require('cmp_nvim_lsp').default_capabilities(),
    ---- File watching is disabled by default for neovim.
    ---- See: https://github.com/neovim/neovim/pull/22405
    --{ workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
  --);

  --require 'lspconfig'.html.setup {
    --capabilities = caps,
    --on_attach = function(client, bufnr)
      ---- Custom on_attach logic
      --vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>t', '<cmd>!bash %<CR>', { noremap = true, silent = true })
    --end
  --}

  --Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require'lspconfig'.html.setup {
  capabilities = capabilities,
}
end

return M
