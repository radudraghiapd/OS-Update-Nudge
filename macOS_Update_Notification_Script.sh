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

# Create the AppleScript file in the user's home directory
cat <<EOL > "$applescript_file"
-- ... (Your AppleScript code here)
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
