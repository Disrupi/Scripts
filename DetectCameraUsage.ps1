$paths = @(
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam\NonPackaged"
)

$activeApps = foreach ($path in $paths) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path | ForEach-Object {
            $lastUsedStop = Get-ItemProperty -Path $_.PSPath -Name "LastUsedTimeStop" -ErrorAction SilentlyContinue
            if ($null -ne $lastUsedStop -and $lastUsedStop.LastUsedTimeStop -eq 0) {
                $_.PSChildName
            }
        }
    }
}

if ($activeApps) {
    Write-Host "Camera is currently IN USE by:" -ForegroundColor Red
    $activeApps | ForEach-Object { Write-Host " - $_" }
} else {
    Write-Host "Camera is NOT in use." -ForegroundColor Green
}
