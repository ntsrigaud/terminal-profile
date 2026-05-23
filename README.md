# Pixegami Terminal Profile

![terminal](./terminal_screenshot.png)

This repository supports Windows 11 (Git Bash), Ubuntu Linux, and macOS.

It installs:

- RobotoMono Nerd Font Mono directly from Nerd Fonts GitHub releases
- zsh + Oh My Zsh
- zsh plugins: syntax highlighting and autosuggestions
- custom Pixegami agnoster theme
- Windows Terminal color scheme + Git Bash profile font settings

## Supported Environments

- Windows 11: Git Bash + Windows Terminal
- Ubuntu Linux: GNOME Terminal
- macOS: iTerm2

## Prerequisites

Install these first:

- Windows:
	- Git for Windows (includes Git Bash)
	- Windows Terminal
	- One package manager for zsh bootstrap: `choco`, `winget`, or `pacman`
- Ubuntu:
	- `sudo` access for `apt-get`
- macOS:
	- Homebrew
	- iTerm2

Optional for Vim Powerline integration on all OSes: `python3` + `pip3` + `vim`

The scripts are idempotent, so it is safe to re-run them.

## Installation

### Auto-detect OS (recommended)

From repository root:

```bash
./install.sh
```

### Explicit OS entry scripts

If you want to force a specific OS flow:

```bash
./install_windows.sh
./install_ubuntu.sh
./install_macos.sh
```

The scripts are idempotent, so re-running is safe.

### Start zsh

From repository root:

```bash
zsh
```

If this is your first time configuring zsh, restart your terminal application after installation.

## What Each Script Does

### 1) Powerline and fonts

```bash
./install_powerline.sh
```

- Installs `powerline-status` with `pip3` when available
- Copies [configs/.vimrc](configs/.vimrc)
- Downloads `RobotoMono.zip` directly from Nerd Fonts releases and installs it to OS-specific user font directories:
	- Windows: `%LOCALAPPDATA%/Microsoft/Windows/Fonts`
	- Ubuntu/Linux: `~/.local/share/fonts`
	- macOS: `~/Library/Fonts`
- Checks first whether the required Nerd Font is already installed and skips download/install when found

You do not need to manually install fonts or change font names in terminal settings.

### 2) zsh and Oh My Zsh

```bash
./install_terminal.sh
```

- Ensures `zsh` exists
- Uses OS package manager:
	- Windows: `pacman`, `choco`, `winget`
	- Ubuntu: `apt-get`
	- macOS: `brew`
- Installs Oh My Zsh unattended

### 3) profile, plugins, and terminal colors

```bash
./install_profile.sh
```

- Installs or updates zsh plugins
- Copies [configs/.zshrc](configs/.zshrc)
- Copies [configs/pixegami-agnoster.zsh-theme](configs/pixegami-agnoster.zsh-theme)
- Applies terminal configuration by OS:
	- Windows Terminal settings using [scripts/apply_windows_terminal_profile.ps1](scripts/apply_windows_terminal_profile.ps1)
	- Ubuntu GNOME Terminal settings via [configs/terminal_profile.dconf](configs/terminal_profile.dconf)
	- iTerm2 dynamic profile using [scripts/apply_iterm2_profile.sh](scripts/apply_iterm2_profile.sh)
- On Windows, configures Git Bash to discover zsh reliably without forcing startup handoff (auto-zsh is opt-in to avoid startup lockups)
- On Windows, creates a `~/bin/zsh` shim and updates `~/.bashrc` to prepend the detected zsh binary directory, ensuring `zsh` is available in normal Git Bash sessions
- On Windows, writes zsh config/theme/plugins into the detected MSYS2 zsh home (for example `/c/msys64/home/<user>`) and normalizes `HOME` inside zsh to your Windows profile path (`/c/Users/<user>`) so `cd` and `~` stay Windows-native

To temporarily stay in Bash on Windows, launch with:

PIXEGAMI_SKIP_AUTO_ZSH=1 bash

To enable auto-start handoff from Bash to zsh on Windows (optional):

```bash
PIXEGAMI_ENABLE_AUTO_ZSH=1 ./install_profile.sh
```

To automatically switch your default shell to zsh on Unix systems, run with:

```bash
AUTO_CHSH=1 ./install.sh
```

## Reset / Rollback

- Windows:
	- Windows Terminal settings are backed up to `settings.json.bak`
	- Restore backup to rollback theme/profile changes
- Ubuntu:
	- Remove the imported GNOME Terminal profile or reset dconf keys
- macOS:
	- Remove `~/Library/Application Support/iTerm2/DynamicProfiles/pixegami-terminal-profile.json`
- To stop using zsh in any session, run `bash`.

## Sources

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
- [Agnoster Theme](https://gist.github.com/3712874)

