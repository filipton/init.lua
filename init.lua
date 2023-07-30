require("notpilif")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

require("lazy").setup({
    { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = true, priority = 1000 },
    {
        'glepnir/dashboard-nvim',
        event = 'VimEnter',
        config = function()
            require('dashboard').setup {
                -- config
            }
        end,
        dependencies = { { 'nvim-tree/nvim-web-devicons' } }
    },
    {
        'nvim-telescope/telescope.nvim',
        version = '0.1.1',
        dependencies = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = { "node_modules/", ".git/", "target/" },
                }
            })
        end
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = function()
            vim.cmd([[TSUpdate]])
        end
    },
    {
        'nvim-treesitter/nvim-treesitter-context'
    },
    {
        'nvim-treesitter/playground'
    },
    {
        'mbbill/undotree'
    },
    {
        'tpope/vim-fugitive'
    },
    {
        { 'VonHeikemen/lsp-zero.nvim', branch = 'dev-v3' },

        --- Uncomment these if you want to manage LSP servers from neovim
        {'williamboman/mason.nvim'},
        {'williamboman/mason-lspconfig.nvim'},

        -- LSP Support
        {
            'neovim/nvim-lspconfig',
            dependencies = {
                { 'hrsh7th/cmp-nvim-lsp' },
            },
        },

        -- Autocompletion
        {
            'hrsh7th/nvim-cmp',
            dependencies = {
                { 'L3MON4D3/LuaSnip' },
            }
        }
    },
    {
        'github/copilot.vim'
    },
    {
        'j-hui/fidget.nvim'
    },
    {
        'nvim-lualine/lualine.nvim',
        -- event = { 'VimEnter' },
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        }
    },
    {
        'linrongbin16/lsp-progress.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lsp-progress').setup()
        end
    },
    {
        'ThePrimeagen/harpoon'
    },
    {
        'folke/trouble.nvim',
        requires = 'nvim-tree/nvim-web-devicons',
        config = function()
            require("trouble").setup({})
        end
    }
})
