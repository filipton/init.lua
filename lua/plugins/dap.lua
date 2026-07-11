return {
    {
        "Civitasv/cmake-tools.nvim",
        opts = {},
    },
    {
        "mfussenegger/nvim-dap",
    },
    {
        "nvim-neotest/neotest",
        -- Don't load at startup: neotest-gtest parses a cpp treesitter query on
        -- require(), which used to abort the whole config if the parser was wrong-arch.
        cmd = { "Neotest" },
        keys = {
            {
                "<leader>tf",
                function()
                    require("neotest").run.run(vim.fn.expand("%"))
                end,
                desc = "Neotest: run file",
            },
            {
                "<leader>ta",
                function()
                    require("neotest").run.run(vim.fn.getcwd())
                end,
                desc = "Neotest: run cwd",
            },
        },
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "orjangj/neotest-ctest",
            "alfaix/neotest-gtest",
        },
        config = function()
            local adapters = {}

            local ok_ctest, ctest = pcall(require, "neotest-ctest")
            if ok_ctest then
                table.insert(adapters, ctest.setup({}))
            else
                vim.notify("neotest-ctest failed to load: " .. tostring(ctest), vim.log.levels.WARN)
            end

            local ok_gtest, gtest = pcall(require, "neotest-gtest")
            if ok_gtest then
                table.insert(adapters, gtest.setup({}))
            else
                vim.notify(
                    "neotest-gtest failed to load (need a working cpp treesitter parser): " .. tostring(gtest),
                    vim.log.levels.WARN
                )
            end

            require("neotest").setup({
                adapters = adapters,
            })
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
            "Civitasv/cmake-tools.nvim",
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            local platform = require("util.platform")
            dapui.setup()

            dap.listeners.after.event_initialized["dapui"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui"] = function()
                dapui.close()
            end

            -- Mason packages are installed under an arch-specific root (see lsp.lua).
            local codelldb = platform.data_dir("mason") .. "/bin/codelldb"
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = codelldb,
                    args = { "--port", "${port}" },
                },
            }
            dap.configurations.cpp = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to binary: ", vim.fn.getcwd() .. "/build/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
            }

            vim.keymap.set("n", "<F5>", dap.continue)
            vim.keymap.set("n", "<F10>", dap.step_over)
            vim.keymap.set("n", "<F11>", dap.step_into)
            vim.keymap.set("n", "<F12>", dap.step_out)
            vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
            vim.keymap.set("n", "<leader>dx", dap.terminate)
            vim.keymap.set("n", "<leader>du", dapui.toggle)
        end,
    },
}
