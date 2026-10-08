# Forever Nameplates

Ein visueller Nameplate-Designer für **WoW Forever Beta 1.60.1 / Interface 16001**.
Dies ist der erweiterte Entwicklungsstand **0.4.1**, kein fertig poliertes Release.

Die gemeldeten `SetFont`-/Inspector-Fehler sind korrigiert. Der Minimap-Button öffnet/schließt
den Designer per Linksklick; Rechtsklick öffnet die Diagnose. Den Button am Minimap-Rand ziehen,
um seine Position zu speichern. `/fnp minimap` blendet ihn aus oder wieder ein. Im Kampf sind
Öffnen und Verschieben gesperrt. Die verwendeten Icon-/Randtexturen kommen aus dem Client.

## Designziel: ausschließlich Nameplates aus sieben Spielen

Gewünscht sind die **Nameplates über Units**, möglichst 1:1 wie in WoW Classic,
Dragonflight, Guild Wars 2, SWTOR, ESO, FFXIV und Diablo IV. Keine Target-Portraitframes,
Player-HUDs oder zusätzliche GUI-Artwork. Die zwölf bisherigen Presets sind Legacy-Platzhalter.

Unter **Game nameplates** im Layout-Studio stehen zwei quellengestützte Varianten bereit:
Classic **1.15.8** und Dragonflight **10.2.7**. Sie verwenden echte clientseitige Nameplate-
Texturpfade und aus FrameXML abgeleitete Maße/Anordnung. Beide sind `source draft`, noch kein
bestätigter 1:1-Pixelvergleich im Forever-Client. Die anderen fünf Spiele sind dort deaktiviert,
weil noch keine vollständige Original-Nameplate visuell geprüft wurde. Konkrete FFXIV-Bildlinks
liegen inzwischen im [Rechercheprotokoll](docs/INTERNET_IMAGE_REFERENCES.md); deren Bildhost ist noch gesperrt. Neue Installationen
starten mit der Classic-Quellenvariante; vorhandene Profile werden nicht umgestaltet. Es werden dafür keine
erfundenen Designs angeboten. [Quellen, tatsächlicher Stand und benötigter Netzwerkzugriff](docs/NAMEPLATE_REFERENCES.md).

Die aktive Grafikliste enthält sieben Nameplate-Rahmen. Classic benötigt eine versetzte
103×10-Öffnung im 128×16-Frame; Dragonflight einen 86×4-Fill. Alte Importausgaben mit
abweichenden Vertragsmaßen werden als obsolete markiert und bleiben auf der Platte erhalten.
Die Maße der anderen Spiele bleiben vorläufig. Die Rahmenersatz-Aktion im Editor betrifft
statische Artwork/Ornamente; sie gleicht alte freie Profile nicht automatisch vollständig ab.

## Was dieser Stand enthält

- Eigene Studio-Oberfläche: Preset-Galerie, Layout-Editor, Mehrfachvorschau, Einheiten-Regeln, Profile und Diagnose.
- Zwei quellengestützte WoW-Nameplate-Layouts und zwölf weiter editierbare Legacy-Platzhalter.
- Neue Health-, Cast-, Text-, Hintergrund-, Ziel-, Dekorations- und importierte Artwork-Elemente
  über den Komponenten-Katalog hinzufügen; fehlendes Artwork wird erst nach Import angeboten.
- Elemente verschieben und per Eckgriff skalieren, Koordinaten/Größe/Ebene/Deckkraft bearbeiten, Sichtbarkeit und Sperren,
  4-Pixel-Snap mit Zoom-Raster, exakte Ausrichtung an der Plate-Mitte oder Healthbar,
  Copy/Paste, Löschen, Undo/Redo einschließlich Preset-Wechsel und automatisches Speichern.
- Health- und Castbars, Name/Gesundheit/Level/Casttext, Hintergrund, Zielmarkierung,
  Ornamentik und integrierbare Artwork-Ebene; horizontale und vertikale Balken.
- Account- und Charakterprofile, Duplikate, Umbenennung, bestätigtes Löschen/Zurücksetzen,
  Auswahl über paginierte Dropdowns und validierte komprimierte Share-Codes.
- Vier gleichzeitig sichtbare Sandbox-Plates mit 13 separat wählbaren simulierten Zuständen.
- Wechselbare GUI-Skins passen Hintergrund- und Textfarben an; ColorPicker bleiben bei Profilwechsel getrennt.
- Klassen- und Reaktionsfarben sowie 12 Unit-Regelkategorien mit Sichtbarkeit, Alpha und Skalierung.
- Verschiebbare Raidmarker über die vorhandene Client-Textur und farbige Klassenkürzel;
  Level und Klassifikation als Textquellen.
- Migration alter Profile auf Schema 2; neue FN2-Exports und weiter nutzbare FN1-Imports.
- Ereignisbasiertes experimentelles Live-Overlay mit Frame-Pooling und Secret-Value-Prüfung.
- Asset-Import mit Dateiname-, Auflösungs-, Alpha- und Balkenöffnungsprüfung, TGA-Konvertierung
  und Manifest. Originalgrafiken werden vom Nutzer separat geliefert.

**Noch nicht im Spiel geprüft.** Das Live-Overlay steht über der Standard-Nameplate,
die weiterhin sichtbar bleibt. Geschützte/verbotene Frames werden übersprungen;
neue Overlays im Kampf werden bis zum Kampfende zurückgestellt. Gesundheitswerte gehen
direkt an StatusBar-Widgets; geheime Texte und Prozentwerte werden ausgelassen.
Dies ist keine vollständige Ablösung der Blizzard-Nameplates.

## Frühere Illustration

Die [KI-Illustration aus Version 0.3.0](docs/previews/forever-nameplates-0.3.0.png) ist archiviert.
Sie zeigt eine angenäherte Editor-Oberfläche und freie Platzhalter, keine originalgetreuen
Game-Nameplates und keinen tatsächlichen Screenshot. Sie ist keine Vorlage für den aktuellen Auftrag.

## Im Spiel installieren

Den Ordner **`ForeverNameplates`** nach
`World of Warcraft/_classic_beta_/Interface/AddOns/ForeverNameplates` kopieren.
Die TOC muss direkt in diesem Ordner liegen, nicht in einem weiteren Unterordner.
Oder das ZIP aus `dist/` in `Interface/AddOns` entpacken.

`/fnp` oder `/forevernameplates` öffnet das Studio.
Die experimentelle Live-Darstellung wird unter **Diagnose** eingeschaltet.
Die Oberfläche schließt im Kampf. Nameplates müssen in den Spieleinstellungen aktiviert sein.

Im Studio öffnet **+ Add component** den Elementkatalog. Versteckte/gesperrte Elemente
lassen sich im Element-Dropdown auswählen. Der goldene Eckgriff verändert die Größe bei
festem linken oberen Rand. **Align element** richtet exakt aus und ignoriert dafür Snap.
**Design Sandbox** vergleicht vier frei gewählte Zustände desselben Layouts.
**Reset element** stellt bei Original-Presets das passende Element wieder her; neu hinzugefügte
oder eigene Elemente erhalten die allgemeinen Komponenten-Defaults.

Unter **Einheiten-Regeln / Unit Rules** wählst du die Healthfarbe aus Preset, Klasse oder
Reaktion. Jede Kategorie kann Sichtbarkeit, Deckkraft, Skalierung und Farbe überschreiben.
Die Priorität lautet: Unit-Kategorie → Elite → Rare → Boss → Ziel/andere Units;
spätere passende Regeln ersetzen Sichtbarkeit, Deckkraft und Skalierung. **Inherit** behält
die zuvor gewählte Farbe. Regeln sind zunächst deaktiviert, damit alte Layouts gleich aussehen.
Bei geheimer oder fehlender Identität wird **Unknown** verwendet; unbekannter Zielstatus zählt
nicht als „Other units“. Die Vorschau simuliert diese Fälle. Sie verändert nur das eigene Overlay.
Im Komponenten-Katalog stehen **Raid marker** und **Class badge** zur Verfügung;
Klassenmarker sind farbige Kürzel, eigene Klassenicons sind noch nicht enthalten.
Neue Share-Codes beginnen mit `FN2:` und benötigen mindestens Version 0.3.0 für den Import.
Alte `FN1:`-Codes bleiben importierbar. Neue native WoW-Layouts mit ihren Asset-IDs
und Outline benötigen mindestens 0.4.0 zum Import. Profile und Layouts werden auf Datenversion 2 migriert.

Auf der Profilseite schützt eine Rückfrage vor Löschen und vollständigem Zurücksetzen.
`Default` ist nicht löschbar. Charaktere eines gelöschten Profils werden auf `Default` umgestellt.

Vor einem Client-Neustart ein Profil unter **Profile & Austausch** exportieren und den
Share-Code extern sichern. Quellen melden einen Beta-Fehler beim Laden von SavedVariables;
ob dein Build noch betroffen ist, muss im Client geprüft werden. Es werden keine Lua-Dateien
aus Share-Codes ausgeführt und keine Combat-Restriktionen umgangen.

## Lokal entwickeln und prüfen

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-dev.lock
.venv/bin/python -m pytest -q
.venv/bin/python Tools/vendor_libraries.py
.venv/bin/python Tools/import_art.py
.venv/bin/python Tools/package.py
```

Unter Windows statt `.venv/bin/python` den Pfad `.venv\Scripts\python.exe` verwenden.
Der vorhandene Cloud-Interpreter liegt unter `/workspace/forever-tools/bin/python`.
Kein WoW-Client oder Zugangsschlüssel ist für diese lokalen Tests erforderlich.

Lua-Syntax und Logik werden mit **Lua 5.1 via Lupa** geprüft. Die Widget-Simulation ist
kein Ersatz für echte Ingame-Tests, Sicherheitseinschränkungen, Pixelprüfung oder FPS-Messungen.
Sie prüft unter anderem den vollständigen TOC-Ladeablauf, Secret-Value-Forwarding, Profile,
Undo/Redo, Share-Roundtrips, GUI-Callbacks, Drag-and-Drop/-Skalierung, exakte Ausrichtung,
Mehrfachvorschau, Profil-Löschung, Menü-Paginierung und 40 gleichzeitige Overlays.

GitHub Actions führt bei Pushes auf `main` und Pull Requests automatisch Library-Prüfung,
Tests und Paketierung aus. Unter **Actions → Test and package Forever Nameplates** liegt
nach einem erfolgreichen Lauf das Artefakt **ForeverNameplates** zum Herunterladen.
Es enthält das installierbare ZIP. Der Workflow wurde lokal vorbereitet; ein erfolgreicher
lokaler Testlauf beweist noch keinen erfolgreichen GitHub-Actions-Lauf.

Forever-API-Definitionen werden in der Cloud unter `/workspace/research/forever-api/types`
für Lua Language Server eingebunden. Für einen eigenen Checkout `Atraeau/WoW-Addons`
daneben nach `../research/forever-api` klonen oder `.luarc.json` lokal anpassen.
`python Tools/audit_api.py` prüft die untersuchten Signaturen gegen diese Referenz.
Ein Language-Server-Binary ist nicht Bestandteil des Addon-ZIPs.

## Artwork und weitere Entwicklung

[ART_ASSET_REQUESTS.md](ART_ASSET_REQUESTS.md) enthält die sieben Nameplate-Grafikaufträge
in zwei Batches inklusive vollständiger Bildgenerierungs-Prompts.
PNGs einfach in `ArtDrop/` ablegen und den Importer ausführen; `--watch` überwacht den Ordner.
Im Spiel anschließend `/reload`, damit Manifest und Texturen neu geladen werden.
Die erste Version verwendet keine angeblich fertigen oder kopierten Spielgrafiken.

[PROGRESS.md](PROGRESS.md) dokumentiert geprüfte Funktionen und offene Phasen.
[docs/API_AUDIT.md](docs/API_AUDIT.md) enthält Quellen, Einschränkungen und die Rendering-Entscheidungen.
[docs/INGAME_TESTS.md](docs/INGAME_TESTS.md) ist die erforderliche Ingame-Testcheckliste.
[docs/DEPENDENCIES.md](docs/DEPENDENCIES.md) dokumentiert die eingebetteten Libraries und Lizenzen.
