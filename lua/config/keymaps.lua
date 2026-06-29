-- Move between windows
vim.keymap.set("n", "<A-h>", "<C-w>h", { desc = "Move to the window on the left" })
vim.keymap.set("n", "<A-j>", "<C-w>j", { desc = "Move to the window below" })
vim.keymap.set("n", "<A-k>", "<C-w>k", { desc = "Move to the window above" })
vim.keymap.set("n", "<A-l>", "<C-w>l", { desc = "Move to the window on the right" })

-- Disable arrow keys in normal, insert, and visual modes
local keys = { "<Up>", "<Down>", "<Left>", "<Right>" }
for _, key in ipairs(keys) do
  vim.keymap.set({ "n", "i", "v" }, key, "<Nop>", { noremap = true, silent = true })
end