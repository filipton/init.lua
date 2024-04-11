return {
    'nvim-telescope/telescope.nvim',
    dependencies = { { 'nvim-lua/plenary.nvim' } },
    config = function()
        require("telescope").setup({
            defaults = {
                file_ignore_patterns = { "node_modules/", ".git/", "target/" },
            }
        })

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
        vim.keymap.set('n', 'gr', builtin.lsp_references, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") });
        end)
    end
}
