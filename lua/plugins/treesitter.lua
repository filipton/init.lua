local platform = require("util.platform")

-- Keep compiled parsers per architecture so Rosetta (x86_64) and native arm
-- never share the same .so files.
local parser_install_dir = platform.data_dir("treesitter")
vim.fn.mkdir(parser_install_dir .. "/parser", "p")
vim.opt.runtimepath:prepend(parser_install_dir)

local function u32le(bytes, i)
    local b1, b2, b3, b4 = bytes:byte(i, i + 3)
    return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

--- Return false when a macOS .so was built for the other CPU (Rosetta vs native).
--- Reads the Mach-O header directly — spawning `file` per parser cost ~20ms each.
local function parser_matches_arch(path)
    if not platform.is_mac then
        return true
    end
    local f = io.open(path, "rb")
    if not f then
        return true
    end
    local hdr = f:read(8)
    f:close()
    if not hdr or #hdr < 8 then
        return true
    end

    -- Only handle native-endian thin MH_MAGIC_64 (what treesitter ships).
    if u32le(hdr, 1) ~= 0xFEEDFACF then
        return true
    end

    local cputype = u32le(hdr, 5)
    -- CPU_TYPE_ARM64 = 0x0100000C, CPU_TYPE_X86_64 = 0x01000007
    if platform.arch == "aarch64" then
        return cputype == 0x0100000C
    end
    return cputype == 0x01000007
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

-- Defer so the UI isn't blocked; Mach-O check is cheap but still not needed
-- before the first draw.
vim.api.nvim_create_autocmd("UIEnter", {
    once = true,
    callback = scrub_incompatible_parsers,
})

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
