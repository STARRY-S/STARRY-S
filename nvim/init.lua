vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
-- Use tab characters instead of spaces, standard for Go
vim.opt.expandtab = false
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#232323" })
vim.opt.clipboard = "unnamedplus"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

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
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "lua",
                callback = function(args)
                    local root_dir = vim.fs.dirname(vim.fs.find({".git", "init.lua"}, { upward = true, path = args.file })[1])
                    if not root_dir then
                         root_dir = vim.fs.dirname(args.file)
                    end
                    local capabilities = require('cmp_nvim_lsp').default_capabilities()
                    vim.lsp.start({
                        name = "lua_ls",
                        cmd = { "lua-language-server" },
                        root_dir = root_dir,
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim" },
                                },
                                workspace = {
                                    library = vim.api.nvim_get_runtime_file("", true),
                                    checkThirdParty = false,
                                },
                                telemetry = { enable = false },
                            },
                        },
                    })
                end,
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
        highlight = { enabled = false },
    },

    -- === Theme (OneDark Pro) ===
    {
        "olimorris/onedarkpro.nvim",
        priority = 1000,
        config = function()
            vim.cmd("colorscheme onedark")
        end,
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
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            require("go").setup({
                -- Disable internal LSP setup to prevent conflict with Mason
                lsp_cfg = {
                    capabilities = capabilities,
                    settings = {
                        gopls = {
                            -- Force enable semantic tokens for rich highlighting
                            semanticTokens = true,
                            -- Enable more aggressive code analysis
                            analyses = {
                                ST1000 = false,
                                unusedparams = true,
                                shadow = true,
                            },
                        },
                    },
                },

                lsp_semantic_highlights = false,
                lsp_inlay_hints = { enable = false },
            })

            -- Auto-Format on save (using goimports)
            local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.go:",
                callback = function()
                    require("go.format").goimports()
                end,
                group = format_sync_grp,
            })
        end,
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
            -- Custom sort function to sort folders first, then by numeric prefix naturally
            local function sort_by_number(nodes)
                table.sort(nodes, function(a, b)
                    -- Prioritize directories over other file types
                    if a.type ~= b.type then
                        if a.type == "directory" then
                            return true
                        elseif b.type == "directory" then
                            return false
                        end
                    end

                    -- Extract the leading digits from the file or folder name
                    local num_a = tonumber(string.match(a.name, "^%d+"))
                    local num_b = tonumber(string.match(b.name, "^%d+"))

                    -- If both names start with numbers, compare them mathematically
                    if num_a and num_b then
                        if num_a ~= num_b then
                            return num_a < num_b
                        end
                    end

                    -- Fallback to standard alphabetical comparison
                    return a.name < b.name
                end)
            end
            require("nvim-tree").setup({
                view = { width = 30 },
                renderer = { group_empty = true },
                sort = {
                      sorter = sort_by_number,
                },
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
        config = function()
            require("toggleterm").setup({
                -- Use a floating window instead of a horizontal split
                direction = "float",
                float_opts = {
                    -- Add a curved border around the terminal
                    border = "curved",
                },
            })
        end,
        keys = {
            { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" }
        }
    },

    -- === Statusline (Lualine) ===
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    -- Automatically match your current colorscheme (onedark, etc.)
                    theme = 'auto',
                    -- Use modern powerline separators
                    component_separators = { left = '', right = ''},
                    section_separators = { left = '', right = ''},
                    -- Use a single unified statusline for the entire Neovim window
                    globalstatus = true,
                },
                sections = {
                    lualine_c = {
                        {
                            'filename',
                            -- Rename ugly terminal URLs to a clean string
                            fmt = function(name)
                                if name:match("^term://") then
                                    return "Terminal 💻"
                                end
                                return name
                            end,
                        }
                    }
                }
            })
        end
    },

    -- === Git Integration (Gitsigns) ===
    {
        "lewis6991/gitsigns.nvim",
        -- Load plugin only when opening a file to optimize startup time
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                -- Enable inline git blame virtual text
                -- Shows who wrote the line and when, right next to the code
                current_line_blame = true,
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = "eol",
                    -- Delay in milliseconds before showing the blame text
                    delay = 500,
                },
                -- Set up keymaps only for buffers that are tracked by git
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Jump to the next modified block of code
                    map("n", "]c", function()
                        if vim.wo.diff then return "]c" end
                        vim.schedule(function() gs.next_hunk() end)
                        return "<Ignore>"
                    end, { expr = true, desc = "Jump to next git hunk" })

                    -- Jump to the previous modified block of code
                    map("n", "[c", function()
                        if vim.wo.diff then return "[c" end
                        vim.schedule(function() gs.prev_hunk() end)
                        return "<Ignore>"
                    end, { expr = true, desc = "Jump to previous git hunk" })

                    -- Open a floating window to see what exactly was changed
                    map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview git hunk" })

                    -- Revert the changes in the current block
                    map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset git hunk" })
                end
            })
        end
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

vim.o.list = true
vim.o.listchars = 'tab:» ,lead:·,trail:·'

vim.api.nvim_set_hl(0, 'TrailingWhitespace', { bg='#753e3e' })
vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    command = [[
        syntax clear TrailingWhitespace |
        syntax match TrailingWhitespace "\_s\+$"
    ]]}
)

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
