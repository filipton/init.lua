local function setupColors()
    vim.cmd.colorscheme("moonfly")

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    priority = 1000,
    config = setupColors
}
