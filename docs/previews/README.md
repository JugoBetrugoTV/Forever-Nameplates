# Lokale GUI-Vorschauen — 0.10.0

Die Abbildungen werden aus dem tatsächlichen Lua-Code und den aufgezeichneten Widgetdaten
des lokalen Simulators erstellt. Die Oberfläche wird mit deutscher Locale geöffnet;
Schaltflächen, Werte, Farben und Positionen stammen aus dem Code.

**Dies sind keine Ingame-Screenshots oder bestätigten 1:1-Pixelvergleiche.** Es gibt hier
keinen WoW-Client. DejaVu Sans ersetzt die Clientfonts; Balkenfüllungen sind einfarbig.
Fehlende native Texturen/Icons erscheinen als Kontur oder Schraffur. Textmaße,
Zeilenumbrüche, Ebenen und Clipping sind vereinfacht und können vom Client abweichen.
Die JSON-Dateien neben den Bildern dokumentieren Version, Zustand und fehlende Ressourcen.

Das isolierte Demo-Profil verwendet den Classic-Quellenentwurf mit zusätzlich angelegter
Castbar, Aura-Reihe und Casticon. Die Castbar wurde unter die Healthbar gesetzt, die Auren
darüber verankert. Die Vorschau zeigt den simulierten Zustand **Casting • Runeweaver**,
der Editor 200 % Zoom. Das verändert keine installierten Profile oder Addondefaults.
Auf der Komponentenseite ist die Aura-Reihe ausgewählt; die Castcontrols sind dort gesperrt.

| Ansicht | Vorschau |
| --- | --- |
| Layout-Editor | [PNG öffnen](forever-nameplates-0.10.0-studio.png) |
| Anker-/Aura-/Cast-Seite | [PNG öffnen](forever-nameplates-0.10.0-components.png) |

Erneut erstellen:

```bash
/workspace/forever-tools/bin/python Tools/preview_ui.py
```

In anderen Umgebungen Python mit `requirements-dev.lock` verwenden und gegebenenfalls
eine installierte TrueType-Schrift mit `--font /pfad/zur/schrift.ttf` angeben.
`--output /pfad/zum/ordner` ändert das Ausgabeziel. Der Generator lädt die komplette
TOC und öffnet die realen GUI-Seiten im Widget-Simulator. Er liest keine gespeicherten
Benutzerprofile oder echten Spieldaten. Es werden keine Spielgrafiken hinzugefügt.

Die ältere Illustration `forever-nameplates-0.3.0.png` bleibt archiviert und ist kein Bild
dieser aktuellen Oberfläche.
