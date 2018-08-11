[string]$taskName = 'windowsUpdate'
[string]$updateScriptPath = 'c:\temp\build\scripts\windowsUpdate.ps1'

New-Item -Path 'HKLM:\SOFTWARE\Packer\'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Packer\' -Name 'taskCompleted' -Value '0' -PropertyType 'String' -Force

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-file $updateScriptPath -ExecutionPolicy Bypass"
Register-ScheduledTask -Action $action -User 'NT AUTHORITY\SYSTEM' -TaskName 'windowsUpdate' -Description "created by packer"
Start-ScheduledTask -TaskName $taskName

$stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

while($true) {
  $taskStatus = Get-ItemProperty 'HKLM:\SOFTWARE\Packer\' | Select-Object taskCompleted
  $taskMessageItem = Get-ItemProperty 'HKLM:\SOFTWARE\Packer\' | Select-Object taskMessage
  $taskMessageValue =  $taskMessageItem.taskMessage

  if ($taskStatus.taskCompleted -ne '1') {
    $elapsed = '{0:D2}:{1:D2}:{2:D2}' -f $stopWatch.Elapsed.Hours, $stopWatch.Elapsed.Minutes, $stopWatch.Elapsed.Seconds
    Write-Output "Waiting for completion of task $taskName : $elapsed : task message $taskMessageValue"
    Start-Sleep -s 60
  }
  else {
    Write-Output "Completion of task $taskName : $elapsed : task message $taskMessageValue"
    break
  }
}
