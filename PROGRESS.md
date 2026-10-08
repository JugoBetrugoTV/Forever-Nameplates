# Forever Nameplates — Entwicklungsstand 0.1.0

Stand: 2026-10-08. **Erster lokal prüfbarer Kern, kein abgeschlossenes Premium-Release.**
Der Name „Jugo Nameplate Studio“ aus dem ursprünglichen Briefing wurde durch
**Forever Nameplates** ersetzt; technisch lautet der Addon-Ordner `ForeverNameplates`.

## Implementiert

- Modularer Namespace, Ereignisbus, begrenztes Diagnoseprotokoll und TOC-Ladefolge.
- Forever-Kompatibilitätsschicht auf Basis der gelieferten client-spezifischen Quellen.
- Registry mit Health/Cast/Text/Panel/Target/Ornament/Artwork, deklaratives validiertes Modell.
- Gepoolte ereignisbasierte Overlay-Engine; keine Veränderung geschützter Blizzard-Frames.
- Zwölf geometrisch verschiedene Presets, inklusive vertikaler Arena-Plate und Segment-Ornamenten.
- Eigene Galerie, Studio-Canvas, Inspector, Profil-/Sharing-Seite und Diagnose; drei GUI-Skins.
- Drag-and-Drop, X/Y/Größe, Layer, Alpha, Farbe, Text, Fontgröße, vertikale/reverse Balken,
  Dekorationsform, Sperren/Sichtbarkeit, Snap, Zoom, Copy/Paste, Löschen, Undo/Redo und Elementreset.
- Acht Preview-Zustände: normal, elite, boss, freundlich, feindlicher Spieler, low health, cast, target.
- Account-/Charakterprofile, Duplizieren/Umbenennen, Versionsschema und explizite v0-Migration.
- Komprimierte, validierte Share-Codes ohne Ausführung importierten Codes.
- Asset-Importer/Watcher, TGA-Konvertierung, Alpha-/Öffnungsprüfung, Checksums, Manifest,
  Erkennung fehlender/veränderter Dateien, zwölf Theme-Aufträge plus GUI-Header.
- Installierbares ZIP, gepinnte eingebettete Libraries, geprüfter Upstream-Refresh.

## Geprüft und Grenzen der Evidenz

- **47 automatisierte Tests**, Lua 5.1 via Lupa sowie Python/Pillow.
- TOCs/Lua-Syntax, voller Addon- und GUI-Ladeablauf, gültige/ungültige Presets,
  Share-Roundtrips/Malformation/Größenlimits, Profile/Migration, atomare Editoränderungen,
  Undo/Redo, Drag, Secret-Health-Forwarding, verweigerte Widgets, geschützte/verbotene Basen,
  Frame-Recycling, fremde Interface-Version, Asset-Konvertierung/Idempotenz und Datenbewahrung.
- 16 untersuchte API-Signaturen gegen den Forever-Export geprüft.
- Library-Dateien aus gepinnten Quellen erneut heruntergeladen und per SHA-256 verifiziert.
- Benchmark in Widget-Simulation: 40 Plates, 4.000 Ereignis-Updates, keine neuen Widgetobjekte.
  Diese Messung belegt **keine** realen FPS, CPU- oder Speicherwerte im Spiel.
- Keiner dieser Tests lief in einem WoW-Client. Tatsächliche Combat-Freigaben, Nameplate-Anbindung,
  Timer-Verhalten, Pixelqualität und Persistenz müssen mit `docs/INGAME_TESTS.md` geprüft werden.

## Artwork fehlt

**Alle 13 Originalgrafiken** aus `ART_ASSET_REQUESTS.md` sind noch ausstehend.
Prozedurale Platzhalter machen den Editor und Renderer lokal benutzbar; sie erfüllen noch nicht
die verlangte finale Art Direction. Der Importer behauptet keine fertigen Grafiken und kann
keine künstlerische Qualität oder jedes künstliche Schachbrettmuster automatisch erkennen.

## API-Grenzen

- Live-Overlay ist opt-in, zusätzlich zur Standardplate und derzeit nur bei ungeschützten Basen.
- Neue Overlays im Kampf werden zurückgestellt; vorhandene zulässige Widgets aktualisieren sich.
- Geheime Healthwerte werden direkt an Widgets übergeben; keine Threshold-/Threat-Arithmetik.
- Geheime Namen, Texte und Prozentinformationen werden ausgelassen.
- Quellen berichten einen SavedVariables-Ladefehler der Beta; regelmäßige externe Share-Backups nötig,
  bis die Korrektur am tatsächlichen Build bestätigt ist. Keine ausführbare SavedVariables-Bridge.
- Curved/Arc-Fill und Masks sind recherchiert, aber nicht als funktionsfähige Features präsentiert.

## Nächste Phasen

1. Ersten Kern im Forever-Client anhand der Checkliste prüfen; dokumentierte Abweichungen messen.
2. Gelieferte Grafik-Batches importieren, Transparenz/Silhouette/Lesbarkeit im Spiel polieren.
3. Zulässige vollständige Nameplate-Anbindung untersuchen, ohne die konservativen Regeln zu umgehen.
4. Echte Icons/Raidmarker, Unit-/PvP-Regeln, Klassenfarben, Medienauswahl und weitere Komponenten.
5. Gruppen/freie Anker, Drag-Skalierung, multiple Preview-Plates, mehr Typography-/Castoptionen.
6. Masken/Animationen nur über bestätigte zulässige Widget-Pfade; Performance-Qualitätsstufen.
7. Weitere Profilschritte (Löschen/Bereichsreset), vollständige DE/EN-Localization, optionale Launcher.
8. Vollständige 17-Seiten-Navigation erst mit tatsächlich implementierten Funktionen ausbauen.
9. Echte Lastmessung, Combat-/PvP-/Raid-Abnahme, visuelles Polishing und Release-Vorbereitung.

Die umfassende Definition of Done aus dem Briefing ist **noch nicht erfüllt**.

## Cloud-Umgebung

Python-Werkzeuge und die gepinnten Forschungsquellen sind installiert. Das vollständige
Installationsskript wurde in der aktuellen Maschine erfolgreich ausgeführt. `install_script`
und `start_skill` sind als Konfigurationsentwurf gespeichert; keine zusätzlichen Secrets
oder Netzwerkfreigaben waren notwendig. Der Entwurf wurde durch den Agenten nicht publiziert.
Für zukünftige Cloud-Tasks bitte die Änderungen in den Umgebungseinstellungen prüfen/speichern
und die Umgebung veröffentlichen. Wiederherstellung in einer neuen Task wurde noch nicht geprüft.
