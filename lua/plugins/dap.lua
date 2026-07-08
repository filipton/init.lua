return {
    {
        'Civitasv/cmake-tools.nvim',
        opts = {}
    },
    {
        'mfussenegger/nvim-dap'
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "orjangj/neotest-ctest",
            "alfaix/neotest-gtest",
        },
        config = function()
            vim.keymap.set("n", "<leader>tf", function() 
                require("neotest").run.run(vim.fn.expand("%")) 
            end)
            vim.keymap.set("n", "<leader>ta", function()
                require("neotest").run.run(vim.fn.getcwd())
            end)

            require("neotest").setup({
                adapters = {
                    require("neotest-ctest").setup({}),
                    require("neotest-gtest").setup({})
                }
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
            -- dap + dapui wiring
            local dap, dapui = require("dap"), require("dapui")
            dapui.setup()

            dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end

            -- codelldb adapter
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
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

            -- keymaps
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
