# Define the OneDrive folder path
$oneDrivePath = "$env:USERPROFILE\OneDrive"

# Get all folders marked as "Always keep on this device"
$folders = Get-ChildItem -Path $oneDrivePath -Recurse -Directory | Where-Object {
    $_.Attributes -band [System.IO.FileAttributes]::Offline
}

# Output the folder paths
$folders | ForEach-Object { Write-Output $_.FullName }
