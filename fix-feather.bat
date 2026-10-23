@echo off
setlocal enabledelayedexpansion
title Feather Client Fixer & Dawn Blocker

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin permissions...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ========================================================
echo   Feather Client - Login Fix & Dawn Blocker
echo ========================================================
echo.

set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"

:: Remove read-only attribute from hosts if present
attrib -R "%HOSTS_FILE%" >nul 2>&1

:: 1. Block auto-update to Dawn Client
findstr /i "launcher.feathercdn.net" "%HOSTS_FILE%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Blocking forced Dawn Client auto-update...
    echo 127.0.0.1 launcher.feathercdn.net>>"%HOSTS_FILE%"
) else (
    echo [OK] Dawn update block already in hosts.
)

:: 2. Fix DNS for version downloads and MS login
findstr /i "game-launcher.feathermc.com" "%HOSTS_FILE%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Fixing game-launcher.feathermc.com connection...
    echo 104.26.11.70 game-launcher.feathermc.com>>"%HOSTS_FILE%"
) else (
    echo [OK] game-launcher.feathermc.com route already in hosts.
)

:: Restore Read-Only attribute
attrib +R "%HOSTS_FILE%" >nul 2>&1

:: 3. Flush DNS
echo [*] Flushing DNS cache...
ipconfig /flushdns >nul 2>&1

:: 4. Kill processes and clean updater files
echo [*] Cleaning updater cache...
taskkill /F /IM "Feather Launcher.exe" >nul 2>&1
taskkill /F /IM "Dawn.exe" >nul 2>&1
taskkill /F /IM "dawn-installer*.exe" >nul 2>&1

if exist "%LOCALAPPDATA%\feather-updater" (
    rmdir /S /Q "%LOCALAPPDATA%\feather-updater" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Dawn" (
    rmdir /S /Q "%LOCALAPPDATA%\Dawn" >nul 2>&1
)

:: 5. Disable app-update.yml
set "FEATHER_INSTALL_DIR=%ProgramFiles%\Feather Launcher"
if exist "%FEATHER_INSTALL_DIR%\resources\app-update.yml" (
    echo [*] Disabling app-update.yml...
    ren "%FEATHER_INSTALL_DIR%\resources\app-update.yml" "app-update.yml.bak" >nul 2>&1
)

echo.
echo ========================================================
echo   Done! Feather Client is fixed.
echo   You can now launch Feather Launcher normally.
echo ========================================================
echo.
pause
