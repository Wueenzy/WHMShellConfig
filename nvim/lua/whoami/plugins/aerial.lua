return {
	"stevearc/aerial.nvim",
	opts = {},
	-- Optional dependencies
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local aerial = require("aerial")
		local keymap = vim.keymap
		aerial.setup({
			on_attach = function(bufnr)
				keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
				keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
			end,
		})

		keymap.set("n", "<leader>ua", "<cmd>AerialToggle! right<CR>", { desc = "Toggle Aerial" })
	end,
}
