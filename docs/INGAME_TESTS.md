# Ingame-Testcheckliste — noch nicht ausgeführt

Für jedes Ergebnis Client-Version/Build, Charakter, Gebiet, Addon-Liste und Fehlertext
notieren. Zuerst ohne weitere Nameplate-Addons testen, danach mit konkurrierenden Addons.
Die lokalen Widget-Tests begründen keinen Haken in dieser Liste.

## Neue Funktionen in 0.10.0

- [ ] Suchfeld: deutsche/englische Begriffe, Großbuchstaben/Umlaute, Pagination; Treffer öffnet richtige Seite und markiert Control.
- [ ] Tooltips auf Reglern/Buttons zeigen Hilfe, Wertebereich und Sperrhinweis; Markierung verschwindet.
- [ ] Galerie/Regeln/Profile/Diagnose/Sandbox/Komponenten/Suche erst beim Besuch gebaut; erneutes Öffnen ohne doppelte Controls, außerhalb Kampf.
- [ ] Icon mit RIGHT-Bezug an Healthbar verankern, Snap klicken; bei Barbreite/Position bleibt der Abstand erhalten. Alle neun Punkte, Ankerketten, Zoom/Drag/Resize prüfen.
- [ ] Bezug wechseln/ablösen erhält Position; Bezug löschen löst abhängige Elemente; Locks/Undo/Redo und Zyklusablehnung prüfen.
- [ ] Aura-Komponente hinzufügen: Buff/Debuff, eigene Auren, Sortierung/Richtung; tatsächliche AuraData-Felder und Enum-Verfügbarkeit notieren.
- [ ] HARMFUL|PLAYER und HELPFUL|PLAYER testen; Secret-/leere Metadaten verbergen betroffene Icons, Healthbar bleibt sichtbar.
- [ ] Limit/Spalten/Größe/Abstand, Include/Exclude-Spell-IDs und Stackcounts prüfen; unbekannte IDs bei Listen ausgelassen.
- [ ] Cooldownswipe mittels Duration-Objekt, Ablauf/Entfernung, Profilwechsel und Combat-Pool-Reuse: keine alten Icons/Counts/Cooldowns.
- [ ] Komponentenseiten-Regler zeigen Vorschau während Drag; Loslassen speichert einmal, Kontextwechsel/Escape/Schließen/Kampf verwerfen unvollständige Drags.
- [ ] Normale Casts, Channels, öffentlich nicht unterbrechbare Casts mit drei Farben; unbekannter Interruptstatus nutzt Normal/Channel.
- [ ] Spark folgt Fill-Kante bei Horizontal/Vertikal/Reverse; Stop/Interrupt/Profilwechsel und fehlende Textur/Anker ohne stehende Sparks.
- [ ] Castgebundene Aura-/Icon-/Textkomponenten bleiben bei UNIT_AURA/UNIT_HEALTH korrekt bedingt sichtbar.
- [ ] Health-/Cast-/Aura-Teilupdates, Name-/Identitätswechsel und Fallback prüfen: kein erneutes Unterdrücken von Blizzard nach Healthfehler.
- [ ] FN1/FN2 importieren, neue Features als FN3 exportieren/importieren; SavedVariables 2→3 bei /reload und kaltem Neustart.
- [ ] 40+ Plates: echte CPU/FPS/Öffnungsdauer und Taint erfassen; lokale Widgetzahlen sind kein Performancebeweis.

## Laden und Studio

- [ ] Beide TOCs werden auf Interface 16001 erkannt; keine fehlenden Dateien/Libraries.
- [ ] Login, `/reload`, Zonenwechsel und Neustart erzeugen keine Lua-Fehler.
- [ ] `/fnp`, `/forevernameplates`, Escape und Schließen funktionieren.
- [ ] Inspector und Profile-Sharebox öffnen ohne `SetFont`-Fehler; Preset-Wechsel ohne `visible`-Folgefehler.
- [ ] Minimap-Icon sichtbar: Linksklick öffnet/schließt, Rechtsklick öffnet Diagnose; Tooltip korrekt.
- [ ] Icon am Rand ziehen, UI-/Minimap-Scale und runde/quadratische Minimap prüfen; kein Drag-OnUpdate bleibt aktiv.
- [ ] `/fnp minimap` versteckt und stellt das Icon wieder her; Position und Sichtbarkeit nach `/reload` erhalten.
- [ ] Kampf startet während Icon-Drag: Drag stoppt, Designer bleibt geschlossen, keine geschützte Aktion.
- [ ] Studio passt auf 1920×1080 und kleinere Displays mit verschiedenen UI-Skalierungen.
- [ ] Fenster lässt sich verschieben; Dark RPG, Light Fantasy und Modern Studio sind lesbar.
- [ ] Alle zwölf Galeriekarten sind erkennbar und übernehmen das richtige Preset.
- [ ] Alle 13 Sandbox-Zustände stellen Health-, Cast- und Zielzustand korrekt dar.
- [ ] Vier Sandbox-Plates gleichzeitig: individuell wählbare Zustände, gleiches aktives Layout.

## Editor

- [ ] Alle Zahlenfelder per Slider, +/− und Mausrad bedienen; Zahlen/Deckkraft bleiben innerhalb ihrer Grenzen.
- [ ] Slider zeigt Vorschau, speichert erst beim Loslassen einen Undo-Schritt; Release auch außerhalb des Tracks prüfen.
- [ ] Drag bei Seiten-/Elementwechsel, Schließen oder Kampf abbrechen: gespeicherte Werte unverändert.
- [ ] Getippte Zahlen/Text durch Klick auf anderes Element/Button übernehmen; Enter nicht doppelt, Escape verwirft.
- [ ] Rechtsklick auf Überlappung zeigt alle betroffenen Ebenen; Auswahl mit Zoom/UI-Scale und gesperrten Teilen prüfen.
- [ ] Schriftstile/native Artwork-Auswahl, ziel-/castbedingte Sichtbarkeit, gesperrte Controls und Skin-Persistenz prüfen.
- [ ] Diagnose: Minimap-Sichtbarkeit/-Winkel per Maus speichern; Profile: Create copy ohne Enter nutzbar.
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

## Quellengestützte Spiel-Nameplates

- [ ] Game nameplates: Classic 1.15.8 / DF 10.2.7 übernehmen, Undo/Redo und Share-Export prüfen.
- [ ] Client besitzt Nameplate-Border/BarFill; tatsächliche Pixel gegen die Originalversion vergleichen.
- [ ] Classic-Level: niedriges/gleiches/hohes öffentliches Level verwendet die clientseitige Schwierigkeitsfarbe; nach eigenem Level-up aktualisiert sie sich ohne Layoutwechsel.
- [ ] Unbekannt hohes Level zeigt das native Schädelicon rechts; fehlende Textur zeigt „??“. Geheimes/fehlendes Level zeigt weder Zahl noch Schädel; Wechsel zum normalen Level und zu anderen Layouts hinterlässt kein Icon. Größe/Crop des Schädels mit Original vergleichen.
- [ ] Classic-Border-Crop 0..1/0.5..1, Level rechts und Raidmarker links stimmen bei Scale=1.
- [ ] DF: 86×4 Health, 86×8 Cast, Kontur, Target-Highlight und Raidmarker links vergleichen.
- [ ] Cast-Hintergrundatlas verfügbar oder unsichtbar; kein Atlas-Sheet statt des gewünschten Ausschnitts.
- [ ] Lateinische Friz-Schrift, Shadow, Fontgröße und CVar/UI-Scale gegen Original messen.
- [ ] Ressourcenwechsel zwischen Source-/Legacy-/Custom-Profilen hinterlässt keine alten Crops oder Blend-Modi.
- [ ] Erst nach direktem visuellem Vergleich 1:1-Abnahme dokumentieren; bisher keine Abnahme.

## Unit-Regeln und Marker

- [ ] Preset-/Klassen-/Reaktionsfarben stimmen bei Spieler, NPC und Pet; Unbekanntes fällt zurück.
- [ ] Friendly/Neutral/Hostile-Palette bleibt nach Undo, Profilwechsel und Share-Import erhalten.
- [ ] Alle 12 Kategorien und Priorität Kategorie → Klassifikation → Ziel prüfen, inklusive Rare-Elite.
- [ ] Sichtbarkeit/Alpha/Scale stimmen in Rule-Vorschau, Studio mit Zoom und Vierfach-Sandbox.
- [ ] Versteckte angewandte Plates zeigen auch keine Blizzard-Visuals; Zustandswechsel/Off stellt Sichtbarkeit wieder her.
- [ ] Geheime Identität und Zielstatus lösen keine NPC-/NonTarget-Fehlklassifikation aus.
- [ ] Reaktions-/Klassifikations-/Zielwechsel im Kampf aktualisieren zulässige bestehende Overlays.
- [ ] Alle acht Raidmarker: tatsächlicher Atlaspfad, Farbe, Ausschnitt, Rotation und Markerentfernung.
- [ ] Klassenkürzel und Level-/Klassifikationstexte lassen sich positionieren und skalieren.
- [ ] + Add component → Class icon: öffentlicher Spieler zeigt passenden nativen Klassenatlas; NPC, geheime/fehlende Klasse und fehlender Atlas zeigen kein altes Icon. Position/Größe/Farbe/Alpha prüfen.
- [ ] + Add component → Cast icon: Cast und Channel zeigen korrektes Icon; Start/Stop/Delay/Interrupt, fehlende/verweigerte Duration, deaktivierte Bar und Elementreihenfolge hinterlassen kein Icon.
- [ ] Geheimer Castname mit öffentlichem Icon zeigt Icon und keinen Text; geheimes Icon zeigt keine Ersatzgrafik. Öffentliche FileID und echte Texture-Pixel im Forever-Client prüfen.
- [ ] Iconlayout speichern, FN2 exportieren/importieren, Undo/Redo, Off/Apply und Pool-/Combat-Wechsel prüfen. Alte Profile behalten ihre bisherigen Elemente.
- [ ] + Add component → Interrupt shield: nicht unterbrechbarer Cast/Channel zeigt nativen Schild; Unterbrechbarkeitswechsel aktualisieren ihn ohne Health-Event. Secret/nil/fehlender Atlas zeigt keinen Schild.
- [ ] Cast läuft vorwärts (ElapsedTime), Channel rückwärts (RemainingTime), auch nach Cast-/Channel-Wechsel, mit Vertical/Reverse. Fehlende Enums blenden Channel samt gebundenen Icons/Text aus.
- [ ] Target-/NonTarget-Regeln, Zielmarker und Raidmarker reagieren weiterhin auf relevante globale Events; reine Healthlayouts bleiben unverändert. Level-up aktualisiert Classic-Schwierigkeitsfarben.
- [ ] Shield-Position/Größe/Alpha, Standalone-Modus, deaktivierte Castbar, Undo/FN2 und Pool-Reuse prüfen. Neue Shieldcodes benötigen 0.8.0.
- [ ] CPU/Speicher bei 40+ Plates vergleichen; bedarfsgerechte Abfragen sind lokal gezählt, noch kein Client-Performancebeleg.
- [ ] Recycelte Plates behalten keine Klassenfarbe oder Marker der vorherigen Unit.

## Live-Rendering und Einschränkungen

- [ ] Im Kampf: Token wechselt auf neue Basis; alte Plate verschwindet, Erstaufbau bleibt Blizzard bis Kampfende.
- [ ] Recycelte bekannte Basis im Kampf übernimmt neue Unit ohne Text-/Alpha-Reste der alten Unit.
- [ ] Blizzard-UnitFrame Show/Hide/SetShown: eigene Plate folgt sofort, Health-Update blendet keine versteckte Plate ein.
- [ ] Öffentliche Blizzard-Fades und Regel-Alpha multiplizieren sich; bei Off bleibt letzte Blizzard-Alpha korrekt.
- [ ] UnitFrame-Poolwechsel vor nächstem ADDED: neue Blizzard-Alpha wird nicht von alter View unterdrückt.
- [ ] Nameplate301+ mit fehlenden/gesperrten öffentlichen Frame-Unit-Feldern wird nach Kampfende wieder erfasst.
- [ ] Fehlender Healthbar-Aufbau erhält begrenzte Retries; Entfernung/Off verhindert spätes Wiederanheften.
- [ ] Geheime IsShown-/Alpha-Ergebnisse und verweigerte Hooks erzeugen sauberen Fallback ohne Lua-/Taint-Fehler.

- [ ] Update von ≤0.5.0 auf 0.8.0 + `/reload`: Bestandsprofile unverändert, Live einmalig automatisch aktiviert.
- [ ] Update von 0.6.0: ein gespeichertes Off bleibt abgeschaltet.
- [ ] `/fnp apply` und Studio-Anwenden-Button ändern die sichtbare Plate direkt; Healthbar-Breite/X ändern und vergleichen.
- [ ] `/fnp off` und erneutes `/reload` bleiben abgeschaltet; Apply aktiviert wieder.
- [ ] Diagnose aktiviert nur auf der erwarteten Forever-Schnittstelle die Anwendung.
- [ ] Eigene Plate sitzt an der Blizzard-Healthbar; nur eine Darstellung sichtbar, Klickfläche/Stacking weiter bedienbar.
- [ ] `/fnp status`: Version 0.8.0, Applied/Pending/Fallback und konkrete Ablehnungsgründe stimmen.
- [ ] Blizzard-Alpha-Updates bei Zielwechsel/Entfernung/Fading erzeugen keine doppelte Plate.
- [ ] UnitFrame wird vor/nach eigenem ADDED-Handler erstellt: begrenzter Retry hängt korrekt an.
- [ ] UnitFrame unabhängig von Basis recycelt: keine unsichtbare Folge-Unit oder alte eigene Plate.
- [ ] Bei fehlendem Health-Fill/verweigerter Weitergabe/renderingbedingtem Fehler ist Blizzard wieder sichtbar.
- [ ] Neu eingeschränkte Alpha/Frames erzeugen Diagnose und erlaubte Wiederherstellung, keine Schutzumgehung.
- [ ] Öffentliche, nicht geschützte Basen akzeptieren eigene Kinderframes.
- [ ] Geschützte/verbotene Basen werden übersprungen, ohne Blocked-Action-/Taint-Fehler.
- [ ] Nameplate hinzufügen/entfernen/recyceln hinterlässt keine falschen Units oder Texte.
- [ ] Bereits erstellte Healthbars reagieren auf öffentliche und geheime Werte.
- [ ] Gesundheitsprozente erscheinen nur bei öffentlichen Zahlen; geheime Texte fehlen.
- [ ] Zielmarkierungen wechseln korrekt, auch während Kampf und Zielverlust.
- [ ] Casting- und Channel-Duration-Widgets starten/stoppen/unterbrechen korrekt.
- [ ] Dragonflight-Cast-Hintergrund/Text fehlen ohne sichtbaren Castbalken; bei verweigerter Timer-Weitergabe keine dekorative Restanzeige.
- [ ] Castbar deaktivieren, Elemente umordnen und altes gespeichertes DF-Layout laden: gleiche gekoppelte Sichtbarkeit.
- [ ] Erste Widget-Erstellung im Kampf wartet bis Kampfende; vorbereitete zulässige Views recyceln ohne neue Widgets.
- [ ] Toggle aus blendet eigene Plates aus und stellt die letzte öffentliche Blizzard-Alpha wieder her.
- [ ] Solo, Dungeon, Raid, Arena, freundliche Spieler und Namensbeschränkungen prüfen.

## Profile und Beta-Persistenz

- [ ] Accountprofile erstellen, wählen und umbenennen; Default duplizieren.
- [ ] Löschen und Factory-Reset zeigen eine Bestätigung; Abbrechen bewahrt Daten.
- [ ] Gelöschtes Profil setzt alle betroffenen Charaktere auf Default; Default ist nicht löschbar.
- [ ] Charakterbindung auf zwei Charakteren und zwei Accountprofilen prüfen.
- [ ] FN2-Export/Import für jedes Preset inklusive Regeln; alte FN1-Codes importieren; beschädigte/fremde Codes werden abgelehnt.
- [ ] Normales Logout und kalter Neustart: Daten wirklich vorhanden oder Beta-Ladefehler?
- [ ] Bei Beta-Ladefehler: extern gesicherter Code stellt Layout manuell wieder her.
- [ ] `/reload`-Persistenz getrennt von kaltem Neustart dokumentieren.
- [ ] Migration v0/v1 nach v2 und unbekannte neuere Datenversion: kein stiller Datenverlust.

## Artwork und Last

- [ ] FFXIV-Auswahl gesperrt bei fehlendem Rahmen/Fill/Icon; nach Import aller drei und `/reload` anwählbar.
- [ ] FFXIV-Entwurf am roten Originalbild bei Quellmaßstab prüfen: Balken, Icon, Labelkontur und `Lv`-Präfix.
- [ ] Ersatzschrift, fehlender Spawn-Buchstabe und unbekannte Original-UI-Skalierung separat dokumentieren.
- [ ] HP-Füllung übernimmt ihre eigenen Farben ohne Tint; Color-Regeln ändern sie nur nach Nutzerkonfiguration.
- [ ] Health/Cast-Fülltexturen wechseln, auf Plain fill zurückstellen, Undo/Profilwechsel/Widget-Reuse prüfen.
- [ ] Fehlender/abgelehnter StatusBar-Texture-Aufruf zeigt keinen alten Fill und keine erfundene Originaltextur.
- [ ] Importierte TGAs haben echte Transparenz, freie Healthöffnung und keine Artefakte.
- [ ] Jede Karte besitzt eine erkennbare eigenständige Silhouette bei nativer Größe.
- [ ] Importierter Rahmen ohne Farbtint: Preset-Ornamente entfernen, Custom-Elemente bewahren, Undo/Locks prüfen.
- [ ] Classic-Frame 128×16/versetzte 103×10-Öffnung und DF-Frame 128×32 in korrekten Importmaßen anzeigen.
- [ ] Originalvorlage bei 100 % mit Silhouette, Text, Icons, Material und Zustand vergleichen.
- [ ] Fehlende Art-Dateien behalten die prozeduralen Platzhalter; keine fehlenden Texture-Pfade.
- [ ] 40+ sichtbare Plates: Speicher, FPS und CPU im Client messen, nicht aus Mock-Zeiten ableiten.
- [ ] Häufiges Ein-/Ausblenden, Profilwechsel, Kampfwechsel und Zone wechseln unter Last.
- [ ] Plater/Kui/NeatPlates/ThreatPlates: Diagnosehinweis, Überlappung und Fehlerfreiheit prüfen.
