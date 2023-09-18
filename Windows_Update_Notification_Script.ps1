# Function to check for Windows updates and get update details
Function CheckForUpdates {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $updates = $updateSearcher.Search("IsInstalled=0 and Type='Software'")

    If ($updates.Updates.Count -eq 0) {
        return $null
    } else {
        return $updates.Updates
    }
}

# Function to display a notification with update details
Function DisplayNotificationWithDetails($updates) {
    $message = "A fully up-to-date device is required to ensure that IT can accurately protect your device.`n`n'Click Yes' to open Windows Update, or 'No' to dismiss the notification.`n`nUpdate Details:`n"

    foreach ($update in $updates) {
        $message += "`nTitle: $($update.Title)`nDescription: $($update.Description)`nKBArticleIDs: $($update.KBArticleIDs)`n----------------------------------`n"
    }

    Add-Type -AssemblyName PresentationFramework
    $result = [System.Windows.MessageBox]::Show($message, "Update Notification", [System.Windows.MessageBoxButton]::YesNo)

    If ($result -eq [System.Windows.MessageBoxResult]::Yes) {
        Invoke-Expression -Command "control /name Microsoft.WindowsUpdate"
    }
}

# Check for updates and display notification with details
$availableUpdates = CheckForUpdates
If ($availableUpdates) {
    DisplayNotificationWithDetails $availableUpdates
}
