#!/bin/bash

# Get the currently logged-in username
current_user=$(stat -f %Su /dev/console)

# Set the path to the user's home directory
user_home_dir=$(eval echo ~$current_user)

# Set the path to the script files
applescript_file="/Library/Scripts/macos_update.applescript"
bash_script_file="/Library/Scripts/macos_update_script.sh"
launchdaemon_file="/Library/LaunchDaemons/com.osx.update_check.plist"

# Create the LaunchDaemon plist file
sudo bash -c "cat <<EOL > $launchdaemon_file
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
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
EOL"

# Create the AppleScript file
cat <<EOL | sudo tee "$applescript_file" > /dev/null
-- ... (Your AppleScript code here)
EOL

# Create the Bash script
cat <<EOL | sudo tee "$bash_script_file" > /dev/null
#!/bin/bash
osascript "$applescript_file"
EOL

# Set permissions and ownership based on the current user
sudo chown "$current_user" "$applescript_file" "$bash_script_file"
sudo chmod +x "$applescript_file" "$bash_script_file"

# Load the LaunchDaemon
sudo launchctl load "$launchdaemon_file"

echo "Scripts and LaunchDaemon created and configured for user: $current_user"
