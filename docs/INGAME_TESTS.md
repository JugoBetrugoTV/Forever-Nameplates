# Ingame-Testcheckliste — noch nicht ausgeführt

Für jedes Ergebnis Client-Version/Build, Charakter, Gebiet, Addon-Liste und Fehlertext
notieren. Zuerst ohne weitere Nameplate-Addons testen, danach mit konkurrierenden Addons.
Die lokalen Widget-Tests begründen keinen Haken in dieser Liste.

## Laden und Studio

- [ ] Beide TOCs werden auf Interface 16001 erkannt; keine fehlenden Dateien/Libraries.
- [ ] Login, `/reload`, Zonenwechsel und Neustart erzeugen keine Lua-Fehler.
- [ ] `/fnp`, `/forevernameplates`, Escape und Schließen funktionieren.
- [ ] Studio passt auf 1920×1080 und kleinere Displays mit verschiedenen UI-Skalierungen.
- [ ] Fenster lässt sich verschieben; Dark RPG, Light Fantasy und Modern Studio sind lesbar.
- [ ] Alle zwölf Galeriekarten sind erkennbar und übernehmen das richtige Preset.
- [ ] Alle acht Sandbox-Zustände stellen Health-, Cast- und Zielzustand korrekt dar.
- [ ] Vier Sandbox-Plates gleichzeitig: individuell wählbare Zustände, gleiches aktives Layout.

## Editor

- [ ] Elementwahl auf Canvas und vorheriges/nächstes Element stimmen überein.
- [ ] Drag-Verschiebung berücksichtigt UI-Scale und Editor-Zoom.
- [ ] Eckgriff skaliert bei festem linken oberen Rand; Snap/Zoom und Abbruch korrekt.
- [ ] Komponenten-Katalog fügt alle verfügbaren Typen hinzu; fehlendes Artwork ist deaktiviert.
- [ ] Versteckte/gesperrte Elemente über Dropdown wählbar; lange Listen paginieren korrekt.
- [ ] Ausrichtung links/rechts/oben/unten an Healthbar; Zentrierung auf Plate trotz aktivem Snap exakt.
- [ ] 4-Pixel-Snap und freie Positionierung, einschließlich negativer Koordinaten.
- [ ] X/Y/Breite/Höhe/Ebene/Alpha und Textgröße werden unmittelbar wirksam.
- [ ] Ungültige Werte verändern das Layout nicht.
- [ ] ColorPicker ändert Farbe/Alpha; Abbrechen stellt die Ausgangsfarbe wieder her.
- [ ] Unsichtbare Elemente lassen sich über den Inspector wieder einschalten.
- [ ] Sperre verhindert Drag und Eigenschaftsänderungen; Entsperren funktioniert.
- [ ] Undo/Redo über mindestens zehn Schritte; neue Änderung verwirft den Redo-Zweig.
- [ ] Preset-Wechsel lässt sich rückgängig machen; gültige Elementauswahl bleibt erhalten.
- [ ] Copy/Paste erzeugt unabhängige IDs; Löschen und Element-Reset funktionieren.
- [ ] Kein Datenverlust bei Kampfbeginn während Drag, Textbearbeitung oder ColorPicker.

## Live-Rendering und Einschränkungen

- [ ] Diagnose aktiviert nur auf der erwarteten Forever-Schnittstelle das Overlay.
- [ ] Standardnameplates/Klickflächen bleiben bedienbar; zusätzlicher Overlay-Abstand sinnvoll.
- [ ] Öffentliche, nicht geschützte Basen akzeptieren eigene Kinderframes.
- [ ] Geschützte/verbotene Basen werden übersprungen, ohne Blocked-Action-/Taint-Fehler.
- [ ] Nameplate hinzufügen/entfernen/recyceln hinterlässt keine falschen Units oder Texte.
- [ ] Bereits erstellte Healthbars reagieren auf öffentliche und geheime Werte.
- [ ] Gesundheitsprozente erscheinen nur bei öffentlichen Zahlen; geheime Texte fehlen.
- [ ] Zielmarkierungen wechseln korrekt, auch während Kampf und Zielverlust.
- [ ] Casting- und Channel-Duration-Widgets starten/stoppen/unterbrechen korrekt.
- [ ] Neue Nameplates im Kampf erhalten erst nach Kampfende ein eigenes Overlay.
- [ ] Toggle aus blendet nur eigene Overlays aus; Standardframes bleiben unverändert.
- [ ] Solo, Dungeon, Raid, Arena, freundliche Spieler und Namensbeschränkungen prüfen.

## Profile und Beta-Persistenz

- [ ] Accountprofile erstellen, wählen und umbenennen; Default duplizieren.
- [ ] Löschen und Factory-Reset zeigen eine Bestätigung; Abbrechen bewahrt Daten.
- [ ] Gelöschtes Profil setzt alle betroffenen Charaktere auf Default; Default ist nicht löschbar.
- [ ] Charakterbindung auf zwei Charakteren und zwei Accountprofilen prüfen.
- [ ] Export/Import für jedes Preset; beschädigte/fremde Codes werden abgelehnt.
- [ ] Normales Logout und kalter Neustart: Daten wirklich vorhanden oder Beta-Ladefehler?
- [ ] Bei Beta-Ladefehler: extern gesicherter Code stellt Layout manuell wieder her.
- [ ] `/reload`-Persistenz getrennt von kaltem Neustart dokumentieren.
- [ ] Migration v0 und unbekannte neuere Datenversion: kein stiller Datenverlust.

## Artwork und Last

- [ ] Importierte TGAs haben echte Transparenz, freie Healthöffnung und keine Artefakte.
- [ ] Jede Karte besitzt eine erkennbare eigenständige Silhouette bei nativer Größe.
- [ ] Fehlende Art-Dateien behalten die prozeduralen Platzhalter; keine fehlenden Texture-Pfade.
- [ ] 40+ sichtbare Plates: Speicher, FPS und CPU im Client messen, nicht aus Mock-Zeiten ableiten.
- [ ] Häufiges Ein-/Ausblenden, Profilwechsel, Kampfwechsel und Zone wechseln unter Last.
- [ ] Plater/Kui/NeatPlates/ThreatPlates: Diagnosehinweis, Überlappung und Fehlerfreiheit prüfen.
