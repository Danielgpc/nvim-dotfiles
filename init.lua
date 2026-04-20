-- =============================================================================
-- Modern Neovim Configuration (with enhanced LSP utilities)
-- Features:
--   • Full LSP + autocompletion (mason + lspconfig + nvim-cmp)
--   • Enhanced LSP utilities: hover, goto definition, declaration, references, etc.
--   • Linting & formatting (conform + nvim-lint)
--   • Debugging (nvim-dap)
--   • which-key.nvim with LSP group
-- =============================================================================

vim.g.mapleader = " "

-- GENERAL SETTINGS -----------------------------------------------------------
vim.opt.mouse = "a"
vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
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

-- Bootstrap vim-plug
local plug_path = config_dir .. "/autoload/plug.vim"
if vim.fn.filereadable(plug_path) == 0 then
	vim.fn.system({
		"curl",
		"-fLo",
		plug_path,
		"--create-dirs",
		"https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
	})
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			vim.cmd("PlugInstall --sync | quit")
		end,
	})
end

-- PLUGINS --------------------------------------------------------------------
vim.cmd([[
  call plug#begin('~/.config/nvim/plugged')

    " Original plugins
    Plug 'preservim/nerdtree'
    Plug 'morhetz/gruvbox'
    Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'nvim-tree/nvim-web-devicons'
    Plug 'ryanoasis/vim-devicons'
    Plug 'voldikss/vim-floaterm'
    Plug 'airblade/vim-gitgutter'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'thinca/vim-quickrun'

    " UI & Aesthetics
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'nvimdev/dashboard-nvim'
    Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
    Plug 'goolord/alpha-nvim'
    Plug 'MaximilianLloyd/ascii.nvim'

    " Modern LSP stack
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

    " Linting & Formatting
    Plug 'stevearc/conform.nvim'
    Plug 'mfussenegger/nvim-lint'

    " Debugging
    Plug 'mfussenegger/nvim-dap'
    Plug 'rcarriga/nvim-dap-ui'
    Plug 'nvim-neotest/nvim-nio'
    Plug 'jay-babu/mason-nvim-dap.nvim'

    " Which-Key
    Plug 'folke/which-key.nvim'

  call plug#end()
]])

-- SAFE REQUIRE ---------------------------------------------------------------
local function safe_require(module)
	local ok, result = pcall(require, module)
	if not ok then
		vim.notify("Failed to load " .. module .. ": " .. result, vim.log.levels.WARN)
		return nil
	end
	return result
end

-- PLUGIN SETUP ---------------------------------------------------------------
-- 1. Which-Key
local wk = safe_require("which-key")
if wk then
	wk.setup({
		plugins = { spelling = { enabled = true } },
		win = { border = "rounded" },
	})
end

-- 2. Mason
if safe_require("mason") then
	require("mason").setup()
end

local mason_lspconfig = safe_require("mason-lspconfig")
if mason_lspconfig then
	mason_lspconfig.setup({
		ensure_installed = {
			"lua_ls",
			"pyright",
			"clangd",
			"jsonls",
			"yamlls",
			"html",
			"cssls",
			"ts_ls",
			"bashls",
			"marksman",
		},
	})
end

if safe_require("mason-nvim-dap") then
	require("mason-nvim-dap").setup({
		ensure_installed = { "codelldb", "debugpy" },
		handlers = {},
	})
end

-- 3. nvim-cmp
local cmp = safe_require("cmp")
local luasnip = safe_require("luasnip")
if cmp and luasnip then
	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		mapping = cmp.mapping.preset.insert({
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
		}),
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "buffer" },
			{ name = "path" },
		}),
	})

	-- Cmdline completion (: commands) with Tab/S-Tab cycling
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline({
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { "c" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end, { "c" }),
		}),
		sources = cmp.config.sources({
			{ name = "cmdline" },
		}),
	})
end

local cmp_nvim_lsp = safe_require("cmp_nvim_lsp")
local capabilities = (cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities()) or {}

-- 4. ENHANCED LSP SETUP with rich utilities ----------------------------------
local function setup_lsp_server(server_name, opts)
	-- Use vim.lsp.config for Neovim 0.11+
	local config = vim.lsp.config[server_name]
	if config then
		for key, value in pairs(opts) do
			config[key] = value
		end
		return
	end

	-- Fallback: try using require('lspconfig') if available
	local ok, lspconfig = pcall(require, "lspconfig")
	if ok and lspconfig[server_name] then
		lspconfig[server_name].setup(opts)
		return
	end

	vim.notify("Unable to configure LSP server: " .. server_name, vim.log.levels.WARN)
end

-- === ADD THESE TWO LINES FOR LSP BORDERS ===
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
-- ===========================================

local on_attach = function(client, bufnr)
	local buf = vim.lsp.buf
	local opts = { buffer = bufnr, silent = true }

	-- === CORE LSP UTILITIES (VS Code style) ===
	vim.keymap.set("n", "gd", buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
	vim.keymap.set("n", "gD", buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))
	vim.keymap.set("n", "gi", buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))
	vim.keymap.set("n", "gr", buf.references, vim.tbl_extend("force", opts, { desc = "Find References" }))
	vim.keymap.set("n", "K", buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
	vim.keymap.set("n", "<leader>rn", buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))
	vim.keymap.set("n", "<leader>ca", buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
	vim.keymap.set(
		"n",
		"<leader>cd",
		vim.diagnostic.open_float,
		vim.tbl_extend("force", opts, { desc = "Show Diagnostics" })
	)

	-- Additional useful LSP utilities
	vim.keymap.set("n", "<leader>cl", function()
		vim.lsp.codelens.run()
	end, vim.tbl_extend("force", opts, { desc = "Run CodeLens" }))
	vim.keymap.set("n", "<leader>cf", function()
		vim.lsp.buf.format({ async = true })
	end, vim.tbl_extend("force", opts, { desc = "Format Buffer" }))

	-- Telescope-like LSP navigation (if you add telescope later)
	vim.keymap.set("n", "<leader>ls", function()
		vim.lsp.buf.workspace_symbol()
	end, vim.tbl_extend("force", opts, { desc = "Workspace Symbols" }))

	-- Diagnostic navigation
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous Diagnostic" }))
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next Diagnostic" }))
end

-- Setup all LSP servers
if lspconfig then
	local servers = {
		"lua_ls",
		"pyright",
		"clangd",
		"jsonls",
		"yamlls",
		"html",
		"cssls",
		"ts_ls",
		"bashls",
		"marksman",
	}

	for _, server_name in ipairs(servers) do
		setup_lsp_server(server_name, {
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end
end

-- 5. Conform + nvim-lint (unchanged)
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
		callback = function()
			lint.try_lint()
		end,
	})
end

-- 6. DAP (Debugging)
local dap = safe_require("dap")
local dapui = safe_require("dapui")
if dap and dapui then
	dapui.setup()
	dap.listeners.after.event_initialized["dapui_config"] = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated["dapui_config"] = function()
		dapui.close()
	end

	vim.keymap.set("n", "<F5>", function()
		dap.continue()
	end, { desc = "Debug: Continue" })
	vim.keymap.set("n", "<F10>", function()
		dap.step_over()
	end, { desc = "Debug: Step over" })
	vim.keymap.set("n", "<F11>", function()
		dap.step_into()
	end, { desc = "Debug: Step into" })
	vim.keymap.set("n", "<F12>", function()
		dap.step_out()
	end, { desc = "Debug: Step out" })
	vim.keymap.set("n", "<leader>b", function()
		dap.toggle_breakpoint()
	end, { desc = "Debug: Toggle breakpoint" })
end

-- 7. nvim-web-devicons setup
if safe_require("nvim-web-devicons") then
	require("nvim-web-devicons").setup()
end

-- 8. Indent-blankline setup
if safe_require("ibl") then
	require("ibl").setup({
		indent = { char = "▏", highlight = "IblIndent" },
		scope = { char = "▎", highlight = "IblScope" },
	})
end

-- 9. Treesitter setup
local ts_ok, ts = pcall(require, "nvim-treesitter.config")
if ts_ok then
	ts.setup({
		ensure_installed = { "c", "cpp", "lua", "python", "json", "yaml", "html", "css", "javascript", "bash", "markdown" },
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
	})
else
	vim.notify("nvim-treesitter not properly configured. Make sure nvim-treesitter is installed.", vim.log.levels.WARN)
end

-- 10. Dashboard setup
if safe_require("dashboard") then
	require("dashboard").setup({
		theme = "doom",
		config = {
			center = {
				{ action = "NERDTreeToggle", desc = " NERDTree", key = "n" },
				{ action = "Files", desc = " Find Files", key = "f" },
				{ action = "FloatermNew lazygit", desc = " Lazygit", key = "g" },
			},
		},
	})
end

-- THEME & UI ----------------------------------------------------------------
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.laststatus = 3
vim.opt.showtabline = 2

-- Catppuccin theme (active)
pcall(vim.cmd, "colorscheme catppuccin-mocha")

-- Gruvbox (kept commented for easy switching)
-- pcall(vim.cmd, "colorscheme gruvbox")

-- Fix floating window backgrounds to match the theme
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		-- Links floating windows to standard editor background
		vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
		-- Links the border background to Normal, but keeps standard border colors
		vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
	end,
})

-- Trigger it immediately for the first load
vim.cmd("doautocmd ColorScheme")

-- Lualine setup (prettier with icons and theme)
if safe_require("lualine") then
	require("lualine").setup({
		options = {
			theme = "catppuccin-mocha",
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
			globalstatus = true,
			refresh = { statusline = 1000, tabline = 1000 },
			icons_enabled = true,
			always_divide_middle = false,
		},
		sections = {
			lualine_a = {
				{ "mode", fmt = function(str) return str:sub(1, 1) end },
			},
			lualine_b = {
				{ "branch", icon = "" },
				{
					"diff",
					symbols = { added = " ", modified = "柳 ", removed = " " },
				},
			},
			lualine_c = {
				{ "filename", file_status = true, path = 1 },
				{
					"diagnostics",
					sources = { "nvim_diagnostic" },
					symbols = { error = "", warn = "", info = "", hint = "" },
				},
			},
			lualine_x = {
				{ "encoding", fmt = string.upper },
				{
					"fileformat",
					icons_enabled = true,
					symbols = { unix = "LF", dos = "CRLF", mac = "CR" },
				},
				{ "filetype", icon_only = true, padding = { left = 1, right = 0 } },
			},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		tabline = {
			lualine_a = { { "buffers", symbols = { alternate_file = "" } } },
			lualine_z = { "tabs" },
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = { "filename" },
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
	})
end

-- Alpha startup screen (lazy.nvim-style)
if safe_require("alpha") then
	local alpha = require("alpha")
	local dashboard = require("alpha.themes.dashboard")

	-- Load random ASCII art from ascii.nvim - try multiple sources
	local all_headers = {}
	
	-- Try to load from neovim.lua
	local nvim_ok, nvim_ascii = pcall(require, "ascii.text.neovim")
	if nvim_ok then
		for _, v in ipairs({ nvim_ascii.default1, nvim_ascii.default2, nvim_ascii.ogre, nvim_ascii.slant_relief, nvim_ascii.ansi_shadow }) do
			if v then table.insert(all_headers, v) end
		end
	end
	
	-- Try to load from other text files
	for _, name in ipairs({ "art", "dune", "graffiti", "isometric1", "isometric2", "isometric3", "letters", "modscript", "poison", "runic", "small", "soft", "standard" }) do
		local ok, ascii_mod = pcall(require, "ascii.text." .. name)
		if ok then
			-- Try to get common option names
			for _, opt in ipairs({ "default", "default1", "default2", "small", "big", "small_fancy", "big_fancy" }) do
				if ascii_mod[opt] then
					table.insert(all_headers, ascii_mod[opt])
				end
			end
		end
	end
	
	local header
	if #all_headers > 0 then
		header = all_headers[math.random(1, #all_headers)]
	else
		header = {
			"░█▀▀█ ░█▀▀█ ░█▀▀█ ░█▀▀█ ░█─── ░█▀▀█ ░█▀▀█ ░█▀▀█",
			"░█──█ ░█▄▄▀ ░█▄▄█ ░█▄▄█ ░█─── ░█▄▄▀ ░█▄▄█ ░█▄▄▀",
			"░█▄▄█ ░█─░█ ░█─░█ ░█─░█ ░█▄▄█ ░█─░█ ░█─░█ ░█─░█",
		}
	end

	dashboard.section.header.val = header
	dashboard.section.header.opts = { hl = "Title", position = "center" }
	dashboard.section.buttons.val = {
		dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
		dashboard.button("f", "  Find file", ":Files<CR>"),
		dashboard.button("r", "  Recent files", ":History<CR>"),		dashboard.button("i", "  Install plugins", ":PlugInstall<CR>"),		dashboard.button("u", "  Update plugins", ":PlugUpdate<CR>"),
		dashboard.button("c", "  Edit config", ":edit $MYVIMRC<CR>"),
		dashboard.button("g", "  Lazygit", ":FloatermNew lazygit<CR>"),
		dashboard.button("q", "󰈆  Quit", ":qa<CR>"),
	}
	dashboard.section.buttons.opts = { hl = "Function", position = "center", spacing = 1 }
	dashboard.section.footer.val = "catppuccin + lualine | Neovim"
	dashboard.section.footer.opts = { hl = "Comment", position = "center" }

	-- Add margins to center content vertically
	dashboard.opts.margin = 10

	alpha.setup(dashboard.opts)
end

-- NERDTree config with enhanced icons
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeHighlightFolders = 1
vim.g.NERDTreeHighlightFoldersFullName = 1
vim.g.NERDTreeFileExtensionHighlightFullName = 1
vim.g.NERDTreeExactMatchHighlightFullName = 1
vim.g.NERDTreePatternMatchHighlightFullName = 1

vim.g.NERDTreeIgnore = {
	[[\.git$]],
	[[\.jpg$]],
	[[\.png$]],
	[[\.gif$]],
	[[\.mp4$]],
	[[\.ogg$]],
	[[\.iso$]],
	[[\.pdf$]],
	[[\.pyc$]],
	[[\.odt$]],
	[[\.db$]],
}

-- MAPPINGS -------------------------------------------------------------------
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "o", "o<Esc>")
vim.keymap.set("n", "O", "O<Esc>")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "Y", "y$")

vim.keymap.set("n", "<F6>", ":w<CR>:!clear<CR>:!python3 %<CR>", { silent = true })

-- Window navigation
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
vim.keymap.set("n", "<leader>fl", "<cmd>Lines<cr>", { desc = "FZF: Lines" })
vim.keymap.set("n", "<leader>r", "<cmd>QuickRun<cr>", { desc = "QuickRun" })

-- Which-Key groups
if wk then
	wk.add({
		{ "<leader>n", group = "NERDTree" },
		{ "<leader>f", group = "FZF" },
		{ "<leader>l", group = "LSP" },
		{ "<leader>d", group = "Debug" },
		{ "<leader>c", group = "Code" },
	})
end

print("✓ Neovim config loaded with enhanced LSP utilities!")