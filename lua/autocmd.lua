local M = {}
function M.setup()
  vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*ApiService.ts", -- Matches any file ending with ApiService.tsx
    callback = function()
      local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
      if first_line == "" then
        local lines = {
          "// Auto-generated file",
          "// Add your content here",
          "import API from '../axiosConfig';",
          "import { handleApiResponse, ApiResponse } from '../utils/handleApiResponse';",
          "import { ErrorResponse } from '../utils/apiTypes';"
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      end
    end,
  })
end

return M
