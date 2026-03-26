# My Neovim Configuration (VS Code-like)

Modern Neovim setup with **full LSP, linting, formatting, and debugging** – exactly like VS Code.

## Features

- **Editor**: Neovim
- **Plugin Manager**: vim-plug (as you requested – no Lazy)
- **LSP & Completion**: mason.nvim + nvim-lspconfig + nvim-cmp (full VS Code experience)
- **Linting & Formatting**: conform.nvim + nvim-lint (works on **all languages**)
- **Debugging**: nvim-dap + mason-nvim-dap (C/C++, Python, etc.)
- **Color Scheme**: Gruvbox
- **File Browser**: NERDTree
- **Fuzzy Finder**: FZF
- **Keybinding Guide**: which-key.nvim
- **UI**: vim-airline + vim-devicons
- **Git**: vim-gitgutter
- **Terminal**: vim-floaterm
- **AI Assistant**: Windsurf
- **Quick Run**: vim-quickrun (like VS Code Code Runner)
- **Mouse support**: Click, select, drag everywhere

### C / C++ Support
Create a `.clangd` file in your project root – works exactly like VS Code’s `c_cpp_properties.json`.

## Installation

```bash
# Back up any existing config first (if needed)
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true

# Clone directly into Neovim's config directory
git clone https://github.com/Danielgpc/nvim-dotfiles.git ~/.config/nvim

# Open Neovim – vim-plug and all plugins will auto-install
nvim
