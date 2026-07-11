local platform = require("util.platform")

-- Keep compiled parsers per architecture so Rosetta (x86_64) and native arm
-- never share the same .so files.
local parser_install_dir = platform.data_dir("treesitter")
vim.fn.mkdir(parser_install_dir .. "/parser", "p")
vim.opt.runtimepath:prepend(parser_install_dir)

--- Return false when a macOS .so was built for the other CPU (Rosetta vs native).
local function parser_matches_arch(path)
    if not platform.is_mac then
        return true
    end
    local info = vim.fn.system({ "file", "-b", path })
    if vim.v.shell_error ~= 0 then
        return true
    end
    if platform.arch == "aarch64" then
        return info:find("arm64", 1, true) ~= nil
    end
    return info:find("x86_64", 1, true) ~= nil
end

--- Drop wrong-arch parsers from known install locations so rtp never picks them up.
local function scrub_incompatible_parsers()
    local dirs = {
        vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser",
        parser_install_dir .. "/parser",
    }
    local removed = {}
    for _, dir in ipairs(dirs) do
        local handle = vim.uv.fs_scandir(dir)
        if handle then
            while true do
                local name = vim.uv.fs_scandir_next(handle)
                if not name then
                    break
                end
                if name:match("%.so$") then
                    local path = dir .. "/" .. name
                    if not parser_matches_arch(path) then
                        vim.fn.delete(path)
                        table.insert(removed, (name:gsub("%.so$", "")))
                    end
                end
            end
        end
    end
    if #removed > 0 then
        vim.notify(
            "Removed wrong-arch treesitter parsers (" .. platform.arch .. "): " .. table.concat(removed, ", "),
            vim.log.levels.WARN
        )
    end
end

scrub_incompatible_parsers()

return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                parser_install_dir = parser_install_dir,

                -- cpp is required by neotest-gtest at require()-time.
                ensure_installed = {
                    "vimdoc",
                    "javascript",
                    "typescript",
                    "c",
                    "cpp",
                    "lua",
                    "rust",
                    "c_sharp",
                    "dockerfile",
                },

                sync_install = false,
                auto_install = true,

                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
    },
}
