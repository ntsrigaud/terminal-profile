#!/bin/bash
set -euo pipefail

# Set source and target directories
powerline_fonts_dir="$( cd "$( dirname "$0" )" && pwd )"

# if an argument is given it is used to select which fonts to install
prefix="${1:-}"

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

if is_windows; then
  echo "Installing fonts for Windows user profile..."
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command '& {
    param([string]$SourceDir, [string]$Prefix)
    $ErrorActionPreference = "Stop"
    $source = Resolve-Path -LiteralPath $SourceDir
    $target = Join-Path $env:LOCALAPPDATA "Microsoft/Windows/Fonts"

    if (!(Test-Path -LiteralPath $target)) {
      New-Item -ItemType Directory -Path $target | Out-Null
    }

    $nameFilter = if ([string]::IsNullOrWhiteSpace($Prefix)) { "*" } else { "$Prefix*" }

    Get-ChildItem -Path $source -Recurse -File |
      Where-Object { $_.Extension -in ".ttf", ".otf" -and $_.Name -like $nameFilter } |
      ForEach-Object {
        $dest = Join-Path $target $_.Name
        Copy-Item -LiteralPath $_.FullName -Destination $dest -Force

        $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
        $fontName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) + " (TrueType)"
        Set-ItemProperty -Path $regPath -Name $fontName -Value $_.Name -Force
      }

    Write-Host "Fonts copied to" $target
  }' "$powerline_fonts_dir" "$prefix"
  echo "Powerline fonts installed for Windows. Restart Windows Terminal to apply changes."
  exit 0
fi

if test "$(uname)" = "Darwin" ; then
  # MacOS
  font_dir="$HOME/Library/Fonts"
else
  # Linux
  font_dir="$HOME/.local/share/fonts"
  mkdir -p $font_dir
fi

# Copy all fonts to user fonts directory
echo "Copying fonts..."
find "$powerline_fonts_dir" \( -name "$prefix*.[ot]tf" -or -name "$prefix*.pcf.gz" \) -type f -print0 | xargs -0 -n1 -I % cp "%" "$font_dir/"

# Reset font cache on Linux
if which fc-cache >/dev/null 2>&1 ; then
    echo "Resetting font cache, this may take a moment..."
    fc-cache -f "$font_dir"
fi

echo "Powerline fonts installed to $font_dir"
