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
      local node = require("luasnip").session.event_node
      print(vim.inspect(node))
      vim.defer_fn(function()
        local choices = ls.get_current_choices()

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
      end, 1)
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "LuasnipInsertNodeEnter",
    callback = function()
      local node = require("luasnip").session.event_node
      --if not ls.choice_active() then
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
      end, 10)
      --end
    end
  })

  local api_service_snippet = {
    s("apiService",
      fmt([[
      interface {name} {{

      }}
      interface {name}Response {{
        data: {name};
        message: string;
      }}
      interface ErrorResponse {{
        message: string;
      }}

      export const get{name}ById = async ({name_lower}Id:number): Promise<{name}Response> | ErrorResponse> => {{

        try {{
          const response = await API.get<{name}Response>(`/{kebab}s/${{{name_lower}Id}}`);
        }}
      }};
      ]], {
        name = i(1, "name"),
        name_lower = l(l._1:sub(1, 1):lower() .. l._1:sub(2), 1),
        kebab = l(l._1:gsub("(%u)", "-%1"):lower():gsub("^%-", ""), 1)
      }, {
        repeat_duplicates = true
      })
    )
  }
  --ls.add_snippets("all", {
  ---- important! fmt does not return a snippet, it returns a table of nodes.
  --s("example1", fmt("just an {iNode1}", {
  --iNode1 = i(1, "example")
  --})),
  --s("example2", fmt([[
  --if {} then
  --{}
  --end
  --]], {
  ---- i(1) is at nodes[1], i(2) at nodes[2].
  --i(1, "not now"), i(2, "when")
  --})),
  --s("example3", fmt([[
  --if <> then
  --<>
  --end
  --]], {
  ---- i(1) is at nodes[1], i(2) at nodes[2].
  --i(1, "not now"), i(2, "when")
  --}, {
  --delimiters = "<>"
  --})),
  --s("example4", fmt([[
  --repeat {a} with the same key {a}
  --]], {
  --a = i(1, "this will be repeat")
  --}, {
  --repeat_duplicates = true
  --}))
  --})

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
