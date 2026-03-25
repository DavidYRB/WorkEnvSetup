# WorkEnvSetup

Terminal environment setup (vim + zsh + tmux) with Nord theme. Targets macOS (Homebrew) and Ubuntu/Debian (apt).

## Architecture

- **Source pattern, not symlinks.** `install.sh` prepends a `source` line to the user's local `~/.zshrc`, `~/.vimrc`, and `~/.tmux.conf`. Repo files are never symlinked. This keeps local customizations safe and uninstall clean.
- Each file type uses its own comment syntax for the `WorkEnvSetup` tag:
  - `.zshrc` / `.tmux.conf`: `# WorkEnvSetup`
  - `.vimrc`: `" WorkEnvSetup`
- `vim/coc-settings.json` is the only symlinked file (not user-edited).

## Key conventions

- Vundle uses `Plugin` (capital P) — lowercase `plugin` silently fails.
- `install.sh` must be idempotent — every step guarded with existence checks.
- `uninstall.sh` only removes what install.sh added. System packages are never uninstalled.
- `set -e` is used in both scripts — any command that can legitimately fail needs `|| true` or `|| warn`.

## Testing

```sh
docker build -f Dockerfile.test -t workenv-test .
docker run --rm -v "$(pwd):/home/testuser/WorkEnvSetup" workenv-test bash /home/testuser/WorkEnvSetup/test.sh
```

Runs 30 checks: install verification, idempotency, uninstall cleanup.

## File structure

```
install.sh          — bootstrap script (packages, plugins, source lines)
uninstall.sh        — reversal script (remove source lines, plugins, oh-my-zsh)
vim/.vimrc          — Vundle, CoC.nvim, NERDTree, FZF, Nord
vim/coc-settings.json — CoC language server config
zsh/.zshrc          — Oh My Zsh, Powerlevel10k, FZF/bat, autosuggestions
tmux/.tmux.conf     — tpm, Nord, tmux-yank, resurrect, continuum, mouse mode
docs/dev-logs/      — session notes documenting changes and learnings
```
