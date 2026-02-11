vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate"
	},
	--{
	--	"ellisonleao/gruvbox.nvim",
	--	priority = 1000,
	--	config = true
	--},
	--{
	--	"navarasu/onedark.nvim",
	--	priority = 1000,
	--	config = function()
	--		require('onedark').setup {
	--			-- style: dark, darker, cool, deep, warm, warmer, light
	--			style = 'darker'
	--		}
	--		vim.cmd.colorscheme 'onedark'
	--	end,
	--},
	--{
	--	"folke/tokyonight.nvim",
	--	priority = 1000,
	--	config = function()
	--		vim.cmd.colorscheme 'tokyonight-night'
	--	end,
	--},
	{
		"shaunsingh/nord.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme 'nord'
		end,
	},
	{
		"nvim-telescope/telescope.nvim",


		dependencies = {
			"nvim-lua/plenary.nvim"
		}
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				view = { width = 30 },
				renderer = { group_empty = true },
			})
		end,
		keys = { {
			"<leader>e",
			"<cmd>NvimTreeToggle<cr>",
			desc = "Toggle Explorer"
		} }
	},
	{
		"akinsho/bufferline.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		version = "*",
		opts = {
			options = {
				mode = "buffers",
				show_buffer_close_icons = false,
				show_close_icon = false,
			},
		},
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = true,
		keys = { {
			"<C-\\>",
			"<cmd>ToggleTerm<cr>",
			desc = "Toggle Terminal"
		} }
	},
})

--vim.cmd([[colorscheme gruvbox]])

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<S-h>', ":bprevious<CR>", {})
vim.keymap.set('n', '<S-l>', ':bnext<CR>', {})
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', {})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		local params = vim.lsp.util.make_range_params()
		params.context = {only = { "source.organizeImports" }}
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
		for cid, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
				end
			end
		end
		vim.lsp.buf.format({async = false})
	end,
})
