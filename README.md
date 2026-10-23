# Feather Client Fix (Dawn bypass & MS login / Error 522 fix)

after inpvp took over feather they started force updating everyone to dawn client, broke the dns for the old launcher (`game-launcher.feathermc.com`), and the in-game webapp server went down with cloudflare error 522 (`mc-webapp.feathermc.com`).

this fix stops the dawn update, fixes microsoft login, and patches the in-game menu so you can keep playing any minecraft version on feather client.

![Feather Launcher](screenshots/launcher.png)
![Mod Menu](screenshots/mod_menu.png)
![In Game](screenshots/in_game.png)

## Quick fix (automatic)
1. download this repo (or grab `fix-feather.bat` and `feather-fix-522.jar` together in the same folder).
2. run `fix-feather.bat` as administrator.
3. open feather client, log in and hit play.

## What it fixes
1. **Dawn Client forced update:** blocks `launcher.feathercdn.net` to 127.0.0.1 and cleans updater cache so dawn never downloads.
2. **Microsoft login / os error 11001:** `game-launcher.feathermc.com` dns was deleted, but the working cloudflare server is still up at `104.26.11.70`. adding this to hosts fixes `version_index.json` downloading.
3. **In-game menu Error 522 (Cloudflare timed out):** feather loads its in-game gui from `https://mc-webapp.feathermc.com/` which is currently dead. `feather-fix-522.jar` redirects it in memory to the working `beta.mc-webapp.feathermc.com` server on all mc versions (1.8.9, 1.12.2, 1.20.x, 1.21.x, etc.) without modifying any jar files on disk. Source code is in `src/FeatherFix522.java`.

## Manual fix (if you dont want to run scripts)
if you want to do it youreself:
1. open notepad as admin, open `C:\Windows\System32\drivers\etc\hosts`
2. add these lines at the bottom:
```
127.0.0.1 launcher.feathercdn.net
104.26.11.70 game-launcher.feathermc.com
```
3. save the file, open cmd and run `ipconfig /flushdns`
4. delete the folder `%localappdata%\feather-updater`
5. go to `C:\Program Files\Feather Launcher\resources` and rename `app-update.yml` to `app-update.yml.bak`
6. put `feather-fix-522.jar` inside `%appdata%\.feather\agent\`
7. in `%appdata%\.feather\settings.json`, add:
```json
"jwmArgs": "-javaagent:C:/Users/YOUR_USERNAME/AppData/Roaming/.feather/agent/feather-fix-522.jar"
```
