-- local actions = require("telescope.actions")

-- Table to keep track of added files

return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        preview = {
          highlight_line = true, -- Enable line highlighting in preview
          hide_on_startup = true,
        },
        layout_config = {
          width = 0.97, -- 97% of screen width
          height = 0.97, -- 97% of screen height
        },
        file_ignore_patterns = { "node_modules", "vendor" },
        mappings = {
          i = {
            ["<C-h>"] = "which_key",
            ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
            ["<C-g>"] = function(_) -- only works Telescope git_status
              local selection = require("telescope.actions.state").get_selected_entry()
              -- Git root command
              local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
              local file_path = git_root .. "/" .. selection.value
              -- Git add command
              local result = vim.fn.system("git add " .. file_path)
              if result == "" then
                vim.notify("Added file: " .. file_path)
              else
                vim.notify("Failed to add file: " .. file_path .. ". Error: " .. result)
              end
            end,
          },
        },
      },
    },
  },
}

-- keys = {
--   -- LSP
--   {
--     "<leader>ss",
--     function()
--       require("telescope.builtin").lsp_document_symbols({
--         symbols = LazyVim.config.get_kind_filter(),
--         symbol_width = 80, -- Increase this value to show more of the symbol name
--       })
--     end,
--     desc = "Goto Symbol",
--   },

--   {
--     "<leader>sS",
--     function()
--       require("telescope.builtin").lsp_dynamic_workspace_symbols({
--         symbols = LazyVim.config.get_kind_filter(),
--         entry_maker = function(entry)
--           local display = require("telescope.pickers.entry_display").create({
--             separator = " ",
--             items = {
--               { width = 80 }, -- symbol name
--               { width = 20 }, -- path
--             },
--           })
--           -- Get the raw symbol data
--           local symbol = entry.symbol or entry
--           local name = symbol.text or symbol.name
--           -- local kind = entry.kind
--           local filename = symbol.filename or (symbol.location and vim.uri_to_fname(symbol.location.uri)) or ""
--           local rel_filename = require("telescope.utils").transform_path({ cwd = vim.fn.getcwd() }, filename)
--           return {
--             value = symbol,
--             filename = filename,
--             display = function(_)
--               return display({
--                 name,
--                 rel_filename,
--               })
--             end,
--             ordinal = name,
--           }
--         end,
--       })
--     end,
--     desc = "Goto Symbol (Workspace)",
--   },
