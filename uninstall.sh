#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { echo "[INFO] $1"; }
warn() { echo "[WARN] $1"; }

SOURCE_TAG="WorkEnvSetup"

# ----------------------------
# 1. Remove source lines from local dotfiles
# ----------------------------
remove_source_line() {
    local config_file="$1"

    if [ ! -f "$config_file" ]; then
        return
    fi

    if grep -qF "$SOURCE_TAG" "$config_file"; then
        # Remove all lines tagged with SOURCE_TAG
        # Use || true because grep -v returns exit 1 if no lines remain
        grep -vF "$SOURCE_TAG" "$config_file" > "${config_file}.tmp" || true
        mv "${config_file}.tmp" "$config_file"
        info "Removed source lines from $config_file"
    else
        info "No source lines found in $config_file, skipping."
    fi
}

info "Removing source lines from dotfiles..."
remove_source_line "$HOME/.zshrc"
remove_source_line "$HOME/.vimrc"
remove_source_line "$HOME/.tmux.conf"

# ----------------------------
# 2. Remove CoC settings symlink
# ----------------------------
if [ -L "$HOME/.vim/coc-settings.json" ]; then
    rm "$HOME/.vim/coc-settings.json"
    info "Removed symlink: ~/.vim/coc-settings.json"
fi

# ----------------------------
# 3. Remove Vim plugins and Vundle
# ----------------------------
if [ -d "$HOME/.vim/bundle" ]; then
    rm -rf "$HOME/.vim/bundle"
    info "Removed Vim plugins: ~/.vim/bundle/"
fi

# ----------------------------
# 4. Remove tmux plugins and tpm
# ----------------------------
if [ -d "$HOME/.tmux/plugins" ]; then
    rm -rf "$HOME/.tmux/plugins"
    info "Removed tmux plugins: ~/.tmux/plugins/"
fi

# ----------------------------
# 5. Remove Oh My Zsh (includes Powerlevel10k and zsh plugins)
# ----------------------------
if [ -d "$HOME/.oh-my-zsh" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    info "Removed Oh My Zsh: ~/.oh-my-zsh/"
fi

# ----------------------------
# 6. Done
# ----------------------------
echo ""
echo "========================================="
echo "  Uninstall complete!"
echo "========================================="
echo ""
echo "Removed:"
echo "  - Source lines from ~/.zshrc, ~/.vimrc, ~/.tmux.conf"
echo "  - CoC settings symlink (~/.vim/coc-settings.json)"
echo "  - Vim plugins (~/.vim/bundle/)"
echo "  - Tmux plugins (~/.tmux/plugins/)"
echo "  - Oh My Zsh (~/.oh-my-zsh/)"
echo ""
echo "Your local dotfiles and any machine-specific customizations are preserved."
echo ""
echo "Note: System packages (zsh, vim, tmux, etc.) were NOT removed."
echo "To switch back from zsh, run: chsh -s /bin/bash"
echo ""
