#!/usr/bin/env bash

set -euo pipefail

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

detect_os() {
  if [ -n "${TARGET_OS:-}" ]; then
    case "$TARGET_OS" in
      windows|ubuntu|macos|linux)
        echo "$TARGET_OS"
        return
        ;;
      *)
        echo "Unsupported TARGET_OS '$TARGET_OS'. Use one of: windows, ubuntu, macos, linux." >&2
        exit 1
        ;;
    esac
  fi

  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      echo "windows"
      return
      ;;
    Darwin)
      echo "macos"
      return
      ;;
    Linux)
      if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        if [ "${ID:-}" = "ubuntu" ] || [[ "${ID_LIKE:-}" == *"ubuntu"* ]]; then
          echo "ubuntu"
          return
        fi
      fi
      echo "linux"
      return
      ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
}