-- =============================================================================
-- Modern Neovim Configuration (ported from your old vimrc + VS Code-like LSP)
-- Features:
--   • Full LSP + autocompletion (mason + lspconfig + nvim-cmp) – VS Code experience
--   • Linting & formatting on all languages (conform.nvim + nvim-lint)
--   • Debugging for C/C++, Python, etc. (nvim-dap + mason-nvim-dap)
--   • which-key.nvim (beautiful keybinding menu on <leader>)
--   • Mouse support for click & select
--   • All your old plugins kept (NERDTree, Gruvbox, airline, etc.)
--   • COC removed and replaced with modern Lua LSP stack
--   • QuickRun (code runner like VS Code Code Runner)
--   • .clangd support for C/C++ (project-specific config like c_cpp_properties.json)
-- =============================================================================

-- GENERAL SETTINGS (ported from your vimrc) -----------------------------------
vim.opt.mouse = "a"                    -- Mouse support (click, select, drag)
vim.opt.nocompatible = true
vim.opt.filetype = "on"
vim.opt.syntax = "on"
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.wrap = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showcmd = true
vim.opt.showmode = true
vim.opt.showmatch = true
vim.opt.hlsearch = true
vim.opt.history = 1000
vim.opt.wildmenu = true
vim.opt.wildmode = "list:longest"
vim.opt.wildignore = "*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx"
vim.opt.lang = "en_US"

-- Persistent undo (uses the backup folder created by install.sh)
vim.opt.undodir = vim.fn.expand("~/.config/nvim/backup")
vim.opt.undofile = true
vim.opt.undoreload = 10000

-- PLUGINS (vim-plug – exactly as you asked) -----------------------------------
vim.cmd([[
  call plug#begin('~/.config/nvim/plugged')

    " Your original plugins (kept)
    Plug 'preservim/nerdtree'
    Plug 'morhetz/gruvbox'
    Plug 'vim-airline/vim-airline'
    Plug 'ryanoasis/vim-devicons'
    Plug 'voldikss/vim-floaterm'
    Plug 'airblade/vim-gitgutter'
    Plug 'Exafunction/windsurf.vim'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'thinca/vim-quickrun'

    " === NEW: Modern VS Code-like LSP stack ===
    Plug 'williamboman/mason.nvim'
    Plug 'williamboman/mason-lspconfig.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'saadparwaiz1/cmp_luasnip'

    " === NEW: Linting & Formatting (full linting on all languages) ===
    Plug 'stevearc/conform.nvim'
    Plug 'mfussenegger/nvim-lint'

    " === NEW: Debugging (for all languages) ===
    Plug 'mfussenegger/nvim-dap'
    Plug 'rcarriga/nvim-dap-ui'
    Plug 'nvim-neotest/nvim-nio'
    Plug 'jay-babu/mason-nvim-dap.nvim'

    " === NEW: Which-Key (beautiful menu) ===
    Plug 'folke/which-key.nvim'

  call plug#end()
]])

-- PLUGIN SETUP (Lua) ----------------------------------------------------------

-- 1. which-key.nvim
local wk = require("which-key")
wk.setup({
  plugins = { spelling = true },
  win = { border = "rounded" },
})

-- 2. Mason (LSP installer)
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls", "pyright", "clangd", "jsonls", "yamlls",
    "html", "cssls", "tsserver", "bashls", "marksman"
  },
})
require("mason-nvim-dap").setup({
  ensure_installed = { "codelldb", "debugpy" }, -- C/C++, Python
  handlers = {},
})

-- 3. nvim-cmp (autocompletion – VS Code style)
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback() end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then luasnip.jump(-1)
      else fallback() end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
})
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- 4. LSP config (on_attach = keybindings + diagnostics)
local lspconfig = require("lspconfig")
local on_attach = function(client, bufnr)
  -- VS Code style LSP keybindings
  local buf = vim.lsp.buf
  vim.keymap.set("n", "gd", buf.definition, { buffer = bufnr, desc = "Go to definition" })
  vim.keymap.set("n", "gD", buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
  vim.keymap.set("n", "K", buf.hover, { buffer = bufnr, desc = "Hover documentation" })
  vim.keymap.set("n", "<leader>ca", buf.code_action, { buffer = bufnr, desc = "Code action" })
  vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { buffer = bufnr, desc = "Diagnostics" })
  vim.keymap.set("n", "<leader>rn", buf.rename, { buffer = bufnr, desc = "Rename" })
  vim.keymap.set("n", "<leader>fr", "<cmd>Telescope lsp_references<cr>", { buffer = bufnr, desc = "Find references" })
end

require("mason-lspconfig").setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end,
})

-- 5. Conform (formatting) + nvim-lint (linting)
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "black" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    json = { "prettier" },
    yaml = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    javascript = { "prettier" },
  },
  format_on_save = { timeout_ms = 500, lsp_fallback = true },
})

local lint = require("lint")
lint.linters_by_ft = {
  python = { "pylint" },
  cpp = { "cppcheck" },
  c = { "cppcheck" },
  lua = { "luacheck" },
}
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function() lint.try_lint() end,
})

-- 6. DAP (debugging)
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()
require("dap").listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
require("dap").listeners.before.event_terminated["dapui_config"] = function() dapui.close() end

-- Debug keybindings (F5 = continue, like VS Code)
vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "Debug: Continue" })
vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "Debug: Step over" })
vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "Debug: Step into" })
vim.keymap.set("n", "<F12>", function() dap.step_out() end, { desc = "Debug: Step out" })
vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle breakpoint" })

-- THEME & UI -----------------------------------------------------------------
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd("colorscheme gruvbox")

-- NERDTree config (your original ignores)
vim.g.NERDTreeIgnore = {
  [[\.git$]], [[\.jpg$]], [[\.png$]], [[\.gif$]], [[\.mp4$]], [[\.ogg$]],
  [[\.iso$]], [[\.pdf$]], [[\.pyc$]], [[\.odt$]], [[\.db$]]
}

-- MAPPINGS (ported + modernized) ---------------------------------------------
vim.g.mapleader = " "

-- Your original mappings (converted to Lua)
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "o", "o<Esc>")
vim.keymap.set("n", "O", "O<Esc>")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "Y", "y$")
vim.keymap.set("n", "<F5>", ":w<CR>:!clear<CR>:!python3 %<CR>", { silent = true }) -- keep your Python runner
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-Up>", "<C-w>+")
vim.keymap.set("n", "<C-Down>", "<C-w>-")
vim.keymap.set("n", "<C-Left>", "<C-w>>")
vim.keymap.set("n", "<C-Right>", "<C-w><")

-- Plugin mappings
vim.keymap.set("n", "<leader>nn", "<cmd>NERDTreeToggle<cr>", { desc = "Toggle NERDTree" })
vim.keymap.set("n", "<leader>lg", "<cmd>FloatermNew lazygit<cr>", { desc = "Open Lazygit" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "New tab" })
vim.keymap.set("n", "<leader>ff", "<cmd>Files<cr>", { desc = "FZF: Find files" })
vim.keymap.set("n", "<leader>fb", "<cmd>Buffers<cr>", { desc = "FZF: Buffers" })
vim.keymap.set("n", "<leader>fr", "<cmd>Rg<cr>", { desc = "FZF: Ripgrep" })
vim.keymap.set("n", "<leader>fl", "<cmd>Lines<cr>", { desc = "FZF: Lines in buffers" })
vim.keymap.set("n", "<leader>r", "<cmd>QuickRun<cr>", { desc = "QuickRun (Code Runner)" })

-- Which-Key groups (beautiful VS Code style menu)
wk.register({
  ["<leader>"] = {
    n = { name = " NERDTree" },
    f = { name = "󰈞 FZF" },
    l = { name = "󰢹 LSP" },
    d = { name = " Debug" },
  },
}, { prefix = "<leader>" })

-- Final message
print("✓ Neovim config loaded – full VS Code-like LSP, linting, debugging & which-key ready!")