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
| `gD`         | Go to declaration          |
| `gi`         | Go to implementation       |
| `gr`         | Find references            |
| `K`          | Hover documentation        |
| `<leader>ca` | Code action                |
| `<leader>cd` | Show diagnostics           |
| `<leader>cf` | Format buffer              |
| `<leader>cl` | Run CodeLens               |
| `<leader>ls` | Workspace symbols          |
| `<leader>rn` | Rename symbol              |
| `[d`         | Previous diagnostic        |
| `]d`         | Next diagnostic            |

### Debug
| Mapping     | Action              |
|-------------|---------------------|
| `<F5>`      | Continue            |
| `<F10>`     | Step over           |
| `<F11>`     | Step into           |
| `<F12>`     | Step out            |
| `<leader>b` | Toggle breakpoint   |

### Plugins
| Mapping     | Action                     |
|-------------|----------------------------|
| `<leader>nn`| Toggle NERDTree            |
| `<leader>ff`| FZF: Find files            |
| `<leader>fb`| FZF: Buffers               |
| `<leader>fr`| FZF: Ripgrep               |
| `<leader>fl`| FZF: Lines                 |
| `<leader>lg`| Lazygit (floaterm)         |
| `<leader>tn`| New tab                    |
| `<leader>r` | QuickRun (code runner)     |
| `<F6>`      | Clear & run Python (F6)    |

### Completion
| Mapping     | Mode       | Action                     |
|-------------|-----------|----------------------------|
| `<C-Space>` | Insert     | Trigger completion         |
| `<C-b>`     | Insert     | Scroll docs up             |
| `<C-f>`     | Insert     | Scroll docs down           |
| `<C-e>`     | Insert     | Abort completion           |
| `<CR>`      | Insert     | Confirm selection          |
| `<Tab>`     | Insert     | Next item / expand snippet |
| `<S-Tab>`   | Insert     | Previous item / jump back  |

## LSP Servers Configured
- lua_ls, pyright, clangd, jsonls, yamlls, html, cssls, ts_ls, bashls, marksman

## Formatters (conform.nvim)
- Lua: stylua
- Python: black
- C/C++: clang_format
- JSON/YAML/HTML/CSS/JavaScript: prettier

## Linters (nvim-lint)
- Python: pylint
- C/C++: cppcheck
- Lua: luacheck

## Debuggers (nvim-dap)
- C/C++: codelldb
- Python: debugpy

## Plugins

**Kept from your vimrc:**
- NERDTree, Gruvbox, vim-airline, vim-devicons, vim-floaterm, vim-gitgutter, FZF + fzf.vim, vim-quickrun

**New (replaced Coc with modern LSP stack):**
- mason.nvim + mason-lspconfig + nvim-lspconfig (LSP server management & setup)
- nvim-cmp + LuaSnip + cmp sources (completion engine)
- conform.nvim + nvim-lint (formatting & linting)
- nvim-dap + dap-ui + mason-nvim-dap (debugging)
- which-key.nvim (key bindings menu)

## UI & Theme Customizations
- **Theme:** Gruvbox (Dark mode)
- **Floating Windows:** Custom highlight overrides applied to `NormalFloat` and `FloatBorder` so popup menus seamlessly match the Gruvbox background instead of defaulting to unreadable colors.
- **Borders:** "Rounded" borders globally applied to Which-Key menus, LSP Hover documentation (`K`), and LSP Signature Help.

## .clangd for C/C++
Place in project root – fully replaces VS Code `c_cpp_properties.json`.

## Mouse
Fully enabled (`set mouse=a`) – click to select, drag, etc.

Everything is now 100% VS Code-like while staying in Neovim!