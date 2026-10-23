# Feather Client Fix (Dawn bypass & MS login fix)

after inpvp took over feather they started force updating everyone to dawn client and broke the dns for the old launcher (`game-launcher.feathermc.com`), causing `os error 11001` / unknown host during microsoft login.

this script blocks the dawn update and fixes the login so you can keep using feather client normally.

## Quick fix (automatic)
1. download `fix-feather.bat`
2. right click and run as administrator (or just double click and accept the uac prompt)
3. open feather client and log in. thats it.

## Manual fix (if you dont want to run scripts)
if you prefer doing it youreself:
1. open notepad as admin
2. open `C:\Windows\System32\drivers\etc\hosts`
3. add these two lines at the bottom:
```
127.0.0.1 launcher.feathercdn.net
104.26.11.70 game-launcher.feathermc.com
```
4. save the file.
5. open cmd and run `ipconfig /flushdns`
6. delete the folder `%localappdata%\feather-updater` if it exists
7. go to `C:\Program Files\Feather Launcher\resources` and rename `app-update.yml` to `app-update.yml.bak`

## How it works
- `launcher.feathercdn.net` is pointed to 127.0.0.1 so the launcher cant reach the server that downloads dawn client.
- `game-launcher.feathermc.com` dns was deleted by devs, but the cloudflare server with the version files is still up at `104.26.11.70`. adding this to hosts fixes `version_index.json` downloading and microsoft auth.
- removes the updater cache and renames `app-update.yml` so electron stops looking for updates completely.
