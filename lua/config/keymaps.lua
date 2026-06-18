-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Mover para a janela da esquerda
vim.keymap.set("n", "<A-h>", "<C-w>h", { desc = "Move to the window on the left" })

-- Mover para a janela de baixo
vim.keymap.set("n", "<A-j>", "<C-w>j", { desc = "Move to the window below" })

-- Mover para a janela de cima
vim.keymap.set("n", "<A-k>", "<C-w>k", { desc = "Move to the window above" })

-- Mover para a janela da direita
vim.keymap.set("n", "<A-l>", "<C-w>l", { desc = "Move to the window on the right" })

-- Disable arrow keys in normal, insert, and visual modes
local keys = { "<Up>", "<Down>", "<Left>", "<Right>" }
for _, key in ipairs(keys) do
  vim.keymap.set({ "n", "i", "v" }, key, "<Nop>", { noremap = true, silent = true })
end
