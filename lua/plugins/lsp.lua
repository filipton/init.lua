local function setupLsp()
    local handle = io.popen('uname -m')
    if handle == nil then
        return
    end
    local arch = handle:read("*a")
    handle:close()
    arch = string.gsub(arch, "\n", "")

    local lsp = require('lsp-zero')

    local lsp_attach = function(client, bufnr)
        lsp.default_keymaps({ buffer = bufnr })
        local opts = { buffer = bufnr, remap = false }

        if client.name == "eslint" then
            vim.cmd.LspStop('eslint')
            return
        end

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
    end

    lsp.extend_lspconfig({
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        lsp_attach = lsp_attach,
        float_border = 'rounded',
        sign_text = true,
    })

    lsp.extend_cmp()

    --[[
    local function setupArduinoLsp()
        local fqbnpath = vim.fn.getcwd() .. '/FQBN'
        local fqbn = vim.fn.filereadable(fqbnpath) == 1 and vim.fn.readfile(fqbnpath)[1] or nil

        if fqbn == nil then
            return
        end

        require('lspconfig').arduino_language_server.setup {
            cmd = {
                "arduino-language-server",
                "-cli-config", "~/.arduino15/arduino-cli.yaml",
                "-fqbn", fqbn,
            }
        }
    end
    ]] --

    local ensure_installed = { 'lua_ls', 'rust_analyzer' }
    if arch == "aarch64" then
        require('lspconfig').clangd.setup {
            cmd = { "clangd", "--background-index" },
            filetypes = { "c", "cpp", "objc", "objcpp" },
        }
    else
        table.insert(ensure_installed, 'clangd')
    end

    require('mason').setup({})
    require('mason-lspconfig').setup({
        ensure_installed = ensure_installed,
        handlers = {
            lsp.default_setup,
            lua_ls = function()
                require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
            end,
            arduino_language_server = function()
                --[[
                if vim.fn.executable('arduino-language-server') == 1 then
                    setupArduinoLsp()
                end
                ]] --
            end,
        },
    })

    -- [[
    -- Fix Undefined global 'vim'
    lsp.configure('lua_ls', {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' }
                }
            }
        }
    })
    -- ]]


    local cmp = require('cmp')
    local cmp_action = require('lsp-zero').cmp_action()

    cmp.setup({
        mapping = {
            -- `Enter` key to confirm completion
            ['<CR>'] = cmp.mapping.confirm({ select = false }),
            -- Ctrl+Space to trigger completion menu
            ['<C-Space>'] = cmp.mapping.complete(),
            -- Navigate between snippet placeholder
            ['<C-f>'] = cmp_action.luasnip_jump_forward(),
            ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        },
        sources = {
            { name = 'copilot' },
            { name = 'nvim_lsp' },
            { name = 'path' },
            { name = 'luasnip' },
            { name = 'buffer' },
        },
    })

    vim.diagnostic.config({
        virtual_text = true,
    })

    lsp.setup()
end

return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v4.x',
    },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/nvim-cmp' },
    { 'L3MON4D3/LuaSnip' },
    {
        'neovim/nvim-lspconfig',
        config = setupLsp
    }
};
