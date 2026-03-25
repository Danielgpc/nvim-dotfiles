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

## Installation (one command)

```bash
git clone https://github.com/Danielgpc/nvim-dotfiles.git ~/.nvim-dotfiles
cd ~/.nvim-dotfiles
chmod +x install.sh
./install.sh