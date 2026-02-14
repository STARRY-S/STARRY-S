-- =========================================
-- Basic Settings
-- =========================================
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- Use tab characters instead of spaces, standard for Go
vim.opt.expandtab = false
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#232323" })

-- =========================================
-- Network Proxy Configuration
-- =========================================
local proxy = "http://10.128.0.1:8818"
vim.env.http_proxy = proxy
vim.env.https_proxy = proxy
vim.env.all_proxy = proxy
vim.env.no_proxy = "127.0.0.1,localhost,::1,.cn,.local,.lan,.hxstarrys.me"

-- =========================================
-- Plugin Manager (Lazy.nvim)
-- =========================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Install lazy.nvim if not found
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

-- =========================================
-- Plugins Setup
-- =========================================
require("lazy").setup({
	-- === LSP Configuration ===
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
			local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})
        end
    },

    -- === Syntax Highlighting (Treesitter) ===
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        ensure_installed = {
        	"go", "gomod", "lua",
            "json", "yaml", "python", "c", "cpp",
            "markdown", "markdown_inline",
            "javascript", "typescript", "rust", "tsx",
        },
        -- highlight = { enabled = true },
    },

    -- === Theme (OneDark) ===
    {
        "navarasu/onedark.nvim",
        priority = 1000,
        config = function()
            require('onedark').setup {
                style = 'darker',
				-- Enable this to use LSP-based semantic highlighting
				diagnostics = {
					undercurl = true,
					background = false,
				},
            }
            vim.cmd.colorscheme 'onedark'
        end,
    },

	{
    	'ray-x/aurora',
		priority = 1300,
    	init = function()
      		vim.g.aurora_italic = 1
      		vim.g.aurora_transparent = 1
      		vim.g.aurora_bold = 1
    	end,
    	config = function()
        	vim.cmd.colorscheme "aurora"
        	-- override defaults
        	vim.api.nvim_set_hl(0, '@number', {fg='#e933e3'})
    	end
    },

	-- === Theme: Catppuccin ===
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1200,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha", -- latte, frappe, macchiato, mocha
                term_colors = true,
                transparent_background = false,
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    treesitter = true,
                    telescope = true,
                    mason = true,
                },
            })
            vim.cmd.colorscheme "catppuccin"
        end,
    },

	-- === Go Tools (ray-x/go.nvim) ===
    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup({
                -- Disable internal LSP setup to prevent conflict with Mason
                lsp_cfg = true,

				lsp_semantic_highlights = true,

				lsp_on_attach = function(client, bufnr)
				end,

				gopls_cmd = nil, -- use system gopls automatically
                -- Disable inlay hints to use Neovim's native ones (optional)
                lsp_inlay_hints = { enable = false },
            })

            -- Auto-Format on save (using goimports)
            local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.go",
                callback = function()
                    require("go.format").goimports()
                end,
                group = format_sync_grp,
            })
        end,
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()'
    },

    -- === Fuzzy Finder (Telescope) ===
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- === File Explorer (Nvim Tree) ===
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                view = { width = 30 },
                renderer = { group_empty = true },
            })
        end,
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle Explorer" }
        }
    },

    -- === Terminal (ToggleTerm) ===
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = true,
        keys = {
            { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" }
        }
    },

    -- === Markdown Rendering ===
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
        opts = {},
        ft = { "markdown" },
    },

    -- === Autocomplete (Nvim-CMP) ===
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                -- Configure snippet engine
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                -- Add borders to completion windows
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                -- Keyboard shortcuts
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),

                    -- Super-Tab behavior
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),

                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                -- Sources for autocompletion
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                    { name = 'path' },
                }),
            })
        end
    },
})

-- =========================================
-- Keymaps
-- =========================================
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<S-h>', ":bprevious<CR>", {})
vim.keymap.set('n', '<S-l>', ':bnext<CR>', {})
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', {})

-- =========================================
-- Autocmds (Automation)
-- =========================================

-- Visual Guides: 80/120 for code, 50/72 for git/markdown
vim.opt_local.colorcolumn = "80,120"
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.colorcolumn = "50,72"
    end,
})

-- Highlight trailing whitespace in red
-- Ignore special buffers like terminal or file explorer
vim.api.nvim_set_hl(0, "TrailingSpace", { bg = "#753e3e" })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufEnter" }, {
    pattern = "*",
    callback = function()
        local ignore_buftypes = { "terminal", "nofile", "prompt", "quickfix" }
        local ignore_filetypes = { "alpha", "dashboard", "NvimTree", "TelescopePrompt", "mason", "lazy" }

        -- Check if current buffer should be ignored
        if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) or vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            pcall(vim.fn.matchdelete, vim.w.trailing_match_id)
            return
        end

        -- Clean up previous match to avoid duplicates
        if vim.w.trailing_match_id then
            pcall(vim.fn.matchdelete, vim.w.trailing_match_id)
            vim.w.trailing_match_id = nil
        end

        -- Apply high priority highlighting
        local id = vim.fn.matchadd("TrailingSpace", "\\s\\+$", 100)
        vim.w.trailing_match_id = id
    end
})

-- Auto-trim trailing whitespace on save
-- Exception: Skip markdown files to preserve hard breaks
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "markdown" then
            return
        end

        -- Save view to restore cursor position later
        local save_view = vim.fn.winsaveview()

        -- Execute substitution
        vim.cmd([[ %s/\s\+$//e ]])

        -- Restore view
        vim.fn.winrestview(save_view)
    end,
})
