# the-dots

Personal macOS development environment managed with [GNU Stow](https://www.gnu.org/software/stow/) and a [`gum`](https://github.com/charmbracelet/gum)-powered TUI wizard.

---

## What's in here

| Directory / File | Contents |
| ---------------- | -------- |
| `zsh/` | `.zshrc`, `.zshenv` — shell config, PATH |
| `git/` | `.gitconfig`, `.gitignore_global` |
| `macos/` | Desired-state macOS settings (Finder, Dock, system) |
| `homebrew/` | `install.sh` + `bundles/*.Brewfile` — app installation |
| `scripts/` | Individual action scripts invoked by Make targets |
| `lib/ui.sh` | Shared output helpers (color, prompts, status) |
| `wizard.sh` | Interactive TUI wrapper around the Makefile |
| `Makefile` | All runnable targets — source of truth for operations |

---

## Getting started

``` bash
# Clone
git clone https://github.com/thepanadev/the-dots.git ~/the-dots
cd ~/the-dots

# Launch the interactive wizard (installs gum if needed)
make the-dots
```

The wizard reads targets directly from the Makefile and shows a menu. Every option below is also runnable standalone.

---

## Available targets

| Command | What it does |
| ------- | ------------ |
| `make the-dots` | Interactive menu — pick and run any target |
| `make install-apps` | Install Homebrew (if missing), then choose app bundles |
| `make dotfiles-stow` | Choose dotfile packages to link into `$HOME` |
| `make dotfiles-unstow` | Choose dotfile packages to unlink from `$HOME` |
| `make git-setup` | Configure Git `user.name` and `user.email` |
| `make zsh-setup` | Configure zsh preferences |
| `make finder-setup` | Interactive Finder settings editor |
| `make dock-setup` | Interactive Dock settings editor |

---

## Homebrew app bundles

Apps are split into four Brewfiles under `homebrew/bundles/`:

| Bundle | Contents |
| ------ | -------- |
| `craft.Brewfile` | Editors, version control, dev tools, containers |
| `terminal.Brewfile` | Shells, CLI utilities, data tools |
| `ai.Brewfile` | AI and coding assistants |
| `productivity.Brewfile` | Browsers, notes, desktop tools, security |

`make install-apps` (or `homebrew/install.sh`) asks which bundles to install via an interactive multi-select, shows their contents, and confirms before running `brew bundle`.

---

## Dotfile packages

Dotfile symlinks are managed separately from setup flows. Use the Stow commands when you want to link or unlink packages such as `zsh` and `git`:

``` bash
make dotfiles-stow
make dotfiles-unstow
```

Both commands show a multi-select built from `STOW_PACKAGES` in the Makefile, then preview symlinks before applying changes.

---

## macOS settings

Settings live in `macos/config.sh` as shell variables with a `# [type]  Label` comment that the interactive menu (`macos/menu.sh`) parses. Changes are applied through helpers in `macos/helpers.sh`, which:

- Compare current system value vs. desired value before writing.
- Only call `killall Finder` / `killall Dock` when something actually changed.

``` bash
# Interactive editors
make finder-setup
make dock-setup
```

---

## Git identity

`user.name` and `user.email` are **not** tracked here. They live in `~/.gitconfig.local`, which is included by `git/.gitconfig`. `make git-setup` writes that file interactively.

---

## Credits

- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles) — the original macOS defaults reference
- [GNU Stow manual](https://www.gnu.org/software/stow/manual/) — symlink farm manager
- [dotfiles.github.io](https://dotfiles.github.io) — community dotfiles resource
