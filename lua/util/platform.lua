-- Shared OS / CPU helpers for cross-platform config (macOS arm, Linux amd64, Rosetta, …).

local M = {}

local uname = vim.uv.os_uname()

--- Normalized CPU arch: "aarch64" | "x86_64" | other.
--- macOS reports "arm64"; Linux usually "aarch64".
M.arch = (uname.machine == "arm64") and "aarch64" or uname.machine

M.sysname = uname.sysname -- "Darwin" | "Linux" | …
M.is_mac = M.sysname == "Darwin"
M.is_linux = M.sysname == "Linux"
M.is_arm = M.arch == "aarch64"

--- Data path that won't collide when the same machine runs both arm64 and x86_64 nvim
--- (e.g. native Apple Silicon + Rosetta). Treesitter .so / Mason binaries are arch-specific.
function M.data_dir(name)
    return vim.fn.stdpath("data") .. "/" .. name .. "-" .. M.arch
end

return M
