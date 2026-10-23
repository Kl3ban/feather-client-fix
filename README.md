# Feather Client - Dawn Bypass & Microsoft Login Fix

Automatyczny skrypt i przewodnik naprawiający **Feather Client** po jego przejęciu i próbie wymuszenia migracji na **Dawn Client**.

---

## 🛑 Problemy, które rozwiązuje ten projekt:
1. **Wymuszona aktualizacja do Dawn Client:** Feather Launcher pobierał w tle instalator `dawn-installer_*.exe` z `launcher.feathercdn.net` i podmieniał stary launcher na Dawn Clienta.
2. **Błąd autoryzacji MS i pobierania wersji:**
   ```text
   Autoryzacja MS nie powiodła się: couldn't download from url https://game-launcher.feathermc.com/release/version_index.json
   Caused by: client error (Connect) / dns error: Nieznany host (os error 11001)
   ```
   Nowi właściciele usunęli publiczny rekord DNS dla subdomeny `game-launcher.feathermc.com`. Jednak oryginalny serwer Cloudflare z wersjami i manifestami **wciąż działa pod adresem IP `104.26.11.70`**.

---

## 🚀 Jak użyć (automatycznie):
1. Pobierz plik [`fix-feather.bat`](fix-feather.bat).
2. Kliknij na niego prawym przyciskiem myszy i wybierz **Uruchom jako administrator** (skrypt sam poprosi o uprawnienia, jeśli o tym zapomnisz).
3. Uruchom Feather Launchera i zaloguj się swoim kontem Microsoft. Wszystko powinno działać!

---

## 🛠️ Jak to działa (ręczna naprawa):
Jeśli wolisz zrobić to ręcznie:
1. **Zablokowanie Dawn Client:**
   Otwórz plik `C:\Windows\System32\drivers\etc\hosts` jako Administrator i dodaj na końcu:
   ```text
   127.0.0.1 launcher.feathercdn.net
   ```
2. **Naprawa pobierania wersji (DNS Fix):**
   W tym samym pliku `hosts` dodaj wpis kierujący na działający serwer Cloudflare:
   ```text
   104.26.11.70 game-launcher.feathermc.com
   ```
3. **Wyczyszczenie cache:**
   * W wierszu poleceń (cmd): `ipconfig /flushdns`
   * Usuń folder `%LOCALAPPDATA%\feather-updater`
   * Zmień nazwę pliku `C:\Program Files\Feather Launcher\resources\app-update.yml` na `app-update.yml.bak`

---

## English Summary
Following the acquisition and rebrand of Feather Client into Dawn Client, users attempting to stay on Feather experience forced updates to Dawn and DNS resolution errors (`os error 11001`) when attempting to authenticate via Microsoft account because `game-launcher.feathermc.com` DNS records were altered.
Run [`fix-feather.bat`](fix-feather.bat) as Administrator to automatically:
* Block `launcher.feathercdn.net` to prevent Dawn auto-update.
* Point `game-launcher.feathermc.com` to the operational Cloudflare IP `104.26.11.70`.
* Flush the DNS cache and clean up updater artifacts.
