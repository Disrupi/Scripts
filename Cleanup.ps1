$TaskName = 'AT Deployment Cleanup'
$WinlogonPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'

$Service = New-Object -ComObject 'Schedule.Service'
$Service.Connect()

$Folder = $Service.GetFolder('\')
$Task = $Service.NewTask(0)

$Task.Settings.StartWhenAvailable = $true
$Task.Settings.Enabled = $true
$Task.Settings.DisallowStartIfOnBatteries = $false
$Task.Settings.StopIfGoingOnBatteries = $false

# Trigger: Windows startup
$Trigger = $Task.Triggers.Create(8) # TASK_TRIGGER_BOOT
$Trigger.Delay = 'PT30S'
$Trigger.Enabled = $true

# Action: wait 30 seconds, then remove AutoAdminLogon values
$Action = $Task.Actions.Create(0)
$Action.Path = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$Action.Arguments = @"
-NoProfile -NonInteractive -WindowStyle Hidden -Command "`$p='$WinlogonPath'; Start-Sleep -Seconds 30; Remove-ItemProperty -LiteralPath `$p -Name 'DefaultPassword','DefaultUserName','DefaultDomainName','AutoAdminLogon','AutoLogonCount' -ErrorAction SilentlyContinue"
"@.Trim()

# Register as Local System
$Folder.RegisterTaskDefinition(
    $TaskName,
    $Task,
    6,       # Create or update
    'SYSTEM',
    $null,
    5,       # TASK_LOGON_SERVICE_ACCOUNT
    $null
) | Out-Null
