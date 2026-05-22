# Pixegami Terminal Profile

![terminal](./terminal_screenshot.png)

This repository now supports Windows 11 with Git Bash as the main target.

It installs:

- Roboto Mono Powerline font for the current Windows user
- zsh + Oh My Zsh
- zsh plugins: syntax highlighting and autosuggestions
- custom Pixegami agnoster theme
- Windows Terminal color scheme + Git Bash profile font settings

## Target Environment

- OS: Windows 11
- Shell host: Git Bash (MINGW64/MSYS)
- Terminal: Windows Terminal

## Prerequisites

Install these first:

- Git for Windows (includes Git Bash)
- Windows Terminal
- One package manager for zsh bootstrap: `choco`, `winget`, or `pacman`
- Optional for Vim Powerline integration: `python3` + `pip3` + `vim`

The scripts are idempotent, so it is safe to re-run them.

## Installation (Windows 11 + Git Bash)

From repository root:

```bash
./install_powerline.sh
./install_terminal.sh
./install_profile.sh
```

Then start zsh:

```bash
zsh
```

If this is your first time configuring zsh on Windows, restart Windows Terminal after installation.

## What Each Script Does

### 1) Powerline and fonts

```bash
./install_powerline.sh
```

- Installs `powerline-status` with `pip3` when available
- Copies [configs/.vimrc](configs/.vimrc)
- Installs Powerline fonts into `%LOCALAPPDATA%/Microsoft/Windows/Fonts`

### 2) zsh and Oh My Zsh

```bash
./install_terminal.sh
```

- Ensures `zsh` exists
- Tries installers in this order: `pacman`, `choco`, `winget`
- Installs Oh My Zsh unattended

### 3) profile, plugins, and terminal colors

```bash
./install_profile.sh
```

- Installs or updates zsh plugins
- Copies [configs/.zshrc](configs/.zshrc)
- Copies [configs/pixegami-agnoster.zsh-theme](configs/pixegami-agnoster.zsh-theme)
- Applies Windows Terminal settings using [scripts/apply_windows_terminal_profile.ps1](scripts/apply_windows_terminal_profile.ps1)

## Reset / Rollback (Windows)

- Windows Terminal settings are backed up automatically to `settings.json.bak` before modifications
- To rollback terminal styling, restore the backup file in your Windows Terminal LocalState folder
- To disable this profile quickly, change the Windows Terminal profile color scheme and font in Settings UI
- To stop using zsh in a session, run `bash`

## Linux Notes (Legacy)

Linux support is still present, including `apt-get` and `dconf` profile import behavior.
Windows is now the primary tested path.

## Sources

- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [Powerline Fonts](https://github.com/powerline/fonts)
- [Agnoster Theme](https://gist.github.com/3712874)

