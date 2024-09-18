local utils = require("whoami.utils")
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- Never use arrow keys :p
keymap.set({ "n", "i", "v" }, "<up>", "<nop>")
keymap.set({ "n", "i", "v" }, "<down>", "<nop>")
keymap.set({ "n", "i", "v" }, "<left>", "<nop>")
keymap.set({ "n", "i", "v" }, "<right>", "<nop>")

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<ESC>", ":nohl<CR>", { desc = "Clear search highlights" })

keymap.set("i", "<C-s>", "<ESC>:w<CR>i", { desc = "Save changes in insert mode" })

do
	keymap.set("n", "<leader>qq", "<cmd>qall!<CR>", { desc = "Quit from Neovim" })
	keymap.set("n", "<leader>qw", "<cmd>:wqall!<CR>", { desc = "Save files and quit" })
end

keymap.set("n", "<leader>p", "<cmd>Lazy<CR>", { desc = "Plugin Manager" })

keymap.set("n", "<leader>k", "<cmd>bdelete<CR>", { desc = "Kill current buffer" })

keymap.set("n", "<leader><space>", "za", { desc = "Toggle fold" })

keymap.set("n", "<leader>r", function()
	require("lualine").hide({ place = { "statusline", "tabline", "winbar" }, unhide = false })
	vim.cmd("Lazy reload lualine.nvim")
	if utils.appearance() == "dark" then
		vim.cmd("Lazy reload tokyonight.nvim")
	else
		vim.cmd("Lazy reload catppuccin")
	end
end, { desc = "Reload theme options" })

-- window management
do
	keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
	keymap.set("n", "<leader>ss", "<C-w>s", { desc = "Split window horizontally" })
	keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
	-- keymap.set('n', '<leader>sm', '<C-w>_', { desc = 'Maximize current split' }) -- Vim-Maximizer already done that
	keymap.set("n", "<leader>sk", "<C-w>-", { desc = "Decrease split hight" })
	keymap.set("n", "<leader>sj", "<C-w>+", { desc = "Increase split hight" })
	keymap.set("n", "<leader>sl", "<C-w>>", { desc = "Increase split width" })
	keymap.set("n", "<leader>sh", "<C-w><", { desc = "Decrease split width" })
	keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

	for _, key in ipairs({ "h", "j", "k", "l" }) do
		keymap.set("n", string.format("<C-%s>", key), "<C-w>" .. key, { desc = "Jump around splits" })
	end
end

-- Tab management
do
	keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
	keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
	keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
	keymap.set("n", "<TAB>", "<cmd>tabn<CR>", { desc = "Go to next tab" })
	keymap.set("n", "<S-TAB>", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
end
