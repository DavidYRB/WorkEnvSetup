#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { echo "[INFO] $1"; }
warn() { echo "[WARN] $1"; }
error() { echo "[ERROR] $1" >&2; exit 1; }

# ----------------------------
# 1. Detect OS
# ----------------------------
OS="$(uname -s)"
case "$OS" in
    Darwin) PLATFORM="macos" ;;
    Linux)  PLATFORM="linux" ;;
    *)      error "Unsupported OS: $OS" ;;
esac
info "Detected platform: $PLATFORM"

# ----------------------------
# 2. Install system packages
# ----------------------------
info "Installing system packages..."
if [ "$PLATFORM" = "macos" ]; then
    if ! command -v brew &>/dev/null; then
        error "Homebrew is required on macOS. Install it from https://brew.sh"
    fi
    brew install zsh vim tmux git fzf bat fd node || true
elif [ "$PLATFORM" = "linux" ]; then
    sudo apt update
    sudo apt install -y zsh vim tmux git fzf bat fd-find nodejs npm curl
    # On Debian/Ubuntu, bat is installed as 'batcat' and fd as 'fdfind'
    if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
        sudo ln -sf "$(which batcat)" /usr/local/bin/bat
    fi
    if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi
fi

# ----------------------------
# 3. Install MesloLGS NF font (required by Powerlevel10k)
# ----------------------------
if [ "$PLATFORM" = "macos" ]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
fi
mkdir -p "$FONT_DIR"

MESLO_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"
FONTS=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
)
for font in "${FONTS[@]}"; do
    if [ ! -f "$FONT_DIR/$font" ]; then
        info "Downloading $font..."
        curl -fsSL -o "$FONT_DIR/$font" "$MESLO_BASE/${font// /%20}"
    fi
done
info "MesloLGS NF fonts installed."
if [ "$PLATFORM" = "linux" ]; then
    fc-cache -f "$FONT_DIR" 2>/dev/null || true
fi

# ----------------------------
# 4. Install Nord iTerm2 color theme (macOS only)
# ----------------------------
if [ "$PLATFORM" = "macos" ]; then
    ITERM_THEME="/tmp/Nord.itermcolors"
    if [ ! -f "$ITERM_THEME" ]; then
        info "Downloading Nord iTerm2 theme..."
        curl -fsSL -o "$ITERM_THEME" "https://raw.githubusercontent.com/nordtheme/iterm2/develop/src/xml/Nord.itermcolors"
    fi
    info "Importing Nord theme into iTerm2..."
    open "$ITERM_THEME" 2>/dev/null || true
    info "Nord theme imported. To activate: iTerm2 → Preferences → Profiles → Colors → Color Presets → Nord"
fi

# ----------------------------
# 5. Install Oh My Zsh
# ----------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    info "Oh My Zsh already installed, skipping."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ----------------------------
# 6. Install Powerlevel10k
# ----------------------------
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    info "Powerlevel10k already installed, skipping."
fi

# ----------------------------
# 7. Install Zsh plugins
# ----------------------------
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    info "zsh-autosuggestions already installed, skipping."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    info "zsh-syntax-highlighting already installed, skipping."
fi

# ----------------------------
# 8. Install Vundle
# ----------------------------
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    info "Installing Vundle..."
    git clone https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
else
    info "Vundle already installed, skipping."
fi

# ----------------------------
# 9. Install tpm (Tmux Plugin Manager)
# ----------------------------
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing tpm..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    info "tpm already installed, skipping."
fi

# ----------------------------
# 10. Source repo configs from local dotfiles
# ----------------------------
# Instead of symlinking, we add a 'source' line to the local dotfile.
# This lets you add machine-specific customizations in ~/.zshrc, ~/.vimrc,
# ~/.tmux.conf without modifying the repo files. Uninstall only removes the
# source line, preserving your local additions.

SOURCE_TAG="WorkEnvSetup"

add_source_line() {
    local config_file="$1"
    local source_line="$2"

    if [ -f "$config_file" ] && grep -qF "$SOURCE_TAG" "$config_file"; then
        info "Source line already present in $config_file, skipping."
        return
    fi

    # Prepend the source line so repo config loads first, local overrides go below
    if [ -f "$config_file" ]; then
        local tmp
        tmp="$(mktemp)"
        echo "$source_line" > "$tmp"
        echo "" >> "$tmp"
        cat "$config_file" >> "$tmp"
        mv "$tmp" "$config_file"
    else
        echo "$source_line" > "$config_file"
    fi

    info "Added source line to $config_file"
}

info "Setting up dotfiles with source pattern..."
# Each file type uses its own comment syntax for the tag
add_source_line "$HOME/.zshrc"      "source $SCRIPT_DIR/zsh/.zshrc # $SOURCE_TAG"
add_source_line "$HOME/.vimrc"      "source $SCRIPT_DIR/vim/.vimrc \" $SOURCE_TAG"
add_source_line "$HOME/.tmux.conf"  "source-file $SCRIPT_DIR/tmux/.tmux.conf # $SOURCE_TAG"

# Source .p10k.zsh only if it exists in the repo
if [ -f "$SCRIPT_DIR/zsh/.p10k.zsh" ]; then
    add_source_line "$HOME/.zshrc" "source $SCRIPT_DIR/zsh/.p10k.zsh # $SOURCE_TAG"
else
    info "No zsh/.p10k.zsh found — run 'p10k configure' after install to generate it."
fi

# Symlink CoC settings (not user-edited, so symlink is fine)
mkdir -p "$HOME/.vim"
if [ -L "$HOME/.vim/coc-settings.json" ]; then
    rm "$HOME/.vim/coc-settings.json"
fi
ln -sf "$SCRIPT_DIR/vim/coc-settings.json" "$HOME/.vim/coc-settings.json"
info "Linked ~/.vim/coc-settings.json"

# ----------------------------
# 11. Install Vim plugins (headless)
# ----------------------------
info "Installing Vim plugins via Vundle (this may take a few minutes)..."
vim +PluginInstall +qall || warn "Vim plugin install had warnings (this is normal on first run)"

# ----------------------------
# 12. Build CoC.nvim
# ----------------------------
COC_DIR="$HOME/.vim/bundle/coc.nvim"
if [ -d "$COC_DIR" ] && [ ! -f "$COC_DIR/build/index.js" ]; then
    info "Building CoC.nvim..."
    cd "$COC_DIR" && npm ci
    cd "$SCRIPT_DIR"
else
    info "CoC.nvim already built, skipping."
fi

# ----------------------------
# 13. Install CoC.nvim extensions
# ----------------------------
info "Installing CoC.nvim language server extensions..."
vim -c 'CocInstall -sync coc-pyright coc-clangd coc-json coc-yaml|q' || warn "CoC extension install had warnings (run :CocInstall manually if needed)"

# ----------------------------
# 14. Set zsh as default shell
# ----------------------------
CURRENT_SHELL="$(basename "$SHELL")"
if [ "$CURRENT_SHELL" != "zsh" ]; then
    info "Setting zsh as default shell..."
    ZSH_PATH="$(which zsh)"
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        info "Adding $ZSH_PATH to /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$ZSH_PATH" || warn "Could not change default shell. Run manually: chsh -s $ZSH_PATH"
else
    info "zsh is already the default shell."
fi

# ----------------------------
# 15. Done — print next steps
# ----------------------------
echo ""
echo "========================================="
echo "  Installation complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "  1. Tmux plugins:"
echo "     Open tmux and press prefix+I (Ctrl+A then I) to install tmux plugins."
echo ""
echo "  2. iTerm2 Nord theme (macOS):"
echo "     iTerm2 → Preferences → Profiles → Colors → Color Presets → Nord"
echo ""
echo "  3. Powerlevel10k:"
echo "     Run 'p10k configure' to set up your prompt theme."
echo "     Then copy the generated config into this repo:"
echo "       cp ~/.p10k.zsh $SCRIPT_DIR/zsh/.p10k.zsh"
echo "     And commit it so it's available on your next machine."
echo ""
echo "  4. Restart your terminal or run: exec zsh"
echo ""
