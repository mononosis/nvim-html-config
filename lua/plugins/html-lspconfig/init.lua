local M = {}


function M.setup()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  --require 'lspconfig'.html.setup {
    --capabilities = capabilities,
    --on_attach = function(_, bufnr)
      --vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>fl', "<cmd>lua vim.lsp.buf.format()<CR>", {})
    --end
  --}
  require'lspconfig'.tsserver.setup{

    on_attach = function(_, bufnr)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', "<cmd>lua vim.lsp.buf.definition()<CR>", {})
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>fl', "<cmd>lua vim.lsp.buf.format()<CR>", {})
    end

  }
end

return M
