#!/bin/bash

# Create the LaunchDaemon plist file
cat <<EOL > /Library/LaunchDaemons/com.osx.update_check.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
   <key>Label</key>
   <string>com.osx.update_check</string>
   <key>Program</key>
   <string>/Library/Scripts/macos_update_script.sh</string>
   <key>RunAtLoad</key>
   <true/>
   <key>StartCalendarInterval</key>
   <dict>
       <key>Hour</key>
       <integer>12</integer> <!-- Hour in 24-hour format (e.g., 12 for noon) -->
       <key>Minute</key>
       <integer>0</integer> <!-- Minute (e.g., 0 for exactly at noon) -->
   </dict>
</dict>
</plist>
EOL

# Create the AppleScript file
cat <<EOL > /Library/Scripts/macos_update.applescript
-- Function to check for software updates
on checkForUpdates()
    do shell script "softwareupdate -l"
end checkForUpdates

-- Function to display a notification
on displayNotification()
    display dialog "Software updates are available. Click \"Open Updates\" to install them." buttons {"Open Updates", "Dismiss"} default button "Open Updates" with icon caution
end displayNotification

-- Check for updates
set updatesAvailable to checkForUpdates()

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
EOL

# Create the Bash script
cat <<EOL > /Library/Scripts/macos_update_script.sh
#!/bin/bash
osascript /Library/Scripts/macos_update.applescript
EOL

# Set permissions and ownership
chmod +x /Library/Scripts/macos_update.applescript
chmod +x /Library/Scripts/macos_update_script.sh

# Load the LaunchDaemon
launchctl load /Library/LaunchDaemons/com.osx.update_check.plist

echo "Scripts and LaunchDaemon created and configured."
