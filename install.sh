#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_ROOT/scripts/os_helpers.sh"

os_name="$(detect_os)"

echo "Detected target OS: $os_name"

echo "[1/3] Installing powerline and fonts"
bash "$REPO_ROOT/install_powerline.sh"

echo "[2/3] Installing shell dependencies"
bash "$REPO_ROOT/install_terminal.sh"

echo "[3/3] Applying shell and terminal profile"
bash "$REPO_ROOT/install_profile.sh"

echo "All steps completed for OS: $os_name"
