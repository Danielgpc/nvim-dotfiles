
# Vim/Neovim Mappings & Configuration (Updated for LSP era)

## Key Mappings (all work in Neovim)

### General
| Mapping     | Mode   | Action                          |
|-------------|--------|---------------------------------|
| `jj`        | Insert | Exit insert mode                |
| `<space>`   | Normal | Opens which-key menu            |
| `o` / `O`   | Normal | New line + exit insert          |
| `n` / `N`   | Normal | Next/prev search (centered)     |
| `Y`         | Normal | Yank to end of line             |

### Window Management
| Mapping          | Action                     |
|------------------|----------------------------|
| `<C-h/j/k/l>`    | Move between splits        |
| `<C-↑/↓/←/→>`    | Resize splits              |

### LSP (VS Code style)
| Mapping      | Action                     |
|--------------|----------------------------|
| `gd`         | Go to definition           |
| `K`          | Hover documentation        |
| `<leader>ca` | Code action                |
| `<leader>cd` | Show diagnostics           |
| `<leader>rn` | Rename                     |

### Debug
| Mapping   | Action              |
|-----------|---------------------|
| `<F5>`    | Continue            |
| `<F10>`   | Step over           |
| `<F11>`   | Step into           |
| `<leader>b` | Toggle breakpoint |

### Plugins
| Mapping     | Action                     |
|-------------|----------------------------|
| `<leader>nn`| Toggle NERDTree            |
| `<leader>ff`| FZF files                  |
| `<leader>lg`| Lazygit (floaterm)         |
| `<leader>r` | QuickRun (code runner)     |

## Plugins (updated list)

**Kept from your vimrc:**
- NERDTree, Gruvbox, vim-airline, vim-devicons, vim-floaterm, vim-gitgutter, windsuf.vim, FZF + fzf.vim, vim-quickrun

**New (removed Coc):**
- mason.nvim + mason-lspconfig + nvim-lspconfig (LSP)
- nvim-cmp + LuaSnip (completion)
- conform.nvim + nvim-lint (linting & formatting)
- nvim-dap + dap-ui + mason-nvim-dap (debugging)
- which-key.nvim

## .clangd for C/C++
Place in project root – fully replaces VS Code `c_cpp_properties.json`.

## Mouse
Fully enabled (`set mouse=a`) – click to select, drag, etc.

Everything is now 100% VS Code-like while staying in Neovim!