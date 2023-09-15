# Function to check for Windows updates
Function CheckForUpdates {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $updates = $updateSearcher.Search("IsInstalled=0 and Type='Software'")

    If ($updates.Updates.Count -eq 0) {
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
    }
}

# Check for updates
If (CheckForUpdates) {
    DisplayNotification
}
