@echo off
setlocal enabledelayedexpansion
title Feather Client Fixer & Dawn Blocker

:: Sprawdzenie uprawnien administratora
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Prosze o uprawnienia administratora...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ========================================================
echo   Feather Client - Fix Logowania MS i Blokada Dawna
echo ========================================================
echo.

set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"

:: Zdjecie atrybutu tylko do odczytu z pliku hosts (jesli istnieje)
attrib -R "%HOSTS_FILE%" >nul 2>&1

:: 1. Blokada auto-update do Dawn Client
findstr /i "launcher.feathercdn.net" "%HOSTS_FILE%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Blokowanie wymuszonej aktualizacji do Dawn Client...
    echo 127.0.0.1 launcher.feathercdn.net>>"%HOSTS_FILE%"
) else (
    echo [OK] Blokada aktualizacji Dawn juz istnieje w pliku hosts.
)

:: 2. Fix DNS dla pobierania wersji i logowania Microsoft (Cloudflare CDN)
findstr /i "game-launcher.feathermc.com" "%HOSTS_FILE%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Naprawianie polaczenia z game-launcher.feathermc.com...
    echo 104.26.11.70 game-launcher.feathermc.com>>"%HOSTS_FILE%"
) else (
    echo [OK] Przekierowanie game-launcher.feathermc.com juz istnieje w pliku hosts.
)

:: Przywrocenie atrybutu Read-Only
attrib +R "%HOSTS_FILE%" >nul 2>&1

:: 3. Czyszczenie cache DNS
echo [*] Czyszczenie pamieci podrecznej DNS...
ipconfig /flushdns >nul 2>&1

:: 4. Zamykanie procesow i czyszczenie folderow instalatora Dawn
echo [*] Czyszczenie tymczasowych plikow instalatora Dawn...
taskkill /F /IM "Feather Launcher.exe" >nul 2>&1
taskkill /F /IM "Dawn.exe" >nul 2>&1
taskkill /F /IM "dawn-installer*.exe" >nul 2>&1

if exist "%LOCALAPPDATA%\feather-updater" (
    rmdir /S /Q "%LOCALAPPDATA%\feather-updater" >nul 2>&1
)
if exist "%LOCALAPPDATA%\Dawn" (
    rmdir /S /Q "%LOCALAPPDATA%\Dawn" >nul 2>&1
)

:: 5. Deaktywacja pliku konfiguracyjnego aktualizatora
set "FEATHER_INSTALL_DIR=%ProgramFiles%\Feather Launcher"
if exist "%FEATHER_INSTALL_DIR%\resources\app-update.yml" (
    echo [*] Wylaczanie modulu app-update.yml...
    ren "%FEATHER_INSTALL_DIR%\resources\app-update.yml" "app-update.yml.bak" >nul 2>&1
)

echo.
echo ========================================================
echo   SUKCES! Feather Client zostal pomyslnie naprawiony!
echo   Mozesz teraz bezpiecznie uruchomic Feather Launchera.
echo ========================================================
echo.
pause