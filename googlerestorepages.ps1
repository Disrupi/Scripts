# Path to Chrome Preferences file
$prefPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences"

# Backup original
$backupPath = "$prefPath.bak"
Copy-Item -Path $prefPath -Destination $backupPath -Force
Write-Output "Backup created at $backupPath"

# Read and parse JSON
$json = Get-Content -Path $prefPath -Raw | ConvertFrom-Json -Depth 100

# Check and modify the session.restore_on_startup value
if ($json.session -and $json.session.restore_on_startup -eq 5) {
    $json.session.restore_on_startup = 4
    Write-Output "Changed restore_on_startup from 5 to 4"
} else {
    Write-Output "No change needed or restore_on_startup not found"
}

# Write back modified JSON
$json | ConvertTo-Json -Depth 100 | Set-Content -Path $prefPath -Encoding UTF8

Write-Output "Preferences file updated."
