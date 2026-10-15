# Projekt: Hörbuch-Werkstatt – Fachbücher (PDF) → Hörbuch + Reader

## Ziel
Lizenzierte Fachbücher (meist Psychiatrie/Psychotherapie, deutsch) aus PDF in
(1) eine geprüfte Struktur-JSON, (2) eine Hörbuch-Produktions-JSON, (3) MP3-Tracks mit Zeitmarken und
(4) einen HTML-Reader mit synchroner Audio-Wiedergabe überführen. Nutzung ausschließlich privat.

## Arbeitsweise
- Antworten auf Deutsch, direkt, ohne Bestätigungsfloskeln am Anfang.
- Geprüftes klar von Annahmen trennen („geprüft: …“ / „Annahme: …“); Quellen nennen, wenn recherchiert.
- Vollständige, getestete Dateien liefern (keine Code-Schnipsel zum Einfügen). Vor der Auslieferung selbst prüfen:
  Vollständigkeit des Texts, Reihenfolge der Überschriften, Seitenzahlen, Skript läuft fehlerfrei.
- Befehle immer für Windows-PowerShell, Python-Aufruf mit `py`, gestartet im Projektordner `hoerbuecher`
  (Terminal über Explorer → Rechtsklick → „Im Terminal öffnen“; liegt auf Netzlaufwerk
  `\\192.168.178.71\personal_folder\Arztsachen\Hörbücher aus pdf\…`).
- Bei Unklarheit zuerst eine Probe anfordern (einige Seiten der PDF oder ein Ausschnitt der JSON), nicht raten.

## Pipeline
### 1. PDF → Struktur-JSON
Bevorzugtes Zielformat (wie `bindungstrauma_struktur.json`):
```
{title, subtitle, author, page_offset,
 front:[{id, title, blocks, footnotes?, hidden}],
 parts:[{num, title, chapters:[{num, title, authors, page,
   sections:[{num, title, level (2/3), page, blocks:[…]}],
   literatur:[…], footnotes:["1 Text", …]}]}],
 back:[{id, title, lines|blocks, hidden}]}
Blocktypen: p · li · li2 · dlg (+ s = Sprecherkürzel) · box (Kastentitel) · table (cap, rows)
```
Bei Büchern ohne Teile: ein einziger Teil oder `parts` weglassen und Kapitel direkt anlegen.

### 2. Prüfung und Bereinigung (Prüfliste als Datei mitliefern)
- Inhaltsverzeichnis gegen Überschriften im Text abgleichen (Nummern, Titel, Seiten; Seitenversatz PDF↔Buch).
- Typische Extraktionsfehler: zerrissene Ligaturen („häufi g“, „Th erapie“), verklebte Bindestriche
  („Drogenund“ → „Drogen- und“, aber Verben: „geprüftund“ → „geprüft und“), an Wörter geklebte
  Fußnotenziffern („Patienten1“), Kolumnentitel, Seitenzahlen, Abbildungs-/Tabellenreste, Download-Vermerke
  (mit IP – immer entfernen), schmale Leerzeichen.
- Unsichere Entscheidungen in die Prüfliste, nicht stillschweigend ändern.

### 3. Hörbuch-JSON (Schema `audiobook-1`, Vorlage: `werkzeug/build_audiobook_rpt.py`)
- `book`, `settings`, `lexicon`, `chapters` (Kapitelmarken), `tracks[]` mit `segments[]`
  (`id`, `type`, `text` = Original, `tts` = Sprechtext, `pause_after_ms`, `book_page`, `optional`, ggf. `speaker`),
  `excluded`, `stats`.
- Tracks: Ebene-2-Abschnitte; < 5 min mit Nachfolger zusammenlegen, > 25 min an Unterabschnitten/Zwischenüberschriften
  teilen; nie über Kapitelgrenzen. Tempo-Annahme 117 Wörter/min (gemessen, edge-tts).
- Sprechtext: Abkürzungen ausschreiben (z. B., d. h., u. U., S. 224 → Seite 224, Kap. 5.1 → Kapitel 5 Punkt 1),
  Bereiche „5–10“ → „5 bis 10“, % → Prozent, „Abb. 1-2“ → „Abbildung eins-zwei“,
  Literaturklammern „(Autor et al. 2010)“ entfernen, ▶-Querverweise → „siehe …“.
- Ansagen: Titeltrack, „Teil eins …“, „Kapitel 6. …“, Kapitelautoren, Abschnitte „6 Punkt 2. …“.
- Fußnoten direkt nach dem Absatz mit dem Verweiszeichen („Anmerkung: …“), sonst nach dem letzten Absatz der Seite.
- Dialoge mit gesprochener Rolle („Therapeutin: …“); Rollen aus dem Kontext ableiten und als Annahme kennzeichnen.
- Optional markieren: Fußnoten, Tabellenzeilen, Literaturlisten, Credits. Nicht vertonen: Literatur, Register,
  Impressum, Adressen, Klappentext (in `excluded` begründen).
- Prüfen: Originaltext vollständig enthalten, alle Überschriften in Reihenfolge, Seiten monoton, Segmente ≤ ~1500 Zeichen.

### 4. Vertonung (auf dem PC des Nutzers)
```
py werkzeug\hoerbuch_vertonen.py werkzeug\<buch>_hoerbuch.json --stimme de-DE-ConradNeural --tonhoehe -15Hz --aussprache werkzeug\aussprache_<kürzel>.txt --ausgabe <kürzel>\audio
```
- Fortsetzbar (fertige Tracks/Segmente werden übersprungen); schreibt `zeiten.js` für den Reader;
  `--nur-zeiten` berechnet Zeitmarken nachträglich (gleiche Optionen nötig); `--neu` erzwingt Neuaufbau.
- `aussprache.txt`: Zeilen `Original = Ersatz` (z. B. `Borderline = Borderlain`), gilt auch in Komposita.
- Bekannte Fehler: 403 → `py -m pip install -U edge-tts`; WinError 1455 → Platz auf C:/Arbeitsspeicher;
  `_segmente` nie löschen (Zeitmarken, schnelle Korrekturen).

### 5. Reader
- Neues Buch in `werkzeug/buecher.json` eintragen (`"kürzel": "<buch>_hoerbuch.json"`), dann `aktualisieren.bat`
  doppelklicken → baut alle Reader und die Startseite `index.html`.
- Reader: Text mit synchroner Markierung, Absatz antippen = dort hören, ±15 s, Tempo, Schlaf-Timer,
  Sperrbildschirm-Steuerung, Suche, Position je Buch; Browserstimme als Fallback ohne MP3.

### 6. Ablage
- Privates GitHub-Repository (`hoerbuecher`), `.gitignore` hält `_segmente`, WAV, M4B fern.
- Nicht GitHub Pages (Seiten sind öffentlich, auch bei privatem Repository). Für Zugriff unterwegs:
  Cloudflare Pages + Cloudflare Access (nur eigene E-Mail). MP3 ≤ 25 MiB je Datei.

## Ordnerstruktur
```
hoerbuecher/
  index.html  aktualisieren.bat  ANLEITUNG.md  .gitignore
  <kürzel>/index.html  <kürzel>/audio/ (MP3, zeiten.js, _segmente)
  werkzeug/ hoerbuch_vertonen.py · build_reader.py · reader2_template.html · build_audiobook_rpt.py
            stimmen_probe.py · buecher.json · *_hoerbuch.json · aussprache_<kürzel>.txt
```

## Bestehende Bücher
- `tfp`: Yeomans/Clarkin/Kernberg, Übertragungsfokussierte Psychotherapie für Borderline-Patienten (Schattauer 2017)
- `rpt`: Wöller, Bindungstrauma und Borderline-Störung – RPT (Schattauer 2014)
