# Define the path for the PowerShell script to check for updates and display notifications
$scriptPath = "C:\ProgramData\Windows_Update_Notification_Script.ps1"

# Create the PowerShell script to check for updates and display notifications
$scriptContent = @"
# Function to check for Windows updates
Function CheckForUpdates {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $updates = $updateSearcher.Search("IsInstalled=0 and Type='Software'").Updates

    If ($updates.Count -eq 0) {
        return $false
    } else {
        return $true
    }
}

# Function to display a notification
Function DisplayNotification {
    Add-Type -AssemblyName PresentationFramework
    $result = [System.Windows.MessageBox]::Show("Windows updates are available. Click 'Open Updates' to install them.", "Update Notification", [System.Windows.MessageBoxButton]::YesNo)

    If ($result -eq [System.Windows.MessageBoxResult]::Yes) {
        Invoke-Expression -Command "control /name Microsoft.WindowsUpdate"

        # Add your additional script or command here
        Invoke-Expression -Command "C:\ProgramData\Windows_Update_Notification_Script.ps1"
    }
}

# Check for updates
If (CheckForUpdates) {
    DisplayNotification
}

"@
Set-Content -Path $scriptPath -Value $scriptContent

# Register a scheduled task to run the script daily at 12:00 PM
$taskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
$taskTrigger = New-ScheduledTaskTrigger -Daily -At "12:00 PM"
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName "Windows_Update_Check" -User "NT AUTHORITY\SYSTEM" -Force

Write-Host "Script and scheduled task created and configured."
