#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_ROOT/scripts/os_helpers.sh"

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

install_ubuntu_deps() {
	run_privileged apt-get update
	run_privileged apt-get install -y python3-pip fonts-powerline
}

install_macos_deps() {
	if command_exists brew; then
		brew install python
	else
		echo "Homebrew not found. Skipping package bootstrap for macOS."
	fi
}

os_name="$(detect_os)"

case "$os_name" in
	windows)
		echo "Detected Windows (Git Bash/MSYS). Installing Powerline user dependencies."
		install_powerline_python
		install_vim_profile
		bash "$REPO_ROOT/fonts/install.sh" "Roboto Mono"
		echo "Powerline/font setup complete for Windows."
		;;
	ubuntu)
		echo "Detected Ubuntu. Installing dependencies with apt-get."
		install_ubuntu_deps
		install_powerline_python
		install_vim_profile
		bash "$REPO_ROOT/fonts/install.sh" "Roboto Mono"
		echo "Powerline/font setup complete for Ubuntu."
		;;
	macos)
		echo "Detected macOS. Installing dependencies with Homebrew where available."
		install_macos_deps
		install_powerline_python
		install_vim_profile
		bash "$REPO_ROOT/fonts/install.sh" "Roboto Mono"
		echo "Powerline/font setup complete for macOS."
		;;
	linux)
		echo "Detected non-Ubuntu Linux. Installing what is available without distro-specific package manager assumptions."
		install_powerline_python
		install_vim_profile
		bash "$REPO_ROOT/fonts/install.sh" "Roboto Mono"
		echo "Powerline/font setup complete for Linux."
		;;
esac