local M = {}
function M.setup()
	local cmp = require("cmp")
	local luasnip = require("luasnip")

	vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
	local formatting = {
		format = require('lspkind').cmp_format({
			mode = 'symbol', -- show only symbol annotations
			maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
			symbol_map = {
				Text = "",
				Method = "",
				Function = "",
				Constructor = "",
				Field = "ﰠ",
				Variable = "",
				Class = "ﴯ",
				Interface = "",
				Module = "",
				Property = "ﰠ",
				Unit = "塞",
				Value = "",
				Enum = "",
				Keyword = "",
				Snippet = "",
				Color = "",
				File = "",
				Reference = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "פּ",
				Event = "",
				Operator = "",
				Copilot = "",
				TypeParameter = "",
			},
		})
	}
	local has_words_before = function()
		if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
	end
	local mapping = {
		    ["<C-p>"] = cmp.mapping.select_prev_item(),
		    ["<C-n>"] = cmp.mapping.select_next_item(),
		    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
		    ["<C-f>"] = cmp.mapping.scroll_docs(4),
		    ["<C-Space>"] = cmp.mapping.complete(),
		    ["<C-e>"] = cmp.mapping.close(),
		    ["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = false }),
		    ["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() and has_words_before then
				cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
			elseif require("luasnip").expand_or_jumpable() then
				vim.fn.feedkeys(
					vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true,
						true,
						true), "")
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
		    ["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif require("luasnip").jumpable(-1) then
				vim.fn.feedkeys(
					vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true,
						true),
					"")
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
	}
	local window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	}
	cmp.setup({
		formatting = formatting,
		snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
		window = window,
		mapping = mapping,
		experimental = {
			ghost_text = true,
		},
		sources = cmp.config.sources({
			{ name = 'nvim_lsp',                group_index = 2 },
			{ name = 'nvim_lsp_signature_help', group_index = 2 },
			{ name = "copilot",                 group_index = 2 },
			{ name = 'path',                    group_index = 2 },
			{ name = 'luasnip',                 group_index = 2 },
			{ name = 'buffer',                  group_index = 3, max_item_count = 3 },
			{ name = 'tmux',                    group_index = 3, max_item_count = 3 },
		})
	})
	-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
	cmp.setup.cmdline('/', {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = 'buffer' }
		}
	})
	-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
	cmp.setup.cmdline(':', {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = 'path' }
		}, {
			{ name = 'cmdline' }
		})
	})
end

return M
