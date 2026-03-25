# Install Scripts, Plugin Upgrade, and Full Documentation

**Date:** 2026-03-25
**Repo:** WorkEnvSetup
**Tool:** Claude Code

---

## What Changed

Took a repo with three bare dotfiles (`.vimrc`, `.zshrc`, `.tmux.conf`) and turned it into a one-command terminal setup for any new macOS or Ubuntu machine. Added install/uninstall automation, upgraded plugins, fixed cross-platform issues, and wrote comprehensive documentation.

**Files changed:** 10 (4 modified, 6 new)
**New files:** `install.sh`, `uninstall.sh`, `.gitignore`, `vim/coc-settings.json`, `Dockerfile.test`, `test.sh`

## Key Decisions

| Decision | Why |
|----------|-----|
| CoC.nvim over YouCompleteMe | LSP-based, lighter install, no compilation step on each machine |
| NERDTree + FZF together | FZF for speed when you know the filename, NERDTree for exploring unfamiliar codebases |
| tmux-yank | System clipboard integration, especially useful over SSH |
| tmux-resurrect + continuum | Session persistence across reboots |
| Source pattern over symlinks | Symlinks mean local changes dirty the repo and uninstall wipes post-install customizations. Source pattern only adds/removes one line. |
| No backup files needed | Source pattern only adds/removes one line, so nothing gets overwritten |
| Don't uninstall system packages | Other tools may depend on zsh, vim, tmux, etc. |
| Keep `.p10k.zsh` for later | Generate via interactive `p10k configure`, then commit — can't be automated |
| Docker testing for install script | Clean-slate Ubuntu container simulates the actual "fresh machine" use case |

## Failures & Lessons Learned

### 1. Vundle command is `Plugin` (capital P), not `plugin`
- **What happened:** The original `.vimrc` had lowercase `plugin` which silently did nothing. Vim hung on `+PluginInstall` because no plugins were registered.
- **Root cause:** Vundle requires `Plugin` (capital P) as the command name. Lowercase is not a recognized editor command.
- **Fix:** Changed all `plugin '...'` to `Plugin '...'` in `.vimrc`.
- **Lesson:** When something hangs, run it interactively to see errors. The `2>/dev/null` in the install script hid the real problem.

### 2. `#` has special meaning in vim
- **What happened:** The source tag `# WorkEnvSetup` appended to the `.vimrc` source line caused `E194: No alternate file name to substitute for '#'`.
- **Root cause:** In vim, `#` refers to the alternate file buffer. It's not a comment character — vim uses `"` for comments.
- **Fix:** Use vim's comment syntax (`"`) for `.vimrc`, `#` for `.zshrc` and `.tmux.conf`.
- **Lesson:** Each config file has its own comment syntax. A universal tag format doesn't work.

### 3. CoC.nvim needs `npm ci` after clone
- **What happened:** Vim showed `build/index.js not found, please install dependencies and compile coc.nvim`.
- **Root cause:** Vundle only clones repos. CoC.nvim's release branch requires an explicit npm build step.
- **Fix:** Added `cd ~/.vim/bundle/coc.nvim && npm ci` step in install.sh after Vundle plugin install.
- **Lesson:** Plugin managers don't always handle post-install build steps. Check if plugins need extra setup.

### 4. `grep -v` exits with code 1 when no lines remain
- **What happened:** Uninstall script silently stopped after processing `~/.zshrc`, never cleaned `~/.vimrc` or `~/.tmux.conf`.
- **Root cause:** `grep -vF` returns exit code 1 when no lines match (i.e., file only contained the source line). Combined with `set -e`, this killed the script.
- **Fix:** `grep -vF ... || true`.
- **Lesson:** `set -e` is a double-edged sword. Every command that can legitimately return non-zero needs a `|| true` guard.

### 5. `chsh` fails in Docker (no PAM auth)
- **What happened:** Install script aborted at the `chsh` step in Docker container.
- **Root cause:** Docker containers don't have PAM authentication configured. `chsh` requires password auth.
- **Fix:** `chsh ... || warn "run manually"` — made it non-fatal.
- **Lesson:** Test in the actual target environment. Docker containers lack things real machines have.

### 6. iTerm2 Option key defaults to compose key
- **What happened:** Option+arrow sent raw `A/B/C/D` characters instead of word-jump sequences, both inside and outside tmux.
- **Root cause:** iTerm2 defaults Option to "Normal" (macOS compose key for special characters), not "Esc+" (terminal escape sequences).
- **Fix:** iTerm2 → Profiles → Keys → Key Mappings: Option+Left → Esc `b`, Option+Right → Esc `f`.
- **Lesson:** Terminal emulator settings are part of the dev environment setup. Document them in README so they aren't forgotten on the next machine.

### 7. `2>/dev/null` hides real errors
- **What happened:** Vim plugin install appeared to hang forever. No output visible.
- **Root cause:** Vim was hitting an error prompt but stderr was suppressed by `2>/dev/null` in the install script.
- **Fix:** Removed `2>/dev/null` from vim commands so progress and errors are visible.
- **Lesson:** Don't suppress stderr in install scripts. Visibility matters more than clean output.

## Claude Code Usage

### What worked well

1. **Started with exploration before coding** — Used Explore agent and `/plan` mode to understand the full repo before writing anything. Caught hardcoded paths, duplicate bindings, and missing plugins early.

2. **Asked clarifying questions before implementation** — Instead of assuming workflow, Claude asked about languages, target platforms, and plugin preferences. Led to better choices (CoC.nvim over YCM, NERDTree addition, macOS + Debian targeting).

3. **Challenged assumptions and pushed back** — Questioned whether `.gitignore` and `.p10k.zsh` were necessary. Caught the symlink problem ("what if I customize `.zshrc` after install?") which led to the better source pattern. Questioned whether backup files were needed (they weren't).

4. **Used plan mode for design, tasks for tracking** — `/plan` kept design discussions separate from implementation. Tasks provided a visible checklist.

5. **Tested in isolated Docker environment** — Caught real bugs (grep exit codes, chsh failures, comment syntax) before they hit the real machine.

6. **Fixed forward instead of suppressing errors** — When vim hung, investigated with `ps aux` and manual run instead of retrying blindly.

### What to improve next time

- Break into separate commits per logical change instead of one large commit
- Consider running Docker tests automatically (CI/CD) rather than manually
- Could have used parallel agents for independent research tasks (e.g., checking CoC.nvim docs while patching config files)

### Techniques used
- [x] Plan mode
- [x] Explore agent
- [x] Task tracking
- [x] Interactive questions
- [x] Docker/isolated testing
- [ ] Multiple agents in parallel
