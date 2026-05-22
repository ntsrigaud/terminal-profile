#!/usr/bin/env bash

set -euo pipefail

NERD_FONT_NAME="${NERD_FONT_NAME:-RobotoMono}"
NERD_FONT_ASSET="${NERD_FONT_NAME}.zip"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${NERD_FONT_ASSET}"

tmp_dir="$(mktemp -d)"
archive_path="$tmp_dir/$NERD_FONT_ASSET"
extract_dir="$tmp_dir/extracted"

cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

is_windows() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 1 ;;
  esac
}

download_archive() {
  echo "Downloading ${NERD_FONT_ASSET} from Nerd Fonts releases..."
  if command -v curl >/dev/null 2>&1; then
    curl -fL "$NERD_FONT_URL" -o "$archive_path"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -O "$archive_path" "$NERD_FONT_URL"
    return
  fi

  echo "curl or wget is required to download fonts."
  exit 1
}

extract_archive() {
  mkdir -p "$extract_dir"
  if command -v unzip >/dev/null 2>&1; then
    unzip -oq "$archive_path" -d "$extract_dir"
    return
  fi

  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '& {
      param([string]$ArchivePath, [string]$Destination)
      Expand-Archive -Path $ArchivePath -DestinationPath $Destination -Force
    }' "$archive_path" "$extract_dir"
    return
  fi

  echo "unzip or powershell.exe is required to extract font archive."
  exit 1
}

ensure_fonts_found() {
  if ! find "$extract_dir" -type f \( -name '*.ttf' -o -name '*.otf' \) | grep -q .; then
    echo "No font files found in extracted archive."
    exit 1
  fi
}

install_windows_fonts() {
  echo "Installing Nerd Font for current Windows user..."
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '& {
    param([string]$SourceDir)
    $ErrorActionPreference = "Stop"

    $source = Resolve-Path -LiteralPath $SourceDir
    $target = Join-Path $env:LOCALAPPDATA "Microsoft/Windows/Fonts"
    if (!(Test-Path -LiteralPath $target)) {
      New-Item -ItemType Directory -Path $target | Out-Null
    }

    Get-ChildItem -Path $source -Recurse -File |
      Where-Object { $_.Extension -in ".ttf", ".otf" } |
      ForEach-Object {
        $dest = Join-Path $target $_.Name
        Copy-Item -LiteralPath $_.FullName -Destination $dest -Force

        $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
        $fontName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) + " (TrueType)"
        Set-ItemProperty -Path $regPath -Name $fontName -Value $_.Name -Force
      }

    Write-Host "Fonts copied to" $target
  }' "$extract_dir"
}

install_unix_fonts() {
  local font_dir
  if [ "$(uname -s)" = "Darwin" ]; then
    font_dir="$HOME/Library/Fonts"
  else
    font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
  fi

  echo "Installing Nerd Font to $font_dir"
  find "$extract_dir" -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp -f {} "$font_dir/" \;

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$font_dir"
  fi
}

download_archive
extract_archive
ensure_fonts_found

if is_windows; then
  install_windows_fonts
  echo "Nerd Font installation complete on Windows. Restart Windows Terminal to refresh font list."
else
  install_unix_fonts
  echo "Nerd Font installation complete. Restart your terminal to refresh font list."
fi
