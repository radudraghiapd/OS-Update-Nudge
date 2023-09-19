#!/bin/bash

# Get the currently logged-in username
current_user=$(stat -f %Su /dev/console)

# Set the path to the user's home directory
user_home_dir=$(eval echo ~$current_user)

# Set the path to the script files in the user's home directory
applescript_file="$user_home_dir/Library/Scripts/macos_update.applescript"
bash_script_file="$user_home_dir/Library/Scripts/macos_update_script.sh"

# Set the path to the LaunchAgent plist in the user's LaunchAgents folder
launchagent_file="$user_home_dir/Library/LaunchAgents/com.osx.update_check.plist"

# Create the LaunchAgent plist file
cat <<EOL > "$launchagent_file"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
   <key>Label</key>
   <string>com.osx.update_check</string>
   <key>Program</key>
   <string>$bash_script_file</string>
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
    set updatesAvailable to do shell script "softwareupdate -l"
    
    -- Initialize variables to store update information and determine extraction
    set versionNumber to ""
    set extractInfo to false
    
    -- Split the lines into a list
    set linesList to paragraphs of updatesAvailable
    
    -- Iterate through the list to find the version number
    repeat with i from 1 to count linesList
        set thisLine to item i of linesList
        if thisLine contains "macOS Ventura" then
            -- Extract the version number
            set versionNumber to last word of thisLine
            exit repeat
        end if
    end repeat
    
    -- If the version number was found, continue extracting other information
    if versionNumber is not equal to "" then
        set extractInfo to true
    end if
    
    -- Initialize a variable to store update information
    set updateInfo to ""
    
    -- Extract and format the relevant update information for all updates
    repeat with i from i to count linesList
        set thisLine to item i of linesList
        if extractInfo then
            if thisLine is not in {"", " ", tab} and thisLine does not contain "Recommended:" and thisLine does not contain "Action:" then
                set updateInfo to updateInfo & thisLine & return
            else
                exit repeat
            end if
        end if
    end repeat
    
    return versionNumber & return & updateInfo
end checkForUpdates

-- Function to display a notification
on displayNotification()
    set updateDetails to checkForUpdates()
    
    set messageText to "A fully up-to-date device is required to ensure that IT can accurately protect your device."
    set buttonText to "Click \"Open Updates\" to install them."
    set dialogText to messageText & return & return & updateDetails & return & buttonText
    display dialog dialogText buttons {"Open Updates", "Dismiss"} default button "Open Updates" with icon caution
end displayNotification

-- Check for updates and display the notification
displayNotification()

EOL

# Create the Bash script in the user's home directory
cat <<EOL > "$bash_script_file"
#!/bin/bash
osascript "$applescript_file"
EOL

# Set permissions and ownership for the user
chmod +x "$applescript_file" "$bash_script_file"
chown "$current_user" "$applescript_file" "$bash_script_file"

# Load the LaunchAgent for the user
launchctl bootstrap gui/$UID "$launchagent_file"

echo "Scripts and LaunchAgent created and configured for user: $current_user"
