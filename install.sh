#!/bin/bash

#############################################
# Neovim Configuration Installation Script
# (Updated for modern LSP stack + vim-plug)
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Neovim Configuration Installation${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Function to print info messages
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Function to print warning messages
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Function to print error messages
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
    info "Detected macOS"
else
    OS="linux"
    info "Detected Linux"
fi

# Step 1: Check/Install Neovim
info "Checking Neovim installation..."
if ! command -v nvim &> /dev/null; then
    warn "Neovim not found. Installing Neovim..."
    if [[ "$OS" == "mac" ]]; then
        if ! command -v brew &> /dev/null; then
            error "Homebrew not found. Please install Homebrew first."
            exit 1
        fi
        brew install neovim
    else
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y neovim
        elif command -v yum &> /dev/null; then
            sudo yum install -y neovim
        else
            error "Package manager not found. Please install Neovim manually."
            exit 1
        fi
    fi
    info "Neovim installed successfully"
else
    info "Neovim is already installed: $(nvim --version | head -n1)"
fi

# Step 2: Create necessary directories
info "Creating necessary directories..."
mkdir -p ~/.config/nvim
mkdir -p ~/.config/nvim/plugged
mkdir -p ~/.config/nvim/backup

# Step 3: Install vim-plug (plugin manager)
info "Installing vim-plug..."
VIM_PLUG_PATH="~/.config/nvim/autoload/plug.vim"
if [ ! -f "${VIM_PLUG_PATH/\~/$HOME}" ]; then
    curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    info "vim-plug installed successfully"
else
    info "vim-plug already installed"
fi

# Step 4: Backup existing init.lua if it exists
if [ -f ~/.config/nvim/init.lua ]; then
    warn "Existing init.lua found. Backing up to init.lua.backup"
    cp ~/.config/nvim/init.lua ~/.config/nvim/init.lua.backup
fi

# Step 5: Copy or create init.lua
if [ -f "$(dirname "$0")/init.lua" ]; then
    info "Copying init.lua from script directory..."
    cp "$(dirname "$0")/init.lua" ~/.config/nvim/init.lua
elif [ -f "./init.lua" ]; then
    info "Copying init.lua from current directory..."
    cp ./init.lua ~/.config/nvim/init.lua
else
    warn "No init.lua found to copy. Using existing ~/.config/nvim/init.lua"
fi

# Step 6: Install Neovim plugins
info "Installing Neovim plugins..."
nvim +PlugInstall +qall 2>/dev/null || true

# Step 7: Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

info "Your Neovim configuration has been set up with:"
echo "  • Full VS Code-like LSP (mason + nvim-cmp)"
echo "  • Linting & formatting on ALL languages"
echo "  • Debugging (C/C++, Python, etc.)"
echo "  • which-key.nvim (keybinding menu)"
echo "  • NERDTree, Gruvbox, FZF, QuickRun, Floaterm, etc."
echo ""
info "Configuration backed up to: ~/.config/nvim/init.lua.backup"
info "Plugins installed in: ~/.config/nvim/plugged/"
info "Undo history stored in: ~/.config/nvim/backup/"
echo ""
info "Next steps:"
echo "  1. Open Neovim – LSP servers will auto-install"
echo "  2. Run :Mason to see installed tools"
echo "  3. For C/C++ projects: create a .clangd file in project root (example below)"
echo ""
info "Key bindings (press <space> for which-key menu):"
echo "  • <leader>nn    - Toggle NERDTree"
echo "  • <leader>ff    - Find files with FZF"
echo "  • <leader>fb    - Search buffers with FZF"
echo "  • <leader>fr    - Search with ripgrep"
echo "  • <leader>fl    - Search lines in loaded buffers"
echo "  • <leader>lg    - Open Lazygit"
echo "  • <F5>          - Debug: Continue / Run Python"
echo "  • <leader>ca    - LSP Code Action"
echo "  • <leader>cd    - Show diagnostics"
echo ""
info "Happy coding!"
echo ""