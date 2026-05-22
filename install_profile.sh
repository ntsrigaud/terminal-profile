#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_ROOT/scripts/os_helpers.sh"

ensure_zsh_in_path() {
	local candidate
	for candidate in \
		/usr/bin \
		/c/Program\ Files/Git/usr/bin \
		/c/tools/msys64/usr/bin \
		/c/msys64/usr/bin
	do
		if [ -x "$candidate/zsh.exe" ] || [ -x "$candidate/zsh" ]; then
			case ":$PATH:" in
				*":$candidate:"*) ;;
				*) PATH="$candidate:$PATH" ;;
			esac
		fi
	done
	export PATH
}

clone_or_update_plugin() {
	local repo_url="$1"
	local target_dir="$2"

	if [ -d "$target_dir/.git" ]; then
		git -C "$target_dir" pull --ff-only
	else
		git clone "$repo_url" "$target_dir"
	fi
}

if [ ! -d "$HOME/.oh-my-zsh" ]; then
	echo "Oh My Zsh is not installed yet. Run ./install_terminal.sh first."
	exit 1
fi

mkdir -p "$HOME/.oh-my-zsh/custom/plugins"

# Install or update plug-ins.
clone_or_update_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
clone_or_update_plugin "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

# Replace the configs with the saved one.
cp "$REPO_ROOT/configs/.zshrc" "$HOME/.zshrc"

# Copy the modified Agnoster Theme.
cp "$REPO_ROOT/configs/pixegami-agnoster.zsh-theme" "$HOME/.oh-my-zsh/themes/pixegami-agnoster.zsh-theme"

apply_ubuntu_terminal_profile() {
	if ! command_exists dconf; then
		echo "dconf not found; skipping GNOME Terminal profile import."
		return
	fi

	# Color Theme
	dconf load /org/gnome/terminal/legacy/profiles:/:fb358fc9-49ea-4252-ad34-1d25c649e633/ < "$REPO_ROOT/configs/terminal_profile.dconf"

	# Add it to the default list in the terminal.
	add_list_id=fb358fc9-49ea-4252-ad34-1d25c649e633
	old_list=$(dconf read /org/gnome/terminal/legacy/profiles:/list | tr -d "]")

	if [ -z "$old_list" ]; then
		front_list="["
	else
		front_list="$old_list, "
	fi

	new_list="$front_list'$add_list_id']"
	dconf write /org/gnome/terminal/legacy/profiles:/list "$new_list"
	dconf write /org/gnome/terminal/legacy/profiles:/default "'$add_list_id'"
}

apply_macos_terminal_profile() {
	bash "$REPO_ROOT/scripts/apply_iterm2_profile.sh"
}

maybe_switch_default_shell() {
	if [ "${AUTO_CHSH:-0}" != "1" ]; then
		echo "Skipping default shell switch. Set AUTO_CHSH=1 to enable automatic chsh."
		return
	fi

	if command_exists chsh && command_exists zsh; then
		chsh -s "$(command -v zsh)"
	fi
}

os_name="$(detect_os)"

case "$os_name" in
	windows)
		echo "Applying Windows Terminal profile and color scheme."
		powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$REPO_ROOT/scripts/apply_windows_terminal_profile.ps1"
		;;
	ubuntu)
		echo "Applying Ubuntu terminal profile and shell configuration."
		apply_ubuntu_terminal_profile
		maybe_switch_default_shell
		;;
	macos)
		echo "Applying macOS iTerm2 profile and shell configuration."
		apply_macos_terminal_profile
		maybe_switch_default_shell
		;;
	linux)
		echo "Applying Linux shell configuration."
		maybe_switch_default_shell
		;;
esac

ensure_zsh_in_path

if command_exists zsh || command_exists zsh.exe; then
	echo "Profile setup complete. Start zsh with: zsh"
else
	echo "Profile copied, but zsh was not found in PATH."
fi
