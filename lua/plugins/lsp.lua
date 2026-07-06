local function setupLsp()
    -- Keymaps: applied to every buffer an LSP server attaches to.
    -- Neovim 0.11 also ships built-in defaults: grn (rename), gra (code action),
    -- grr (references), gri (implementation), gO (document symbols), K (hover),
    -- <C-s> (signature help, insert mode), ]d / [d (diagnostics).
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("Notpilif_LspAttach", { clear = true }),
        callback = function(event)
            local opts = { buffer = event.buf, remap = false }

            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
            vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
            vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
            vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
            vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
        end,
    })

    vim.diagnostic.config({
        virtual_text = true,
        float = { border = "rounded" },
    })

    -- Extend the defaults (from nvim-lspconfig) for every server with
    -- nvim-cmp capabilities.
    vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })

    vim.lsp.config("lua_ls", {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
            },
        },
    })

    -- On aarch64 mason binaries can be unavailable; use the system clangd.
    local is_aarch64 = vim.uv.os_uname().machine == "aarch64"

    local ensure_installed = { "lua_ls", "rust_analyzer" }
    if is_aarch64 then
        vim.lsp.config("clangd", {
            cmd = { "clangd", "--background-index" },
        })
        vim.lsp.enable("clangd")
    else
        table.insert(ensure_installed, "clangd")
    end

    require("mason").setup({})

    -- mason-lspconfig v2 automatically runs vim.lsp.enable() for every server
    -- installed through mason, so `:MasonInstall <server>` (or the :Mason UI)
    -- is all it takes to add a new language server -- no config changes needed.
    require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
        -- eslint was explicitly stopped in the old config; keep it disabled.
        automatic_enable = {
            exclude = { "eslint" },
        },
    })
end

local function setupCmp()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = {
            ["<CR>"] = cmp.mapping.confirm({ select = false }),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<C-f>"] = cmp.mapping(function(fallback)
                if luasnip.locally_jumpable(1) then
                    luasnip.jump(1)
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<C-b>"] = cmp.mapping(function(fallback)
                if luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        },
        sources = cmp.config.sources({
            { name = "copilot" },
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "luasnip" },
        }, {
            { name = "buffer" },
        }),
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
    })
end

return {
    { "mason-org/mason.nvim" },
    { "mason-org/mason-lspconfig.nvim" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-buffer" },
    { "L3MON4D3/LuaSnip" },
    { "saadparwaiz1/cmp_luasnip" },
    {
        "hrsh7th/nvim-cmp",
        config = setupCmp,
    },
    {
        -- Provides default configurations for servers via the lsp/ runtime dir;
        -- vim.lsp.config()/enable() build on top of these.
        "neovim/nvim-lspconfig",
        config = setupLsp,
    },
    {
        -- Proper lua_ls setup for editing your Neovim config: adds vim API
        -- types and completion for plugin sources you actually use.
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {},
    },
}
