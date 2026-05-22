#!/usr/bin/env bash

set -euo pipefail

is_windows() {
	case "$(uname -s)" in
		MINGW*|MSYS*|CYGWIN*)
			return 0
			;;
		*)
			return 1
			;;
	esac
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

run_privileged() {
	if command_exists sudo; then
		sudo "$@"
	else
		"$@"
	fi
}

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

install_zsh_windows() {
	ensure_zsh_in_path
	if command_exists zsh; then
		echo "zsh already available."
		return
	fi

	if command_exists pacman; then
		pacman -Sy --noconfirm zsh
		ensure_zsh_in_path
	elif command_exists choco.exe; then
		choco.exe install -y zsh
		ensure_zsh_in_path
	elif command_exists winget.exe; then
		winget.exe install --exact --id MSYS2.MSYS2 --accept-source-agreements --accept-package-agreements
		ensure_zsh_in_path
	fi

	if ! command_exists zsh; then
		echo "Unable to auto-install zsh. Install zsh with choco, winget, or pacman, then re-run this script."
		exit 1
	fi
}

install_oh_my_zsh() {
	if [ -d "$HOME/.oh-my-zsh" ]; then
		echo "Oh My Zsh already installed."
		return
	fi

	if command_exists curl; then
		RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
		return
	fi

	if command_exists wget; then
		RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
		return
	fi

	echo "curl/wget is required to install Oh My Zsh."
	exit 1
}

if is_windows; then
	echo "Detected Windows (Git Bash/MSYS)."
	install_zsh_windows
	install_oh_my_zsh
	echo "Terminal dependencies installed for Windows."
	exit 0
fi

echo "Detected Unix-like OS. Installing Linux dependencies."
run_privileged apt-get update
run_privileged apt-get install -y git-core zsh curl
install_oh_my_zsh
echo "Terminal dependencies installed for Linux."
