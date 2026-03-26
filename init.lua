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

-- Leader must be set before any plugin loads keymaps
vim.g.mapleader = " "

-- GENERAL SETTINGS (ported from your vimrc) -----------------------------------
vim.opt.mouse = "a"                    -- Mouse support (click, select, drag)
vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")
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

-- Persistent undo
local config_dir = vim.fn.stdpath("config")
vim.fn.mkdir(config_dir .. "/backup", "p")
vim.opt.undodir = config_dir .. "/backup"
vim.opt.undofile = true
vim.opt.undoreload = 10000

-- Bootstrap vim-plug (auto-installs on first launch after cloning)
local plug_path = config_dir .. "/autoload/plug.vim"
if vim.fn.filereadable(plug_path) == 0 then
  vim.fn.system({
    "curl", "-fLo", plug_path, "--create-dirs",
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
  })
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.cmd("PlugInstall --sync | quit")
    end,
  })
end

-- PLUGINS (vim-plug) -----------------------------------------------------------
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
-- Safe requires with fallback
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Failed to load " .. module .. ": " .. result, vim.log.levels.WARN)
    return nil
  end
  return result
end

-- 1. which-key.nvim
local wk = safe_require("which-key")
if wk then
  wk.setup({
    plugins = { spelling = { enabled = true } },
    win = { border = "rounded" },
  })
end

-- 2. Mason (LSP installer)
if safe_require("mason") then
  require("mason").setup()
end

local mason_lspconfig = safe_require("mason-lspconfig")
if mason_lspconfig then
  mason_lspconfig.setup({
    ensure_installed = {
      "lua_ls", "pyright", "clangd", "jsonls", "yamlls",
      "html", "cssls", "ts_ls", "bashls", "marksman"
    },
  })
end

if safe_require("mason-nvim-dap") then
  require("mason-nvim-dap").setup({
    ensure_installed = { "codelldb", "debugpy" },
    handlers = {},
  })
end

-- 3. nvim-cmp (autocompletion – VS Code style)
local cmp = safe_require("cmp")
local luasnip = safe_require("luasnip")
if cmp and luasnip then
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
end

local cmp_nvim_lsp = safe_require("cmp_nvim_lsp")
local capabilities = (cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities()) or {}

-- 4. LSP config (on_attach = keybindings + diagnostics)
local lspconfig = safe_require("lspconfig")
local on_attach = function(client, bufnr)
  -- VS Code style LSP keybindings
  local buf = vim.lsp.buf
  vim.keymap.set("n", "gd", buf.definition, { buffer = bufnr, desc = "Go to definition" })
  vim.keymap.set("n", "gD", buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
  vim.keymap.set("n", "K", buf.hover, { buffer = bufnr, desc = "Hover documentation" })
  vim.keymap.set("n", "<leader>ca", buf.code_action, { buffer = bufnr, desc = "Code action" })
  vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { buffer = bufnr, desc = "Diagnostics" })
  vim.keymap.set("n", "<leader>rn", buf.rename, { buffer = bufnr, desc = "Rename" })
  vim.keymap.set("n", "gr", buf.references, { buffer = bufnr, desc = "Find references" })
end

-- Configure each LSP server directly (setup_handlers removed in newer mason-lspconfig)
if lspconfig then
  local servers = {
    "lua_ls", "pyright", "clangd", "jsonls", "yamlls",
    "html", "cssls", "ts_ls", "bashls", "marksman",
  }
  for _, server_name in ipairs(servers) do
    lspconfig[server_name].setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end
end

-- 5. Conform (formatting) + nvim-lint (linting)
local conform = safe_require("conform")
if conform then
  conform.setup({
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
end

local lint = safe_require("lint")
if lint then
  lint.linters_by_ft = {
    python = { "pylint" },
    cpp = { "cppcheck" },
    c = { "cppcheck" },
    lua = { "luacheck" },
  }
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function() lint.try_lint() end,
  })
end

-- 6. DAP (debugging)
local dap = safe_require("dap")
local dapui = safe_require("dapui")
if dap and dapui then
  dapui.setup()
  require("dap").listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  require("dap").listeners.before.event_terminated["dapui_config"] = function() dapui.close() end

  -- Debug keybindings (F5 = continue, like VS Code)
  vim.keymap.set("n", "<F5>", function() dap.continue() end, { desc = "Debug: Continue" })
  vim.keymap.set("n", "<F10>", function() dap.step_over() end, { desc = "Debug: Step over" })
  vim.keymap.set("n", "<F11>", function() dap.step_into() end, { desc = "Debug: Step into" })
  vim.keymap.set("n", "<F12>", function() dap.step_out() end, { desc = "Debug: Step out" })
  vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end, { desc = "Debug: Toggle breakpoint" })
end

-- THEME & UI -----------------------------------------------------------------
vim.opt.termguicolors = true
vim.opt.background = "dark"
-- Try to set gruvbox, fallback to default if not installed
local theme_ok, _ = pcall(vim.cmd, "colorscheme gruvbox")
if not theme_ok then
  vim.notify("Gruvbox theme not loaded yet. Run :PlugInstall", vim.log.levels.INFO)
end

-- NERDTree config (your original ignores)
vim.g.NERDTreeIgnore = {
  [[\.git$]], [[\.jpg$]], [[\.png$]], [[\.gif$]], [[\.mp4$]], [[\.ogg$]],
  [[\.iso$]], [[\.pdf$]], [[\.pyc$]], [[\.odt$]], [[\.db$]]
}

-- MAPPINGS (ported + modernized) ---------------------------------------------
-- (mapleader is set at the top of this file)

-- Your original mappings
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "o", "o<Esc>")
vim.keymap.set("n", "O", "O<Esc>")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "Y", "y$")
vim.keymap.set("n", "<F6>", ":w<CR>:!clear<CR>:!python3 %<CR>", { silent = true }) -- Python runner
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
if wk then
  wk.add({
    { "<leader>n", group = " NERDTree" },
    { "<leader>f", group = "󰈞 FZF" },
    { "<leader>l", group = "󰢹 LSP" },
    { "<leader>d", group = " Debug" },
  })
end

-- Final message
print("✓ Neovim config loaded – full VS Code-like LSP, linting, debugging & which-key ready!")