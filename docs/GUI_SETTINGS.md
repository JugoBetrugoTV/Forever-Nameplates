# Einstellungen per Maus — Version 0.9.0

Vor 0.9.0 waren mehrere vorhandene Funktionen nicht im Inspector auswählbar; Zahlen
benötigten Enter. Jetzt haben alle zehn Zahlenoptionen Mausregler, Plus/Minus und Mausrad.
Eine Übersicht der tatsächlich implementierten Funktionen:

| Funktion | Stelle im Studio | Bedienung |
| --- | --- | --- |
| Layout/Originalentwurf wählen | Galerie / Layout Studio → Game nameplates | Auswahl klicken; fehlende Quellen/Assets bleiben deaktiviert |
| Komponenten hinzufügen | Layout Studio → + Add component | Health/Cast/Text/Panel/Target/Ornament/Artwork/Raid/Class/Class icon/Cast icon/Interrupt shield wählen; zweite Menüseite beachten |
| Elemente wählen | Canvas / Element-Dropdown / Select previous/next | Linksklick, Dropdown; Rechtsklick zeigt die überlappenden Ebenen |
| X/Y, Breite/Höhe | Inspector | Ziehen auf Canvas/Eckgriff oder Schieberegler, +/−, Mausrad |
| Ebene, Schriftgröße, Deckkraft | Inspector | Schieberegler, +/−, Mausrad; Schriftgröße nur für Text/Klassenkürzel |
| Farbe/Alpha | Inspector → Color / opacity | Nativer ColorPicker; Abbrechen stellt Ausgangsfarbe wieder her |
| Sichtbarkeit/Sperre | Inspector → Visible / Locked | Checkboxen klicken; erst entsperren, dann bearbeiten |
| Balkenrichtung | Inspector → Vertical / Reverse | Checkboxen für Health/Cast |
| Textquelle | Inspector → Quellen-Auswahl | Name/Health/Level/Classification/Class/Cast/Custom/Custom on target |
| Bedingte Sichtbarkeit | Quellen-Auswahl anderer Komponenten | Always / Only on target / During casting; Icons haben ihre feste Klasse-/Castquelle |
| Form | Inspector → Formen-Auswahl | Rectangle/Diamond/Outline/Rune/Brackets/Segments für Panel/Target/Ornament |
| Schriftstil | Inspector → Stil-Auswahl bei Text/Class badge | Default outline oder vorhandene native WoW-/FFXIV-Labelstile; FFXIV benutzt weiterhin eine Ersatzschrift |
| Balkentextur/Artwork | Inspector → Asset-Auswahl | Plain/native Fill oder importierte Fill-Textur; Artwork: vorhandene native/importierte Grafiken |
| Ausrichten/Raster/Zoom | Layout Studio → Align element / Grid / −/+ | Auswahl und Buttons; Raster ein/aus, exakte Healthbar-/Mittelpunkt-Ausrichtung |
| Copy/Paste/Delete/Reset/Undo/Redo | Layout Studio / Regeln | Buttons; Regeln teilen die Session-History |
| Testzustände | Layout Studio / Design Sandbox / Regeln | Dropdowns mit 13 simulierten Zuständen; vier unabhängige Sandbox-Plates |
| Reaktions-/Klassenfarben | Unit Rules | Healthfarbmodus wählen; Reaktionsfarben per ColorPicker |
| Unit-Kategorien, Target/NonTarget | Unit Rules | Kategorie wählen; Enabled/Visible/Color mode/Fixed color klicken; Alpha/Scale per Mausregler |
| Profile/Kopien/Charakterbindung | Profile & Share | Profil-Dropdown, Create copy, Rename, Character profile, bestätigtes Delete/Reset |
| Share-Code | Profile & Share | Export/Import klicken; Text kopieren/einfügen |
| Live-Anwendung | Apply in game / Diagnostics → Live | Anwenden oder ein-/ausschalten; Status erklärt Fallbacks |
| Minimap-Icon | Diagnostics / Icon auf Minimap | Sichtbarkeit/Winkel per Controls; Icon direkt am Rand ziehen |
| GUI-Skin | Kopfzeile → GUI skin | Drei Skins durchklicken; Auswahl wird im Account gespeichert |

Reglerbewegungen zeigen eine **lokale Vorschau**. Beim Loslassen wird die Änderung gespeichert
und erscheint als ein Undo-Schritt. Unvollständige Drags werden bei Kontextwechsel, Schließen
oder Kampf verworfen. Tippen bleibt für genaue Zahlen möglich; Klick auf ein anderes Feld,
Button oder Element übernimmt Zahlen/eigenen Text ohne Enter. Escape verwirft die Eingabe.
Profilnamen erzeugen erst mit Create copy oder Enter eine Kopie, damit Rename/Import keine
unbeabsichtigte Kopie erstellen. Profilnamen, eigener Text und Share-Codes bleiben Texteingaben.

Assets werden außerhalb des Spiels über ArtDrop und den Importer bereitgestellt. Der Client
kann hier keine Betriebssystemdateien per Drag-and-Drop importieren; nach Import ist /reload
nötig. Nameplate-An/Aus, Klickflächen und Stacking bleiben Spieleinstellungen des Clients.
Reaktion-/Levelstile können absichtlich die normale Textfarbe ersetzen; Icons folgen ihrem
öffentlichen Klassen-/Cast-/Raidzustand auch bei gesetztem Visible. Sichtbar bedeutet aktiviert,
nicht unabhängig vom tatsächlichen Spielzustand eingeblendet.

## Was noch nicht implementiert ist

Aus dem Addonvergleich sind **Aura-/Debuff-Filter und sortierbare Iconreihen**, **Questmarker**
und **Cast-Spark/Zustandseffekte** die nächsten Kandidaten. Dafür gibt es noch keine aktiven
GUI-Einstellungen. Sie brauchen zuerst einen eigenen Forever-API-Abgleich. Threat-/Execute-
Automatik hängt zusätzlich von öffentlich nutzbaren Daten ab; geheime Werte werden nicht
rekonstruiert. Importierbare Fremdspiel-Originalgrafiken, echte Fonts und bestätigte 1:1-
Clientvergleiche bleiben ebenfalls offen. [Quellenvergleich](ADDON_COMPARISON.md).

255 lokale Tests prüfen Code und Widget-Callbacks. Die tatsächliche Mausbedienung im
Forever-Client, Combat/Taint, Farben/Pixels und SavedVariables-Neustart müssen noch anhand
der [Ingame-Checkliste](INGAME_TESTS.md) geprüft werden.
