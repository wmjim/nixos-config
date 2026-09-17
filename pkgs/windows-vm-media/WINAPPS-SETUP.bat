@echo off
REM WinApps Windows-side setup - single entry point, run this from the media ISO.
REM
REM Step 1 runs the pinned upstream script (RDP registry switches, firewall group
REM enable, TimeSync / NetProfileCleanup scheduled tasks). Step 2 fixes what step 1
REM cannot do on localized Windows: oem\install.bat enables the Remote Desktop
REM firewall rules by their ENGLISH display group name, which does not resolve on
REM e.g. Chinese Windows ("远程桌面"), so the rules stay disabled and 3389 keeps
REM being dropped even though the RDP listener is up.
title WinApps VM setup

REM 'fltmc' succeeds only for administrators; otherwise relaunch elevated.
fltmc >nul 2>&1
if errorlevel 1 (
    echo [INFO] Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo ============================================================
echo  WinApps VM setup
echo    [1/2] oem\install.bat        - registry + scheduled tasks
echo    [2/2] winapps-fix-rdp.ps1    - language-proof firewall fix
echo ============================================================
echo.

if exist "%~dp0oem\install.bat" (
    echo [1/2] Running oem\install.bat ...
    call "%~dp0oem\install.bat"
    echo.
) else (
    echo [WARN] oem\install.bat not found next to this script, skipping step 1.
    echo        ^(RDP registry switches are re-applied by step 2 anyway.^)
    echo.
)

echo [2/2] Running winapps-fix-rdp.ps1 ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0winapps-fix-rdp.ps1"

echo.
echo [INFO] Done. Reboot Windows, then run 'winapps-setup --user' on the Linux side.
echo [INFO] Press any key to close this window.
pause >nul
