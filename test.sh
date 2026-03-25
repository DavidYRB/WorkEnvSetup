#!/usr/bin/env bash
# Test script for install.sh and uninstall.sh
# Runs inside a clean Ubuntu Docker container

REPO_DIR="$HOME/WorkEnvSetup"
PASS=0
FAIL=0

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "  PASS: $description"
        ((PASS++))
    else
        echo "  FAIL: $description"
        ((FAIL++))
    fi
}

check_output() {
    local description="$1"
    local expected="$2"
    shift 2
    local output
    output="$("$@" 2>/dev/null)"
    if [[ "$output" == *"$expected"* ]]; then
        echo "  PASS: $description"
        ((PASS++))
    else
        echo "  FAIL: $description (got: '$output', expected: '$expected')"
        ((FAIL++))
    fi
}

check_not_exists() {
    local description="$1"
    local path="$2"
    if [ ! -e "$path" ]; then
        echo "  PASS: $description"
        ((PASS++))
    else
        echo "  FAIL: $description (path still exists: $path)"
        ((FAIL++))
    fi
}

echo "========================================="
echo "  Phase 1: Run install.sh"
echo "========================================="
cd "$REPO_DIR"
bash install.sh
echo ""

echo "========================================="
echo "  Phase 2: Verify Installation"
echo "========================================="

# System packages
check "zsh installed"    which zsh
check "vim installed"    which vim
check "tmux installed"   which tmux
check "git installed"    which git
check "fzf installed"    which fzf
check "bat installed"    which bat
check "fd installed"     which fd
check "node installed"   which node

# Plugin managers & plugins
check "Oh My Zsh installed"              ls "$HOME/.oh-my-zsh/"
check "Powerlevel10k installed"          ls "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/"
check "zsh-autosuggestions installed"    ls "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/"
check "zsh-syntax-highlighting installed" ls "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/"
check "Vundle installed"                 ls "$HOME/.vim/bundle/Vundle.vim/"
check "tpm installed"                    ls "$HOME/.tmux/plugins/tpm/"

# Source lines in dotfiles
check_output "source line in ~/.zshrc"      "# WorkEnvSetup" head -1 "$HOME/.zshrc"
check_output "source line in ~/.vimrc"      "# WorkEnvSetup" head -1 "$HOME/.vimrc"
check_output "source line in ~/.tmux.conf"  "# WorkEnvSetup" head -1 "$HOME/.tmux.conf"

# CoC settings symlink
check "CoC settings symlinked" test -L "$HOME/.vim/coc-settings.json"

# No duplicate source lines
check_output "no duplicate source lines in ~/.zshrc" "1" grep -c "WorkEnvSetup" "$HOME/.zshrc"

echo ""
echo "========================================="
echo "  Phase 3: Test Idempotency"
echo "========================================="
bash install.sh
echo ""

check_output "still no duplicate source lines after re-run" "1" grep -c "WorkEnvSetup" "$HOME/.zshrc"
check_output "still no duplicate source lines in ~/.vimrc" "1" grep -c "WorkEnvSetup" "$HOME/.vimrc"
check_output "still no duplicate source lines in ~/.tmux.conf" "1" grep -c "WorkEnvSetup" "$HOME/.tmux.conf"

echo ""
echo "========================================="
echo "  Phase 4: Run uninstall.sh"
echo "========================================="
bash uninstall.sh
echo ""

echo "========================================="
echo "  Phase 5: Verify Uninstall"
echo "========================================="

# Source lines removed
check "source lines removed from ~/.zshrc"     test -z "$(grep 'WorkEnvSetup' "$HOME/.zshrc" 2>/dev/null)"
check "source lines removed from ~/.vimrc"     test -z "$(grep 'WorkEnvSetup' "$HOME/.vimrc" 2>/dev/null)"
check "source lines removed from ~/.tmux.conf" test -z "$(grep 'WorkEnvSetup' "$HOME/.tmux.conf" 2>/dev/null)"

# Symlink removed
check_not_exists "CoC symlink removed"     "$HOME/.vim/coc-settings.json"

# Plugin dirs removed
check_not_exists "Vim plugins removed"     "$HOME/.vim/bundle"
check_not_exists "Tmux plugins removed"    "$HOME/.tmux/plugins"
check_not_exists "Oh My Zsh removed"       "$HOME/.oh-my-zsh"

echo ""
echo "========================================="
echo "  Results: $PASS passed, $FAIL failed"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
