@echo off
setlocal enabledelayedexpansion

:: Define the URL of the PowerShell script on GitHub
set "script_url=https://github.com/radudraghiapd/itdep/raw/main/Windows_Update_Notification_Script.ps1"

:: Define the directory to save the script
set "script_dir=C:\ProgramData\"

:: Define the script name
set "script_name=Windows_Update_Notification_Script.ps1"

:: Define the full path to the downloaded script
set "downloaded_script=%script_dir%%script_name%"

:: Create the directory if it doesn't exist
if not exist "%script_dir%" (
    mkdir "%script_dir%"
)

:: Download the PowerShell script
powershell -command "(New-Object System.Net.WebClient).DownloadFile('%script_url%', '%downloaded_script%')"

:: Check if the download was successful
if !errorlevel! equ 0 (
    echo Downloaded script to %downloaded_script%
    
    :: Run the PowerShell script with bypassing the execution policy
    powershell -ExecutionPolicy Bypass -File "%downloaded_script%"
    
    :: Clean up the downloaded script
    del "%downloaded_script%"
    
    echo Script execution complete.
) else (
    echo Failed to download the script from %script_url%
)

endlocal
