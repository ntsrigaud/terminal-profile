#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

install_powerline_python() {
	if command_exists pip3; then
		pip3 install --user --upgrade powerline-status
		return
	fi

	if command_exists python3; then
		python3 -m pip install --user --upgrade powerline-status
		return
	fi

	echo "Skipping powerline-status install: python3/pip3 not found."
}

install_vim_profile() {
	if [ -f "$REPO_ROOT/configs/.vimrc" ]; then
		cp "$REPO_ROOT/configs/.vimrc" "$HOME/.vimrc"
	fi
}

if is_windows; then
	echo "Detected Windows (Git Bash/MSYS). Installing Powerline user dependencies."
	install_powerline_python
	install_vim_profile
	bash "$REPO_ROOT/fonts/install.sh" "Roboto Mono"
	echo "Powerline/font setup complete for Windows."
	exit 0
fi

echo "Detected Unix-like OS. Installing Linux dependencies."
run_privileged apt-get update
run_privileged apt-get install -y python3-pip fonts-powerline
install_powerline_python
install_vim_profile
bash "$REPO_ROOT/fonts/install.sh" "Roboto Mono"
echo "Powerline/font setup complete for Linux."