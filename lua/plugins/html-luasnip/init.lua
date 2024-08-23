local M = {}


_G.LUASNIP_DIRECTION = 1

local ls = require('luasnip')
local function jump_back()
  if ls.locally_jumpable(-1) then
    _G.LUASNIP_DIRECTION = -1
    ls.jump(-1)
  end
end
local function tab_complete()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), 'n', false)
  end
end

function M.setup()
  --require("luasnip.loaders.from_lua").load({paths = "~/Lab/LuaLab/nvim-html-config/lua/plugins/html-luasnip/snippets"})
  --require("luasnip.loaders.from_lua").load({ paths = my_init.this_file_path() .. "/snippets" })
  ls.setup({
    history = true,                            -- keep a history of expanded snippets to allow navigation
    updateevents = "TextChanged,TextChangedI", -- update snippets on text changes
    enable_autosnippets = true,                -- enable automatic triggering of snippets
    link_roots = true,                         -- link root snippets to allow easy navigation between them
    keep_roots = true,                         -- keep root snippets in memory for later navigation
    store_selection_keys = '<Tab>',            -- Control-k to store the selected text
  })
  local s = ls.snippet
  local sn = ls.snippet_node
  local isn = ls.indent_snippet_node
  local t = ls.text_node
  local i = ls.insert_node
  local f = ls.function_node
  local c = ls.choice_node
  local d = ls.dynamic_node
  local r = ls.restore_node
  local events = require("luasnip.util.events")
  local ai = require("luasnip.nodes.absolute_indexer")
  local extras = require("luasnip.extras")
  local l = extras.lambda
  local rep = extras.rep
  local p = extras.partial
  local m = extras.match
  local n = extras.nonempty
  local dl = extras.dynamic_lambda
  local fmt = require("luasnip.extras.fmt").fmt
  local fmta = require("luasnip.extras.fmt").fmta
  local conds = require("luasnip.extras.expand_conditions")
  local postfix = require("luasnip.extras.postfix").postfix
  local types = require("luasnip.util.types")
  local parse = require("luasnip.util.parser").parse_snippet
  local ms = ls.multi_snippet
  local k = require("luasnip.nodes.key_indexer").new_key

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local sorters = require("telescope.sorters")

  vim.api.nvim_create_autocmd("User", {
    pattern = "LuasnipChoiceNodeEnter",
    callback = function()
      local choices = ls.get_current_choices()
      if choices then
        vim.defer_fn(function()
          -- Use Telescope to select a choice
          pickers.new({}, {
            prompt_title = "Choose an option:",
            finder = finders.new_table {
              results = choices,
              entry_maker = function(entry)
                return {
                  value = entry,
                  display = "-> " .. entry,
                  ordinal = entry,
                }
              end,
            },
            sorter = sorters.get_generic_fuzzy_sorter(),
            attach_mappings = function(prompt_bufnr, map)
              map('i', '<CR>', function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                if selection then
                  ls.set_choice(selection.index)
                else
                  print("No option selected")
                end
              end)
              return true
            end,
          }):find()
        end, 1000)
      end
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "LuasnipInsertNodeEnter",
    callback = function()
      local node = require("luasnip").session.event_node
      if not ls.choice_active() then
        vim.defer_fn(function()
          local cd = node:get_jump_index()
          local li = vim.fn.input(vim.inspect(cd), node:get_text()[1])
          node:set_text({ li })
          ls.jump(_G.LUASNIP_DIRECTION)
          if not ls.locally_jumpable(_G.LUASNIP_DIRECTION) then
            _G.LUASNIP_DIRECTION = 1
            --ls.exit_out_of_region(node)
            --vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>o", true, false, true), 'n', false)
          end
        end, 100)
      end
    end
  })

  -- filename: {service_name}apiService.tsx
  -- resource: {resource_name} 
  --    create interface with a field type list something  
  --    create interface with primitive fields 

  local api_resource_snippet = {
    s("newApiCall",
      fmt([[
    interface {resource_list} {{
      list{resource_object}: [{resource_object}];
    }}
    interface {resource_object} {{
      key: string;
      field1: string;
      field2?: string;
      {field_key}: {field_val};
    }}
    ]], {
        resource_list = i(1, "resource_list"),
        resource_object = i(2, "resource_object"),

        field_key = i(3,"field_key"),
        field_val = i(4, "field_val"),
      }, {
        repeat_duplicates = true
      })
    )
  }
  local api_service_snippet = {
    s("newApiCall",
      fmt([[
    interface {name} {{
      id: number;
      field1: string;
      field2?: string;
      {field_key}: {field_val};
    }}
    interface {name}Response {{
      data: {name};
      message: string;
    }}
    interface ErrorResponse {{
      message: string;
    }}

    export const {api_call_name} 
    ]], {
        name = i(1, "name"),
        field_key = i(2, "field_key"),
        field_val = i(3, "field_val"),
        api_call_name =  t"ById{name}lH" ,
      }, {
        repeat_duplicates = true
      })
    )
  }

  ls.add_snippets("all", api_service_snippet)

  vim.keymap.set('i', '<Tab>', tab_complete, { silent = true })
  vim.keymap.set({ 'n', 'i' }, '<S-Tab>', jump_back, { silent = true })
  -- set keybinds for both INSERT and VISUAL.
  vim.api.nvim_set_keymap("i", "<leader>n", "<Plug>luasnip-next-choice", {})
  vim.api.nvim_set_keymap("s", "<leader>n", "<Plug>luasnip-next-choice", {})
  vim.api.nvim_set_keymap("i", "<leader>p", "<Plug>luasnip-prev-choice", {})
  vim.api.nvim_set_keymap("s", "<leader>p", "<Plug>luasnip-prev-choice", {})
end

return M
