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

try_command() {
	set +e
	"$@"
	local exit_code=$?
	set -e
	return $exit_code
}

install_zsh_with_pacman() {
	if command_exists pacman; then
		if try_command pacman -Sy --noconfirm zsh; then
			ensure_zsh_in_path
			return 0
		fi
	fi

	if [ -x /c/msys64/usr/bin/pacman.exe ]; then
		if try_command /c/msys64/usr/bin/pacman.exe -Sy --noconfirm zsh; then
			ensure_zsh_in_path
			return 0
		fi
	fi

	return 1
}

install_msys2_windows() {
	if command_exists winget.exe; then
		try_command winget.exe install --exact --id MSYS2.MSYS2 --accept-source-agreements --accept-package-agreements
	fi

	if [ ! -d /c/msys64 ] && command_exists choco.exe; then
		try_command choco.exe install -y msys2
	fi
}

install_zsh_windows() {
	ensure_zsh_in_path
	if command_exists zsh; then
		echo "zsh already available."
		return
	fi

	if install_zsh_with_pacman; then
		return
	fi

	install_msys2_windows

	if install_zsh_with_pacman; then
		return
	fi

	if ! command_exists zsh; then
		echo "Unable to auto-install zsh. Install MSYS2 and run: pacman -Sy --noconfirm zsh"
		exit 1
	fi
}

install_oh_my_zsh() {
	if [ -d "$HOME/.oh-my-zsh" ]; then
		echo "Oh My Zsh already installed."
		return
	fi

	if ! command_exists git; then
		echo "git is required to install Oh My Zsh."
		exit 1
	fi

	git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"

	if [ ! -f "$HOME/.zshrc" ] && [ -f "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" ]; then
		cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
	fi
}

install_ubuntu_deps() {
	run_privileged apt-get update
	run_privileged apt-get install -y git-core zsh curl
}

install_macos_deps() {
	if ! command_exists brew; then
		echo "Homebrew is required on macOS. Install it from https://brew.sh and rerun."
		exit 1
	fi
	brew install git zsh curl
}

install_linux_deps() {
	if command_exists apt-get; then
		run_privileged apt-get update
		run_privileged apt-get install -y git-core zsh curl
		return
	fi

	if command_exists dnf; then
		run_privileged dnf install -y git zsh curl
		return
	fi

	if command_exists pacman; then
		run_privileged pacman -Sy --noconfirm git zsh curl
		return
	fi

	echo "No supported package manager found for Linux. Install git, zsh, and curl manually, then rerun."
	exit 1
}

os_name="$(detect_os)"

case "$os_name" in
	windows)
		echo "Detected Windows (Git Bash/MSYS)."
		install_zsh_windows
		install_oh_my_zsh
		echo "Terminal dependencies installed for Windows."
		;;
	ubuntu)
		echo "Detected Ubuntu. Installing terminal dependencies with apt-get."
		install_ubuntu_deps
		install_oh_my_zsh
		echo "Terminal dependencies installed for Ubuntu."
		;;
	macos)
		echo "Detected macOS. Installing terminal dependencies with Homebrew."
		install_macos_deps
		install_oh_my_zsh
		echo "Terminal dependencies installed for macOS."
		;;
	linux)
		echo "Detected non-Ubuntu Linux. Installing terminal dependencies with available package manager."
		install_linux_deps
		install_oh_my_zsh
		echo "Terminal dependencies installed for Linux."
		;;
esac
