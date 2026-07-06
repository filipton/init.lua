return {
    'nvim-lualine/lualine.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
    },
    opts = {
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "filename" },
            lualine_c = { "diagnostics" },
        },
    },
}
