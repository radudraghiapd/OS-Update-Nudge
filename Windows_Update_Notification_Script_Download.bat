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

:: Define the path for the "Windows_Update_Check.bat" script
set "bat_script=%script_dir%Windows_Update_Check.bat"

:: Check if the task "Windows_Update_Check" exists
schtasks /query /tn "Windows_Update_Check" 2>nul
if %errorlevel% equ 0 (
    echo Task "Windows_Update_Check" exists.
) else (
    echo Task "Windows_Update_Check" does not exist.
    
    :: Create the directory if it doesn't exist
    if not exist "%script_dir%" (
        mkdir "%script_dir%"
    )

    :: Download the PowerShell script
    powershell -command "(New-Object System.Net.WebClient).DownloadFile('%script_url%', '%downloaded_script%')"

    :: Check if the download was successful
    if !errorlevel! equ 0 (
        echo Downloaded script to %downloaded_script%
        
        :: Create the "Windows_Update_Check.bat" script
        echo @echo off > "%bat_script%"
        echo PowerShell.exe -ExecutionPolicy Bypass -File "%downloaded_script%" >> "%bat_script%"
        echo Batch script "Windows_Update_Check.bat" created.
        
        :: Create a scheduled task for "Windows_Update_Check.bat"
        schtasks /create /tn "Windows_Update_Check" /tr "%bat_script%" /sc daily /st 12:00
        echo Scheduled task "Windows_Update_Check" created.
        
        :: Run the "Windows_Update_Check.bat" script
        call "%bat_script%"
        
        echo Script execution complete.
    ) else (
        echo Failed to download the script from %script_url%
    )
)

endlocal
