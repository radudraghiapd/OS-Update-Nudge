#!/bin/bash

# Define the user's home directory
user_home="$HOME"

# Define script files and folders
scripts_folder="$user_home/Library/Scripts"
applescript_file="$scripts_folder/macos_update.applescript"
bash_script_file="$scripts_folder/check_updates.sh"
launch_agent_file="$user_home/Library/LaunchAgents/com.osxupdatecheck.plist"

# Create the "Scripts" folder if it doesn't exist
mkdir -p "$scripts_folder"

# Create and populate the macos_update.applescript file
cat > "$applescript_file" <<EOF
-- Function to check for software updates
on checkForUpdates()
    do shell script "softwareupdate -l"
end checkForUpdates

-- Function to display a notification
on displayNotification()
    set updateDetails to checkForUpdates()
    set messageText to "A fully up-to-date device is required to ensure that IT can accurately protect your device."
    set infoText to "Update Details:" & return & updateDetails
    set buttonText to "Click \"Open Updates\" to install them."
    display dialog messageText & return & return & infoText & return & buttonText buttons {"Open Updates", "Dismiss"} default button "Open Updates" with icon caution
end displayNotification

-- Check for updates and display the notification
displayNotification()
EOF

# Create and populate the check_updates.sh file
cat > "$bash_script_file" <<EOF
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
    osascript "$applescript_file"
fi
EOF

# Create and populate the com.osxupdatecheck.plist file
cat > "$launch_agent_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.osxupdatecheck</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$bash_script_file</string>
    </array>
    <key>StandardOutPath</key>
    <string>/tmp/runscript.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/runscript-error.log</string>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>12</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
EOF

# Make the script files executable
chmod +x "$applescript_file"
chmod +x "$bash_script_file"

echo "Files and folder created successfully."
