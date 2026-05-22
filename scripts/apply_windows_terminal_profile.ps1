param(
  [string]$SchemeName = 'Pixegami',
  [string]$FontFace = 'Roboto Mono for Powerline',
  [int]$FontSize = 14
)

$ErrorActionPreference = 'Stop'

function Resolve-WindowsTerminalSettingsPath {
  $candidates = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
  )

  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) {
      return $candidate
    }
  }

  throw 'Windows Terminal settings.json was not found in expected package locations.'
}

function Convert-JsoncToJson {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Text
  )

  $withoutBlockComments = [Regex]::Replace($Text, '/\*.*?\*/', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
  $withoutLineComments = [Regex]::Replace($withoutBlockComments, '(?m)^\s*//.*$', '')
  $withoutTrailingCommas = [Regex]::Replace($withoutLineComments, ',\s*([}\]])', '$1')
  return $withoutTrailingCommas
}

$settingsPath = Resolve-WindowsTerminalSettingsPath
$rawSettings = Get-Content -LiteralPath $settingsPath -Raw
$settings = (Convert-JsoncToJson -Text $rawSettings) | ConvertFrom-Json -Depth 100

if ($null -eq $settings.profiles) {
  $settings | Add-Member -MemberType NoteProperty -Name profiles -Value ([PSCustomObject]@{})
}

if ($null -eq $settings.profiles.list) {
  $settings.profiles | Add-Member -MemberType NoteProperty -Name list -Value @()
}

$profiles = @($settings.profiles.list)
if ($profiles.Count -eq 0) {
  throw 'No terminal profiles found in settings.json.'
}

$gitBashProfile = $profiles |
  Where-Object {
    $_.name -match 'Git Bash' -or
    ($_.commandline -is [string] -and $_.commandline -match 'git-bash\.exe|\\bash\.exe')
  } |
  Select-Object -First 1

if ($null -eq $gitBashProfile) {
  throw 'No Git Bash profile found in Windows Terminal settings. Create a Git Bash profile first, then rerun install_profile.sh.'
}

if ($null -eq $gitBashProfile.font) {
  $gitBashProfile | Add-Member -MemberType NoteProperty -Name font -Value ([PSCustomObject]@{})
}

$gitBashProfile.font.face = $FontFace
$gitBashProfile.font.size = $FontSize
$gitBashProfile.colorScheme = $SchemeName

$pixegamiScheme = [PSCustomObject]@{
  name          = $SchemeName
  background    = '#0C1C25'
  foreground    = '#86FFAF'
  black         = '#152535'
  red           = '#FF3C3C'
  green         = '#49FF6D'
  yellow        = '#FFBC51'
  blue          = '#3DB6F9'
  purple        = '#8E44AD'
  cyan          = '#16A085'
  white         = '#BDC3C7'
  brightBlack   = '#26384B'
  brightRed     = '#FF3C4C'
  brightGreen   = '#93FF91'
  brightYellow  = '#FFD057'
  brightBlue    = '#5BD7FF'
  brightPurple  = '#9B59B6'
  brightCyan    = '#205C57'
  brightWhite   = '#FFFFFF'
}

if ($null -eq $settings.schemes) {
  $settings | Add-Member -MemberType NoteProperty -Name schemes -Value @()
}

$existingScheme = @($settings.schemes) | Where-Object { $_.name -eq $SchemeName } | Select-Object -First 1
if ($null -eq $existingScheme) {
  $settings.schemes += $pixegamiScheme
} else {
  foreach ($prop in $pixegamiScheme.PSObject.Properties.Name) {
    $existingScheme.$prop = $pixegamiScheme.$prop
  }
}

if ($null -ne $gitBashProfile.guid) {
  $settings.defaultProfile = $gitBashProfile.guid
}

$backupPath = "$settingsPath.bak"
Copy-Item -LiteralPath $settingsPath -Destination $backupPath -Force

$updatedJson = $settings | ConvertTo-Json -Depth 100
Set-Content -LiteralPath $settingsPath -Value $updatedJson -Encoding UTF8

Write-Host "Updated Windows Terminal settings at: $settingsPath"
Write-Host "Backup created at: $backupPath"
Write-Host "Applied scheme '$SchemeName' to profile '$($gitBashProfile.name)'."
