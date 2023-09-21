#!/bin/bash

# Directory paths
launch_agents_dir="/Library/LaunchAgents"
scripts_dir="/Library/Scripts"

# Create Scripts directory if it doesn't exist
if [ ! -d "$scripts_dir" ]; then
    sudo mkdir -p "$scripts_dir"
fi

# Create check_updates.sh script
cat > "$scripts_dir/check_updates.sh" <<EOF
#!/bin/bash
# Function to check for updates
function checkForUpdates() {
    softwareupdate -l
}
# Check for updates
update_check=\$(checkForUpdates 2>&1)
# Check if updates are available
if ! echo "\$update_check" | grep -q "No new software available."; then
    # Updates available, execute the AppleScript to display the dialog
    osascript <<EOF
    display dialog "A fully up-to-date device is required to ensure that IT can accurately protect your device." & return & return & "Info about the update goes here." & return & return & "Click \"Open Updates\" to install them." buttons {"Open Updates", "Dismiss"} default button "Open Updates" with icon caution
    
    set buttonChoice to button returned of result
    
    if buttonChoice is equal to "Open Updates" then
        do shell script "open /System/Library/PreferencePanes/SoftwareUpdate.prefPane"
    end if
EOF
fi
EOF

# Make check_updates.sh executable
sudo chmod +x "$scripts_dir/check_updates.sh"

# Create macos_update.applescript
cat > "$scripts_dir/macos_update.applescript" <<EOF
-- Function to check for software updates
on checkForUpdates()
    do shell script "softwareupdate -l"
end checkForUpdates
-- Check for updates
set updatesAvailable to checkForUpdates()
-- Function to display a notification
on displayNotification()
    set updateDetails to do shell script "softwareupdate -l"
    
    set messageText to "A fully up-to-date device is required to ensure that IT can accurately protect your device."
    set buttonText to "Click \"Open Updates\" to install them."
    set dialogText to messageText & return & return & updateDetails & return & buttonText
    
    display dialog dialogText buttons {"Open Updates", "Dismiss"} default button "Open Updates" with icon caution
end displayNotification
-- Display the notification only if updates are available
if updatesAvailable contains "No new software available." then
    -- No updates available, do nothing
else
    -- Updates available, display the notification
    displayNotification()
    
    -- Capture the response
    set response to button returned of result
    
    -- Check the response and open the Software Update preference pane if "Open Updates" was clicked
    if response is equal to "Open Updates" then
        do shell script "open /System/Library/PreferencePanes/SoftwareUpdate.prefPane"
    end if
end if
EOF

# Create com.osx.updatecheck.plist
cat > "$launch_agents_dir/com.osxupdatecheck.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.osxupdatecheck</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Library/Scripts/check_updates.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>12</integer> <!-- Adjust the hour as needed -->
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/runscript.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/runscript-error.log</string>
</dict>
</plist>
EOF

# Set permissions
sudo chmod 644 "$launch_agents_dir/com.osxupdatecheck.plist"

echo "Files and folders created successfully."
