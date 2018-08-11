# Windows Update in Packer

* https://www.packer.io
* https://www.powershellgallery.com/packages/PSWindowsUpdate/

Performing a windows update within a packer build can be problematic. From what I could establish this is caused by a security feature within the Windows Update process, this prevents downloads when it’s initiated by a remote caller such as WinRM. As a workaround a scheduled task can be used to invoke the update as the local system account. These two scripts can be incorporated into a packer build to perform a windows update.

The packer script creates a registry key\value for signalling, creates and initiates a scheduled task, then waits for this to complete by checking the registry. 

The script ```windows\windowsUpdate.ps1``` must be copied into the Windows OS prior to packer running the ```packer\windowsUpdate.ps1``` script. You could use the file provisioner to do this.

    {
      "type": "file",
      "source": "windows\windowsUpdate.ps1",
      "destination": "c:\temp\build\scripts\windowsUpdate.ps1"
    }

The update script should be used as follows, the restart timeout may need increasing. The packer script is located ```packer\windowsUpdate.ps1```.

    {
      "type": "powershell",
      "scripts": [
        "windowsUpdate.ps1"
      ]
    },
    { 
      "type": "windows-restart",
      "restart_check_command": "powershell -command \"& {Write-Output 'restarted.'}\"",
      "restart_timeout": "15m"
    },

