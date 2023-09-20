#!/bin/bash

# Function to check for software updates
checkForUpdates() {
    updatesAvailable=$(softwareupdate -l)

    # Initialize variables to store update information and determine extraction
    versionNumber=""
    extractInfo=false

    # Split the lines into a list
    IFS=$'\n' read -r -a linesList <<< "$updatesAvailable"

    # Iterate through the list to find the version number
    for thisLine in "${linesList[@]}"; do
        # Extract the version number if the line contains the word "macOS"
        if [[ $thisLine == *macOS* ]]; then
            # Extract the version number
            versionNumber=$(echo "$thisLine" | awk '{print $NF}')
            break
        fi
    done

    # If the version number was found, continue extracting other information
    if [[ -n "$versionNumber" ]]; then
        extractInfo=true
    fi

    # Initialize a variable to store update information
    updateInfo=""

    # Extract and format the relevant update information for all updates
    for thisLine in "${linesList[@]}"; do
        if $extractInfo && [[ $thisLine != "" && $thisLine != " " && $thisLine != *$'\t'* && $thisLine != *"Recommended:"* && $thisLine != *"Action:"* ]]; then
            updateInfo+="$thisLine"$'\n'
        else
            break
        fi
    done

    if [[ -n "$versionNumber" ]]; then
        echo "$versionNumber"$'\n'"$updateInfo"
    fi
}

# Function to display a notification
displayNotification() {
    updateDetails=$(checkForUpdates)

    if [[ -n "$updateDetails" ]]; then
        messageText="A fully up-to-date device is required to ensure that IT can accurately protect your device."
        buttonText="Click \"Open Updates\" to install them."
        dialogText="$messageText"$'\n'$'\n'$updateDetails$'\n'$buttonText
        display dialog "$dialogText" buttons {"Open Updates", "Dismiss"} default button "Open Updates" with icon caution
    fi
}

# Set the path to the user's home directory
current_user=$(stat -f %Su /dev/console)
user_home_dir=$(eval echo ~$current_user)

# Set the path to the Scripts directory in the user's home directory
scripts_dir="$user_home_dir/Library/Scripts"

# Create the Scripts directory if it doesn't exist
mkdir -p "$scripts_dir"

# Set the path to the AppleScript file in the user's home directory
applescript_file="$scripts_dir/macos_update.applescript"

# Check if the AppleScript file exists, and create it if not
if [ ! -f "$applescript_file" ]; then
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
    
    if updateDetails is not equal to "" then
        set messageText to "A fully up-to-date device is required to ensure that IT can accurately protect your device."
        set buttonText to "Click \"Open Updates\" to install them."
        set dialogText to messageText & return & return & updateDetails & return & buttonText
        display dialog dialogText buttons {"Open Updates", "Dismiss"} default button "Open Updates" with icon caution
    end if
end displayNotification

-- Check for updates and display the notification
displayNotification()
EOL
fi

# Check for updates
updateDetails=$(checkForUpdates)

# If updates are available, run the AppleScript
if [[ -n "$updateDetails" ]]; then
    # Schedule the script to run daily at 12:00 noon using cron syntax
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/osascript $applescript_file") | crontab -
fi

# Set permissions and ownership for the user
chmod +x "$applescript_file"
chown "$current_user" "$applescript_file"
