# Hörbücher – Reader mit Audio

## Aufbau
```
hoerbuecher/
  index.html            Startseite (Bücherliste)
  tfp/index.html        Reader TFP-Buch
  tfp/audio/            ← MP3-Dateien + zeiten.js des TFP-Hörbuchs
  rpt/index.html        Reader Wöller (RPT)
  rpt/audio/            ← MP3-Dateien + zeiten.js des RPT-Hörbuchs
  werkzeug/             Skripte, Hörbuch-JSONs, Aussprachedateien
  .gitignore            hält Zwischenspeicher (_segmente) und M4B aus dem Repository
```

## 1. Zeitmarken erzeugen (einmal je Buch, nach dem Vertonen)
Der Reader braucht `zeiten.js`, um den Text synchron zum Audio zu markieren.
Neue Vertonungen schreiben sie automatisch. Für bereits vertonte Bücher:
mit **denselben Optionen wie beim Vertonen** plus `--nur-zeiten` aufrufen – es wird nichts neu gesprochen:

```
py werkzeug\hoerbuch_vertonen.py werkzeug\TFP_Borderline_hoerbuch.json --stimme de-DE-ConradNeural --tonhoehe -15Hz --ausgabe <Vertonungsordner> --aussprache <dieselbe aussprache.txt> --nur-zeiten
```
Meldet das Skript „Für N Tracks fehlen Zeitmarken“, stimmt eine Option nicht überein
(auch eine seither geänderte aussprache.txt zählt) – oder der Zwischenspeicher `_segmente` wurde gelöscht.

## 2. Audio in den Reader kopieren
```
Copy-Item <Vertonungsordner>\*.mp3, <Vertonungsordner>\zeiten.js -Destination tfp\audio
```
Danach `tfp\index.html` doppelklicken: Absatz anklicken → Audio startet an dieser Stelle.

## 3. Privat bei GitHub ablegen
1. GitHub Desktop installieren, anmelden.
2. File → Add local repository → diesen Ordner → „create a repository“ → **Private** auswählen → Publish.
3. Später: Änderungen erscheinen in GitHub Desktop → Commit → Push.

## 4. Unterwegs hören (privat geschützt)
GitHub Pages ist hierfür **nicht** geeignet: Pages-Seiten sind laut GitHub öffentlich, auch wenn das Repository privat ist.
Stattdessen Cloudflare Pages + Cloudflare Access (Zugang nur mit eigener E-Mail):
1. cloudflare.com → Konto anlegen → Workers & Pages → Create → Pages → „Connect to Git“ → GitHub-Repository wählen.
2. Build-Einstellungen: Framework „None“, Build-Befehl leer, Ausgabeordner `/`.
3. Zero Trust → Access → Applications → Add → Self-hosted → Domain `<projekt>.pages.dev` →
   Policy „Allow“, Include: Emails = eigene Adresse → Anmeldung per Einmal-Code (One-time PIN).
4. Die Adresse auf dem Handy öffnen, Code aus der Mail eingeben, „Zum Home-Bildschirm“ hinzufügen.

## Bedienung
- Absatz antippen: ab dort hören · ▶/⏸ · −15/+15 s · ⏮/⏭ Absatz zurück/vor · Tempo 0,8–2×
- Sperrbildschirm/Kopfhörertasten steuern die Wiedergabe (Media Session)
- ⚙: Quelle (Audio/Browserstimme), Schlaf-Timer, Mitscrollen
- Die Position wird je Buch und Gerät gespeichert.
- Tracks ohne MP3 liest automatisch die Browserstimme.

## Reader und Startseite neu bauen
`aktualisieren.bat` doppelklicken. Neue Bücher vorher in `werkzeug\buecher.json` eintragen.
