#!/usr/bin/env bash

set -euo pipefail

NERD_FONT_NAME="${NERD_FONT_NAME:-RobotoMono}"
NERD_FONT_ASSET="${NERD_FONT_NAME}.zip"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${NERD_FONT_ASSET}"
NERD_FONT_MATCH_REGEX='Roboto[ ]?Mono.*Nerd Font|RobotoMono.*NF'
FORCE_FONT_REINSTALL="${FORCE_FONT_REINSTALL:-0}"

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

windows_font_available() {
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Drawing; \$fonts = New-Object System.Drawing.Text.InstalledFontCollection; \$candidates = @('RobotoMono Nerd Font Mono','RobotoMono Nerd Font','Roboto Mono Nerd Font Mono','Roboto Mono Nerd Font','RobotoMono NFM','RobotoMono NF','RobotoMonoNerdFontMono'); \$installed = \$fonts.Families | ForEach-Object { \$_.Name }; if (\$candidates | Where-Object { \$installed -contains \$_ }) { exit 0 } else { exit 1 }"
}

unix_font_available() {
  if command -v fc-list >/dev/null 2>&1; then
    if fc-list | grep -Eiq "$NERD_FONT_MATCH_REGEX"; then
      return 0
    fi
  fi

  if [ "$(uname -s)" = "Darwin" ]; then
    if find "$HOME/Library/Fonts" -type f \( -iname '*roboto*mono*nerd*.ttf' -o -iname '*roboto*mono*nerd*.otf' \) 2>/dev/null | grep -q .; then
      return 0
    fi
  else
    if find "$HOME/.local/share/fonts" "$HOME/.fonts" -type f \( -iname '*roboto*mono*nerd*.ttf' -o -iname '*roboto*mono*nerd*.otf' \) 2>/dev/null | grep -q .; then
      return 0
    fi
  fi

  return 1
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

    Add-Type -AssemblyName System.Drawing
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class FontNative {
  [DllImport("gdi32.dll", CharSet = CharSet.Unicode)]
  public static extern int AddFontResourceW(string lpszFilename);

  [DllImport("user32.dll", SetLastError = true)]
  public static extern IntPtr SendMessageTimeout(
    IntPtr hWnd,
    uint Msg,
    UIntPtr wParam,
    IntPtr lParam,
    uint fuFlags,
    uint uTimeout,
    out UIntPtr lpdwResult
  );
}
"@

    Get-ChildItem -Path $source -Recurse -File |
      Where-Object { $_.Extension -in ".ttf", ".otf" } |
      ForEach-Object {
        $dest = Join-Path $target $_.Name
        Copy-Item -LiteralPath $_.FullName -Destination $dest -Force

        $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
        $pfc = New-Object System.Drawing.Text.PrivateFontCollection
        $pfc.AddFontFile($dest)
        $familyName = if ($pfc.Families.Length -gt 0) { $pfc.Families[0].Name } else { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) }
        $fontName = $familyName + " (TrueType)"
        Set-ItemProperty -Path $regPath -Name $fontName -Value $dest -Force

        [void][FontNative]::AddFontResourceW($dest)
      }

    [UIntPtr]$result = [UIntPtr]::Zero
    [void][FontNative]::SendMessageTimeout([IntPtr]0xffff, 0x001D, [UIntPtr]::Zero, [IntPtr]::Zero, 0x0002, 5000, [ref]$result)

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

if is_windows; then
  if [ "$FORCE_FONT_REINSTALL" != "1" ] && windows_font_available; then
    echo "Nerd Font already installed on Windows. Skipping download/install."
    exit 0
  fi

  download_archive
  extract_archive
  ensure_fonts_found

  install_windows_fonts
  echo "Nerd Font installation complete on Windows. Restart Windows Terminal to refresh font list."
else
  if unix_font_available; then
    echo "Nerd Font already installed. Skipping download/install."
    exit 0
  fi

  download_archive
  extract_archive
  ensure_fonts_found

  install_unix_fonts
  echo "Nerd Font installation complete. Restart your terminal to refresh font list."
fi
