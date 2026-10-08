# Forever Nameplates — Entwicklungsstand 0.5.0

Stand: 2026-10-08. **Erweiterter lokal geprüfter Kern, kein abgeschlossenes Premium-Release.**
Der Name „Jugo Nameplate Studio“ aus dem ursprünglichen Briefing wurde durch
**Forever Nameplates** ersetzt; technisch lautet der Addon-Ordner `ForeverNameplates`.

## Implementiert

- Vier offizielle FFXIV-Overhead-Referenzen heruntergeladen, angesehen und gehasht;
  rote Claimed-Enemy-Plate vermessen. 896×192-JPEGs, unbekannte UI-Skalierung/Version,
  Messunsicherheit ±2 Pixel und tatsächliche Grenzen dokumentiert.
- FFXIV-Layout-Entwurf mit gemessenem 236×12-Innenraum, importierter HP-Füllung/Frame/Icon,
  hellem Label-Outline und `Lv`-Präfix. Menüauswahl erst mit allen drei importierten Assets.
  Lokale Arial-Narrow-Ersatzschrift, kein erfundener Spawn-Buchstabe oder WoW-Claim-Status.
- Health/Cast verwenden passende importierte Fill-Texturen, eigene Inspector-Auswahl und Plain-Reset;
  öffentliche boolesche Texture-Ergebnisse prüfen, fehlende/abgelehnte Texturen und alte Pool-Inhalte ausblenden.
- Transparente Rahmen/Icon-Verträge und getrennt deckende RGBA-Füllungen; neun PNG-Aufträge
  (sieben Rahmen plus zwei FFXIV-Komponenten), synchronisierte Prompt-Dokumentation mit CI-Prüfung.
- Alle GUI-SetFont-Aufrufe mit obligatorischem Flags-Argument; strenger Mock reproduziert die
  gemeldete Client-Signatur. Studio-Aufbau wird erst nach vollständiger Konstruktion freigegeben;
  fehlgeschlagene Builds werden verborgen/verworfen und sind erneut öffnungsfähig.
- Minimap-Launcher mit Client-Icon, Tooltip, Linksklick Öffnen/Schließen, Rechtsklick Diagnose,
  Drag am Rand, skalierter Cursor-Geometrie, gespeicherter Position/Sichtbarkeit und `/fnp minimap`.
  Drag-OnUpdate nur während des Ziehens; Kampf stoppt Drag und blockiert GUI-/Positionseingriffe.
- Modularer Namespace, Ereignisbus, begrenztes Diagnoseprotokoll und TOC-Ladefolge.
- Forever-Kompatibilitätsschicht auf Basis der gelieferten client-spezifischen Quellen.
- Registry mit Health/Cast/Text/Panel/Target/Ornament/Artwork/Raid/Class, deklaratives validiertes Modell.
- Gepoolte ereignisbasierte Overlay-Engine; keine Veränderung geschützter Blizzard-Frames.
- Zwei quellengestützte Original-Nameplate-Strukturen für Classic 1.15.8/Dragonflight 10.2.7;
  kontrollierte Clienttextur-/Atlas-Nutzung, normale Schrift mit Shadow statt pauschaler Outline,
  vierseitige Kontur und Target-only-Image. Source-Layouts separat Undo-/Share-fähig wählbar.
- Zwölf geometrisch verschiedene Legacy-Presets, inklusive vertikaler Arena-Plate und Segment-Ornamenten.
- Eigene Galerie, Studio-Canvas, Inspector, Vierfach-Sandbox, Unit-Regeln, Profil-/Sharing-Seite und Diagnose;
  drei GUI-Skins mit konsistent wechselnden Hintergrund- und Textfarben.
- Drag-and-Drop, X/Y/Größe, Layer, Alpha, Farbe, Text, Fontgröße, vertikale/reverse Balken,
  Dekorationsform, Sperren/Sichtbarkeit, Zoom-Raster, Copy/Paste, Löschen, Undo/Redo und Elementreset.
- Komponenten-Katalog, exakte Ausrichtung, Drag-Skalierung bei festem linken oberen Rand;
  Preset-Wechsel bleiben in der Undo-Historie, Menüs sind bei langen Listen paginiert.
- 13 Preview-Zustände mit öffentlichen simulierten Identitäten, einschließlich Pet, Rare-Elite,
  freundlichem/neutralem NPC und unbekannter Identität.
- Klassen-/Reaktionsfarben, konfigurierbare Friendly/Neutral/Hostile-Palette und 12 Unit-Regeln
  für Sichtbarkeit, Alpha, Skalierung und Farbmodus; Priorität und Unknown-Fallback explizit.
- Raidmarker (vorhandene Client-Textur, kein kopiertes Asset), farbige Klassenkürzel sowie
  Level-/Klassifikationstexte; Klassenicons bleiben offen.
- Account-/Charakterprofile, Duplizieren/Umbenennen, bestätigtes Löschen/Factory-Reset,
  Default-Fallback aller betroffenen Charaktere, Datenversion 2 und explizite v0/v1-Migration ohne Änderung der alten Darstellung.
- Komprimierte, validierte FN2-Share-Codes inklusive Regeln; FN1-Import weiter unterstützt.
- Referenzgebundene statt frei erfundener Art-Prompts: Originalspiel, Patch und konkrete Ansicht
  müssen feststehen. Alle Slots ausdrücklich „Originalreferenz fehlt“; keine 1:1-Abnahme behauptet.
- Importierter Preset-Rahmen lässt sich ohne Farbtint und bekannte generische Ornamente aktivieren;
  eigene Komponenten bleiben erhalten, Locks/Combat/Undo werden berücksichtigt. Artwork-Katalog
  berücksichtigt die neuen Classic-/Dragonflight-Importmaße; bestehende Legacy-Profile bleiben erhalten.
- Galerie kennzeichnet fehlendes Artwork sichtbar als Platzhalter.
- Asset-Importer/Watcher, TGA-Konvertierung, Alpha-/Öffnungsprüfung, Checksums, Manifest,
  Erkennung fehlender/veränderter Dateien, neun aktive Nameplate-Asset-Aufträge; GUI-Header aus dem Auftrag entfernt.
- Installierbares versioniertes ZIP, gepinnte eingebettete Libraries, geprüfter Upstream-Refresh.
- GitHub-Workflow für Tests und Paket-Artefakt; laufende Änderungen werden gemäß Nutzerwunsch
  nach lokaler Prüfung direkt auf `origin/main` gepusht. Veröffentlichungspräferenz in AGENTS.md.

## Geprüft und Grenzen der Evidenz

- **143 automatisierte Tests**, Lua 5.1 via Lupa sowie Python/Pillow.
- TOCs/Lua-Syntax, voller Addon- und GUI-Ladeablauf, gültige/ungültige Presets,
  Share-Roundtrips/Malformation/Größenlimits, Profile/Migration, atomare Editoränderungen,
  Undo/Redo, Drag, Secret-Health-Forwarding, verweigerte Widgets, geschützte/verbotene Basen,
  Frame-Recycling, fremde Interface-Version, Asset-Konvertierung/Idempotenz und Datenbewahrung.
- Zusätzlich Komponentenlimits/Artwork-Verfügbarkeit, Resize/Snap/Zoom, Align-Referenzen,
  Menü-Paginierung, deaktivierte Aktionen, Vierfachvorschau und Widget-Reuse, GUI-Textfarben,
  Profil-Fallback/32er-Limit/Combat-Sperre, Confirm/Cancel, Preset-Undo und Grenzkoordinaten.
- Zusätzlich native Texturen/Crops/Blend/Fonts, öffentliche Atlasverfügbarkeit, abgelehnte
  Texture-Rückgaben und Secret-Daten, Pool-Reset, Quellgeometrie, Source-Preset-Wechsel/Undo,
  Native-Artwork-Handles, Source-Default bei Neuinstallation und unveränderte Bestandsprofile,
  versetzte Classic-Öffnung und obsolete Vertragsdimensionen.
- Zusätzlich Rahmenersatz mit Custom-Komponenten, Locks/Combat/Undo, tatsächliche Assetgrößen
  und der deaktivierte/aktive Frame-Artwork-Button.
- Zusätzlich echte FN1-Fixture aus Commit `90fc278`, FN2-Regel-Roundtrip und Malformationen,
  Migration mit Charakterbindung, Secret-Identity-Sperren, Regelpriorität, Reaktionswechsel,
  nativer Raid-Helper inklusive fehlendem/verweigertem Aufruf, Marker-Reuse, Vorschau-Skalierung sowie neue GUI-Callbacks und Undo.
- Zusätzlich obligatorische Font-Flags, fehlgeschlagener Aufbau an drei verschiedenen Seiten,
  Wiederöffnung ohne doppelte Sandbox/Registrierung sowie Minimap-Klick/Tooltip/Hide/Drag,
  UI-Skalierung, fünf Winkel, Speicherung/Migration, verspätete Minimap und Kampfsperre.
- Zusätzlich FFXIV-Vertragsöffnung/Alpha, deckender 32-Bit-Fill, obsolete Frame-Datenbewahrung,
  Filtern von Frame-/Fill-Auswahl, Plain-Reset/Undo, drei notwendige Assets, Source-Share-Roundtrip,
  fehlende/abgelehnte/Secret-Texture-Ergebnisse, Secret-Health-Forwarding und Outline-/Prefix-Pool-Reset.
- Version 0.5.0 paketiert und ZIP-Inhalte gegen aktuelle Quellen und TOC-Ladefolge geprüft.
- 37 untersuchte API-Signaturen gegen den Forever-Export geprüft.
- Library-Dateien aus gepinnten Quellen erneut heruntergeladen und per SHA-256 verifiziert.
- Benchmark in Widget-Simulation: 40 Plates, 4.000 Ereignis-Updates, keine neuen Widgetobjekte.
  Diese Messung belegt **keine** realen FPS, CPU- oder Speicherwerte im Spiel.
- Keiner dieser Tests lief in einem WoW-Client. Tatsächliche Combat-Freigaben, Nameplate-Anbindung,
  Timer-Verhalten, Pixelqualität und Persistenz müssen mit `docs/INGAME_TESTS.md` geprüft werden.

## Maßstab für die Gestaltung und offene Quellen

Ausschließlich Nameplates aus Classic, Dragonflight, GW2, SWTOR, ESO, FFXIV und Diablo IV.
Classic 1.15.8 und Dragonflight 10.2.7 wurden aus gepinnten FrameXML-Tags strukturell rekonstruiert.
Keine Fremdspiel-Grafik wurde in das Addon kopiert. Die Clientressourcen werden referenziert.
Die beiden Quellenlayouts sind noch keine vollständig abgenommenen 1:1-Replikate: tatsächliche
Texturpixel, Fonts/CVar-Scaling und zusätzliche Unit-Zustände sind im Client ungeprüft.

Vier FFXIV-Originalbilder sind jetzt tatsächlich heruntergeladen und angesehen. Die rote
Gegner-Plate ist als vermessener Entwurf vorbereitet; ihre Menüauswahl bleibt bis zum Import
von Rahmen, Fill und Icon gesperrt. Keine Originalschrift vorhanden, keine automatische
FFXIV-Claim-Erkennung oder Spawn-Letter-Nachbildung. [Originalbilder, Messungen und Abrufbefunde](docs/INTERNET_IMAGE_REFERENCES.md).
Die anderen vier Fremdspiele bleiben ohne geprüfte Vorlage deaktiviert. GW2/WoW-Wikis und
SWTOR-Suche liefern weiterhin HTTP 403; weitere Web-/RSS-Suchen ergaben keine geeignete Vorlage.
Die ergänzten Netzwerkregeln bleiben erhalten; FFXIV-CDN-Zugriff ist durch HTTP 200 bestätigt.

**Alle neun aktiven Nameplate-PNGs** stehen noch aus. Classic/Dragonflight können für den
jetzigen Strukturstand vorhandene Clientressourcen verwenden. Die Grafikaufträge verlangen
Original-Nameplate-Crops; frühere generische Themes, GUI-Header und Targetframe-/HUD-Aufträge
sind nicht Teil des neuen Auftrags. Die KI-Illustration 0.3.0 wurde in der README als frühere
Illustration archiviert. FFXIV-Maße sind Arbeitsmessungen in JPEG-Pixeln; Patch/UI-Scale unbekannt.
Für die anderen vier Fremdspiele bestehen noch vorläufige Importmaße, keine erfundene
Originalgeometrie. Pixelidentität wird nicht von technischen PNG- oder Mock-Tests behauptet.

## API-Grenzen

- Live-Overlay ist opt-in, zusätzlich zur Standardplate und derzeit nur bei ungeschützten Basen.
- Neue Overlays im Kampf werden zurückgestellt; vorhandene zulässige Widgets aktualisieren sich.
- Geheime Healthwerte werden direkt an Widgets übergeben; keine Threshold-/Threat-Arithmetik.
- Geheime Namen, Texte und Prozentinformationen werden ausgelassen. Identitätsrestriktionen
  werden vor Unit-Abfragen geprüft; keine Wiederverwendung zuvor öffentlicher Klassendaten.
- Verstecken durch Regeln betrifft nur eigene Overlays; Standardplates bleiben sichtbar.
- Quellen berichten einen SavedVariables-Ladefehler der Beta; regelmäßige externe Share-Backups nötig,
  bis die Korrektur am tatsächlichen Build bestätigt ist. Keine ausführbare SavedVariables-Bridge.
- Curved/Arc-Fill und Masks sind recherchiert, aber nicht als funktionsfähige Features präsentiert.

## Nächste Phasen

1. Die drei FFXIV-Komponenten anhand der jetzt verfügbaren Originale liefern/importieren und am Bild vergleichen.
2. GW2/SWTOR/ESO/Diablo-IV-Originalbilder finden, prüfen, vermessen und deren Nameplates nachbauen.
3. Native WoW-Layouts am Referenzbild und Forever-Client abgleichen; Font-/Scale-/Textur-Abweichungen dokumentieren.
4. Namens-/Level-/Elite-/Target-/Cast-Details ausschließlich zur Abbildung dieser Nameplates ergänzen.
5. Gelieferte Nameplate-Grafiken importieren, nebeneinander bei 100 % vergleichen und im Spiel polieren.
6. Combat-/Secret-/Lastprüfung des bestehenden Nameplate-Renderers, anschließend Release-Abnahme.

Die umfassende Definition of Done aus dem Briefing ist **noch nicht erfüllt**.

## Cloud-Umgebung

Python-Werkzeuge und die gepinnten Forschungsquellen sind installiert. Das vollständige
Installationsskript wurde in der aktuellen Maschine erfolgreich ausgeführt. `install_script`
und `start_skill` sind als Konfigurationsentwurf gespeichert; zusätzliche Netzwerkanforderungen
für die Originalbild-Recherche wurden ergänzt. Keine zusätzlichen Secrets benötigt.
Der Entwurf wurde durch den Agenten nicht publiziert.
Für zukünftige Cloud-Tasks bitte die Änderungen in den Umgebungseinstellungen prüfen/speichern
und die Umgebung veröffentlichen. Wiederherstellung in einer neuen Task wurde noch nicht geprüft.
