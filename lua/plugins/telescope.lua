return {
    "nvim-telescope/telescope.nvim",
    dependencies = { { "nvim-lua/plenary.nvim" } },
    cmd = "Telescope",
    keys = {
        {
            "<leader>pf",
            function()
                require("telescope.builtin").find_files()
            end,
            desc = "Telescope find files",
        },
        {
            "gd",
            function()
                require("telescope.builtin").lsp_definitions()
            end,
            desc = "Telescope LSP definitions",
        },
        {
            "gr",
            function()
                require("telescope.builtin").lsp_references()
            end,
            desc = "Telescope LSP references",
        },
        {
            "<C-p>",
            function()
                require("telescope.builtin").git_files()
            end,
            desc = "Telescope git files",
        },
        {
            "<leader>ps",
            function()
                require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
            end,
            desc = "Telescope grep string",
        },
    },
    config = function()
        require("telescope").setup({
            defaults = {
                file_ignore_patterns = { "node_modules/", ".git/", "target/" },
            },
        })
    end,
}
