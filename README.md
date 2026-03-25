# WorkEnvSetup

One-command terminal environment setup for vim, zsh, and tmux — all themed with [Nord](https://www.nordtheme.com/).

Supports macOS (Homebrew) and Ubuntu/Debian (apt).

## What's Included

| Tool | Plugins |
|------|---------|
| **Vim** | vim-airline (status bar), CoC.nvim (LSP completion), NERDTree (file explorer), FZF (fuzzy finder), vim-polyglot (syntax), Nord theme |
| **Zsh** | Oh My Zsh, Powerlevel10k (prompt), zsh-autosuggestions, zsh-syntax-highlighting, FZF + bat integration |
| **Tmux** | tpm, tmux-sensible, tmux-yank (system clipboard), tmux-resurrect + tmux-continuum (session persistence), Nord theme |

## Quick Start

```sh
git clone https://github.com/DavidYRB/WorkEnvSetup.git
cd WorkEnvSetup
./install.sh
```

## Post-Install Steps

1. **Tmux plugins** — Open tmux and press `Ctrl+A` then `I` to install tmux plugins via tpm.

2. **iTerm2 setup (macOS)** — The install script downloads the Nord color theme and MesloLGS NF font automatically. You still need to:
   - **Activate Nord theme:** iTerm2 → Settings → Profiles → Colors → Color Presets → Nord
   - **Set font:** iTerm2 → Settings → Profiles → Text → Font → MesloLGS NF
   - **Fix Option+arrow word jumping:** iTerm2 → Settings → Profiles → Keys → Key Mappings, add:
     - `Option+Left` → Send Escape Sequence → `b`
     - `Option+Right` → Send Escape Sequence → `f`

3. **Powerlevel10k** — Run `p10k configure` to set up your prompt, then save the config to the repo:
   ```sh
   cp ~/.p10k.zsh zsh/.p10k.zsh
   git add zsh/.p10k.zsh && git commit -m "Add p10k config"
   ```

4. **Restart** your terminal or run `exec zsh`.

## Design: Source Pattern

This repo uses a **source pattern** instead of symlinking dotfiles. The install script prepends a single `source` line to your local `~/.zshrc`, `~/.vimrc`, and `~/.tmux.conf`:

```sh
# Example: what ~/.zshrc looks like after install
source /path/to/WorkEnvSetup/zsh/.zshrc  # WorkEnvSetup

# Your machine-specific config below...
export WORK_API_KEY="..."
alias proj="cd ~/work/my-project"
```

**Why this approach:**
- **Repo files stay clean** — shared config lives in the repo, local customizations stay in your local dotfiles
- **Safe to customize** — add machine-specific aliases, env vars, or overrides below the source line without dirtying the git repo
- **Clean uninstall** — `uninstall.sh` removes only the source lines, preserving all your local additions
- **No symlink fragility** — no broken symlinks if the repo moves or is deleted

## Key Shortcuts

### Vim

Leader key: `Space`

| Shortcut | Action |
|----------|--------|
| `Space f` | FZF file search |
| `Space n` | Toggle NERDTree file explorer |
| `Space j` | Go to definition (CoC.nvim) |
| `bn` | Next buffer |
| `bp` | Previous buffer |
| `ls` | List buffers |
| `Ctrl+H/J/K/L` | Navigate between splits |
| `Ctrl+S` | Horizontal split |
| `Ctrl+S v` | Vertical split |
| `Shift+H/J/K/L` | Resize splits |

### Tmux

Prefix: `Ctrl+A`

| Shortcut | Action |
|----------|--------|
| `prefix \|` | Split pane vertically |
| `prefix -` | Split pane horizontally |
| `prefix h/j/k/l` | Navigate panes |
| `prefix Arrow keys` | Resize panes |
| `prefix t` | Choose tree |
| `prefix i` | Choose client |
| `prefix K` | Kill window |
| `prefix b` | Break pane to new window |
| `prefix Escape` | Enter copy mode |
| `prefix r` | Reload tmux config |
| `prefix I` | Install tpm plugins |
| Trackpad/mouse scroll | Scroll active pane (mouse mode enabled) |
| Click on pane | Switch to that pane |

## Tips & Recipes

### Tmux

**Sessions:**
```sh
tmux new -s work          # Create a named session
tmux new -s personal      # Create another session
```
- `prefix t` — visual tree of all sessions/windows/panes, arrow keys to navigate, Enter to switch
- `prefix i` — switch between attached clients (useful when multiple terminals connect to tmux)
- `prefix d` — detach from current session (session keeps running)
- `tmux ls` — list all sessions from outside tmux
- `tmux attach -t work` — reattach to a named session

**Windows & panes:**
- `prefix c` — create a new window
- `prefix ,` — rename current window
- `prefix 1-9` — jump to window by number
- `prefix z` — zoom current pane (fullscreen toggle, press again to restore)
- `prefix {` / `prefix }` — swap pane with previous/next

**Copy mode (vi keys):**
- `prefix Escape` — enter copy mode
- `/` — search forward, `?` — search backward
- `v` — start selection, `y` — yank (copies to system clipboard via tmux-yank)
- `q` — exit copy mode

### Vim

**File navigation:**
- `Space f` — fuzzy find files (FZF), start typing to filter
- `Space n` — toggle file tree sidebar (NERDTree)
- In NERDTree: `o` open, `t` open in tab, `s` vertical split, `i` horizontal split

**Code navigation (CoC.nvim):**
- `Space j` — go to definition
- `K` — show documentation hover (in normal mode)
- `[g` / `]g` — jump to previous/next diagnostic

**Buffers:**
- `ls` — list open buffers
- `bn` / `bp` — next/previous buffer
- `:bd` — close current buffer

**Splits:**
- `Ctrl+S` — horizontal split, `Ctrl+S v` — vertical split
- `Ctrl+H/J/K/L` — move between splits
- `Shift+H/J/K/L` — resize splits
- `Shift+=` — equalize split sizes

## Testing

Run the install/uninstall scripts in a clean Ubuntu Docker container to verify everything works on a fresh machine:

```sh
docker build -f Dockerfile.test -t workenv-test .
docker run --rm -v "$(pwd):/home/testuser/WorkEnvSetup" workenv-test bash /home/testuser/WorkEnvSetup/test.sh
```

This runs 30 automated checks across 5 phases:
1. **Install** — runs `install.sh` in a clean Ubuntu 22.04 container
2. **Verify** — checks all packages, plugins, source lines, and symlinks
3. **Idempotency** — runs `install.sh` again, verifies no duplicate source lines
4. **Uninstall** — runs `uninstall.sh`
5. **Verify cleanup** — confirms all source lines, plugins, and plugin managers are removed

Requires [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.

## Uninstall

```sh
./uninstall.sh
```

Removes source lines from dotfiles, plugin managers, and Oh My Zsh. Your local dotfile customizations and system packages are preserved.
