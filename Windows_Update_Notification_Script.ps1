# Define the script content as a Here-String
$scriptContent = @"
# Function to check for software updates
Function CheckForUpdates {
    $updateResult = softwareupdate -l 2>&1
    if ($updateResult -match "No new software available.") {
        return \`$false
    } else {
        return \`$true
    }
}

# Function to display a notification
Function DisplayNotification {
    Add-Type -TypeDefinition @"
    using System;
    using System.Windows.Forms;

    public class MessageBoxShowDialog {
        public static void ShowDialog() {
            DialogResult result = MessageBox.Show("Software updates are available. Click 'OK' to install them.", "Update Notification", MessageBoxButtons.OKCancel, MessageBoxIcon.Information);
            if (result == DialogResult.OK) {
                System.Diagnostics.Process.Start("ms-settings:windowsupdate");
            }
        }
    }
"@
    [MessageBoxShowDialog]::ShowDialog()
}

# Check for updates
if (CheckForUpdates) {
    DisplayNotification
}
"@

# Execute the script using Invoke-Expression
Invoke-Expression -Command $scriptContent
