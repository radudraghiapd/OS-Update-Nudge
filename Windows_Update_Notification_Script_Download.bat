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

:: Define the path for the VBS script
set "vbs_script=%script_dir%RunPowerShellScript.vbs"

:: Create the directory if it doesn't exist
if not exist "%script_dir%" (
    mkdir "%script_dir%"
)

:: Download the PowerShell script
powershell -command "(New-Object System.Net.WebClient).DownloadFile('%script_url%', '%downloaded_script%')"

:: Check if the download was successful
if !errorlevel! equ 0 (
    :: Create the VBS script
    echo Set objShell = CreateObject("WScript.Shell"^) > "%vbs_script%"
    echo objShell.Run "powershell.exe -ExecutionPolicy Bypass -File %downloaded_script%", 0, True >> "%vbs_script%"
    echo VBScript "RunPowerShellScript.vbs" created.
    echo Script creation complete.

    :: Specify the path to the PowerShell script
    set "scriptPath=%downloaded_script%"

    :: Unblock the file
    Powershell -Command "Unblock-File -Path '%scriptPath%'"

    :: Create a scheduled task to run for all interactive users
    schtasks /create /tn Windows_Update_Check /rl HIGHEST /tr "%vbs_script%" /sc daily /st 12:00 /ru "NT AUTHORITY\INTERACTIVE"
) else (
    echo Failed to download the script from %script_url%
)

endlocal
