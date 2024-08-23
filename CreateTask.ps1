#region Register Scheduled Task
$TaskDescription= "AT Deployment"
$Author = 'RoJasinski'
$ID= whoami

$ScheduledTaskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffffff')</Date>
    <Author>$Author</Author>
    <Description>$TaskDescription</Description>
    <URI>\$TaskDescription</URI>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <UserId>$ID</UserId>
      <Delay>PT1M</Delay>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Users\Disruptor\Desktop\boot.bat</Command>
    </Exec>
  </Actions>
</Task>
"@

if (Get-ScheduledTask -TaskName $TaskDescription -ErrorAction 'Ignore') {
    try {
        Unregister-ScheduledTask -TaskName $TaskDescription -ErrorAction 'Stop' -Confirm:$false
    }
    catch {
        exit 1
    }
}
if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\$TaskDescription") {
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\$TaskDescription" -Confirm:$false -Force -ErrorAction 'Stop'
}
$ExistingRegTasks = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks').Where({$_.GetValue('Description') -eq "$TaskDescription"})
if ($null -ne $ExistingRegTasks) {
    foreach ($Item in $ExistingRegTasks) {
        Remove-Item -Path $($Item.PSPath) -Force -Confirm:$false
    }
}
if (Test-Path -Path "$env:windir\System32\Tasks\$TaskDescription" -PathType 'Leaf') {
    Remove-Item -Path "$env:windir\System32\Tasks\$TaskDescription" -Force -Confirm:$false -ErrorAction 'Stop'
}

try {
    $null = Register-ScheduledTask -TaskName "$TaskDescription" -Xml $ScheduledTaskXml -ErrorAction 'Stop'
}
catch {
    Write-Error -Message $($_)
    exit 2
}