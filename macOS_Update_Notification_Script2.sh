#!/bin/bash

# Get the currently logged-in username
current_user=$(stat -f %Su /dev/console)

# Set the path to the user's home directory
user_home_dir=$(eval echo ~$current_user)

# Set the path to the Scripts directory in the user's home directory
scripts_dir="$user_home_dir/Library/Scripts"

# Create the Scripts directory if it doesn't exist
mkdir -p "$scripts_dir"

# Set the path to the script files in the user's home directory
applescript_file="$scripts_dir/macos_update.applescript"
bash_script_file="$scripts_dir/OSXupdate.sh"

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

# Set the ownership of the LaunchAgent plist to the current user
chown "$current_user" "$launchagent_file"

# Create the AppleScript file directly in the Scripts directory
cat <<EOL > "$applescript_file"
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

# Create the Bash script directly in the Scripts directory
cat <<EOL > "$bash_script_file"
#!/bin/bash

# Function to check for software updates
checkForUpdates() {
    updatesAvailable=\$(softwareupdate -l)

    # Initialize variables to store update information and determine extraction
    versionNumber=""
    extractInfo=false

    # Split the lines into a list
    IFS=\$'\n' read -r -a linesList <<< "\$updatesAvailable"

    # Iterate through the list to find the version number
    for thisLine in "\${linesList[@]}"; do
        # Extract the version number if the line contains the word "macOS"
        if [[ \$thisLine == *macOS* ]]; then
            # Extract the version number
            versionNumber=\$(echo "\$thisLine" | awk '{print \$NF}')
            break
        fi
    done

    # If the version number was found, continue extracting other information
    if [[ -n "\$versionNumber" ]]; then
        extractInfo=true
    fi

    # Initialize a variable to store update information
    updateInfo=""

    # Extract and format the relevant update information for all updates
    for thisLine in "\${linesList[@]}"; do
        if \$extractInfo && [[ \$thisLine != "" && \$thisLine != " " && \$thisLine != *\$'\t'* && \$thisLine != *"Recommended:"* && \$thisLine != *"Action:"* ]]; then
            updateInfo+="\$thisLine"\$'\n'
        else
            break
        fi
    done

    if [[ -n "\$versionNumber" ]]; then
        echo "\$versionNumber"\$'\n'"\$updateInfo"
    fi
}

# Check for updates
updateDetails=\$(checkForUpdates)

# If updates are available, run the AppleScript
if [[ -n "\$updateDetails" ]]; then
    osascript "$applescript_file"
fi
EOL


# Set permissions and ownership for the user
chmod +x "$applescript_file" "$bash_script_file"
chown "$current_user" "$applescript_file" "$bash_script_file"



# Load the LaunchAgent for the user
launchctl bootstrap gui/$UID "$launchagent_file"  # Load the launch agent

echo "Scripts and LaunchAgent created and configured for user: $current_user"

