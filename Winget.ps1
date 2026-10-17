<#
.SYNOPSIS
    Updates all installed applications using WinGet.

.DESCRIPTION
    Locates WinGet for the current user and upgrades all packages
    that have available updates. Runs installers silently and accepts
    package and source agreements automatically.

    Before upgrading, records existing shortcuts on the user's desktop
    and the public desktop. After upgrading, removes newly created
    .lnk shortcuts while preserving shortcuts that existed beforehand.

    Returns exit code 0 on success or the WinGet exit code on failure.

.NOTES
    - Requires WinGet to be available for the current user.
    - Newly created desktop shortcuts are removed after the upgrade.
    - A shortcut created manually during the upgrade may also be removed.
    - Existing shortcuts overwritten at the same path are preserved.
    - Shortcut cleanup runs even if WinGet returns a non-zero exit code.
#>

$ErrorActionPreference = 'Stop'

# Locate WinGet for the current user
$Winget = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\winget.exe'

if (-not (Test-Path $Winget)) {
    throw "WinGet not found at $Winget"
}

# Snapshot existing desktop shortcuts
$DesktopPaths = @(
    [Environment]::GetFolderPath('Desktop')
    [Environment]::GetFolderPath('CommonDesktopDirectory')
) | Where-Object { $_ -and (Test-Path $_) } |
    Select-Object -Unique

$ExistingShortcuts = @(
    foreach ($Desktop in $DesktopPaths) {
        Get-ChildItem -Path $Desktop -Filter '*.lnk' -File |
            Select-Object -ExpandProperty FullName
    }
)

# Upgrade all packages that WinGet can update
& $Winget upgrade --all `
    --silent `
    --accept-package-agreements `
    --accept-source-agreements `
    --disable-interactivity

$ExitCode = $LASTEXITCODE

# Remove newly created desktop shortcuts
foreach ($Desktop in $DesktopPaths) {
    Get-ChildItem -Path $Desktop -Filter '*.lnk' -File |
        Where-Object { $_.FullName -notin $ExistingShortcuts } |
        Remove-Item -Force
}

if ($ExitCode -ne 0) {
    Write-Error "WinGet finished with exit code $ExitCode"
    exit $ExitCode
}

exit 0
