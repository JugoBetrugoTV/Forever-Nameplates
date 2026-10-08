# Forever API-Audit — 2026-10-08

## Referenzbilder und importierte Fill-Texturen ab 0.5.0

Vier offizielle FFXIV-JPEGs wurden erfolgreich heruntergeladen und visuell geprüft.
[Originalansichten, SHA-256 und Arbeitsmessungen](INTERNET_IMAGE_REFERENCES.md).
FFXIV ist damit nicht mehr wegen fehlenden Bildzugriffs blockiert; fertige Assets,
Originalschrift und unbekannte Client-Patch-/UI-Skalierung bleiben offen.
Der rote Referenzentwurf setzt keine FFXIV-Claim-Erkennung oder Spawn-Buchstaben in WoW voraus.

`SimpleStatusBarAPI.SetStatusBarTexture(asset)` hat laut Forever-Dokumentation eine boolesche
Rückgabe. Apply prüft sie mit pcall und Secret-Prädikat; fehlende/abgelehnte Texture-Ergebnisse
blenden die Bar aus und zeigen keine alte gepoolte Füllung. Zulässig sind vorhandene native
Pfadressourcen oder bekannte importierte Fill-Dateien. Der Plain-Default verwendet WHITE8X8.
Importierte Gradienten liegen im Fill selbst; das FFXIV-Template verwendet weißen Tint und
Preset-Farbmodus. Secret-Health wird weiterhin direkt an StatusBar-Widgets weitergereicht.
Health/Cast-Auswahl und dekorative Artwork-Auswahl filtern unterschiedliche Asset-Rollen.

Die helle Textkontur nutzt acht verschobene FontStrings hinter dem dynamischen Text.
Sie werden einmal angelegt, wiederverwendet und bei anderem Layout verborgen. `Lv` wird nur
mit öffentlichen Zahlen/Strings zusammengesetzt, geheime oder leere Level bleiben leer.
Arial Narrow ist ausdrücklich eine vorhandene lokale Ersatzschrift, kein Originalfont-Nachweis.
Zusätzliche Drawcalls und Pixelwirkung müssen im Client geprüft werden; kein Ingame-Performancebeleg.

## Clientfehler und Minimap ab 0.4.1

Der tatsächliche Client meldete `SimpleEditBoxAPI.SetFont`: Flags sind obligatorisch,
nicht nilable. Alle drei GUI-Aufrufstellen (Label, Inspector-EditBox, Share-EditBox) übergeben
jetzt explizit `""`. Der Mock verlangt ebenfalls alle Argumente und würde die frühere Signatur ablehnen.
Der Folgefehler `inspector.visible == nil` entstand nach dem abgebrochenen Aufbau.
Die Studio-Oberfläche wird erst nach vollständigem Aufbau freigegeben; ein gescheiterter
Aufbau wird verborgen und kann ohne doppelte Sandbox/Globalregistrierung erneut gestartet werden.

Minimap-Button auf eigenem UIParent-Frame mit Minimap-Anker, Client-Icon/Texturrand,
`RegisterForClicks`, `SetHighlightTexture`, `GetCenter`, `GetWidth` und `GetEffectiveScale`.
Die zusätzlichen Widgetsignaturen sind in der Forever-Dokumentation geprüft. Vorhandene
Minimap-Scripts und Controls werden nicht verändert. OnUpdate läuft nur während Drag;
Kampfbeginn stoppt Drag, Öffnen/Positionseingriffe sind im Kampf gesperrt. Rund und `SQUARE`
unterstützt; andere Sonderformen verwenden den Kreis-Fallback. SavedVariables bleiben
Schema 2, Launcher-Metadaten ergänzen sich optional und ändern keine FN1/FN2-Layoutcodes.
Echte Positionierung/Clienttexturen und Taint müssen noch im Spiel geprüft werden.

## Quellen und Evidenz

- [Atraeau/WoW-Addons](https://github.com/Atraeau/WoW-Addons), Commit
  `d8c9be3635e756fd90284e02b5a800c796b337a0`.
  Generierte Client-Dokumentation: **Build 70170, Interface 16001, Export vom 2026-10-01**.
  [Durchsuchbare Referenz](https://atraeau.github.io/WoW-Addons/).
- [Thunderz96/forever-addon-kit](https://github.com/Thunderz96/forever-addon-kit), Commit
  `8dc297689059dd204bf8663a05aaa36d6a628b76`.
  README und BUG_REPORTS enthalten gemessene Beta-Befunde; zeitliche Unterschiede zwischen
  Befunden und API-Export beachten. Die Befunde wurden hier nicht im Client reproduziert.
- Zunächst wurde Gethe/wow-ui-source (`09b9db7948abc9b9648dedaab51eb0cf3ee67b31`)
  als allgemeine Mainline-Referenz gelesen. Nach Lieferung der Forever-Quellen ist
  die client-spezifische Referenz maßgeblich, keine Vanilla-1.12-Annahme.
- KuiNameplates wurde nur zur Orientierung angesehen. Keine Quelldatei, Grafik oder Gestaltung
  übernommen; eine ausreichende Lizenz für die Übernahme wurde nicht festgestellt.
  BlizzThreatPlates im Atraeau-Repository bestätigt Widget-Forwarding und ColorPicker-Aufrufe;
  dessen MIT-Quellcode wurde ebenfalls nicht kopiert.

Hier läuft **kein WoW-Client**. Dokumentierte Präsenz einer API beweist keine Berechtigung
für einen bestimmten Frame, einen geheimen Wert oder eine Kampfsituation. Laufzeitfehler
werden aufgefangen und als Diagnose gezählt, nicht durch alternative verbotene Wege umgangen.

## Rendering-Entscheidungen

| Bereich | Befund | Umsetzung im ersten Stand |
| --- | --- | --- |
| Nameplates | `C_NamePlate.GetNamePlateForUnit`, `GetNamePlates`, `GetNamePlateSize`, `SetNamePlateSize` existieren | Eigene ungeschützte Frames; keine Änderung globaler Plate-Größen |
| Hit-Test/Stacking | `FrameAPINamePlate` dokumentiert Combat-/Taint-Grenzen für Hit-Test-Punkte | Hit-Test, Klickbereiche und Stacking bleiben vollständig beim Client |
| Health | `UnitHealth`/`UnitHealthMax` können geheim sein | Direkt an `SetMinMaxValues`/`SetValue`; keine Lua-Arithmetik mit Geheimwerten |
| Health-Text | Prozentrechnung ist bei Geheimwerten unzulässig | Nur öffentliche Zahlen werden formatiert; sonst „—“ |
| Casts | `UnitCastingDuration`, `UnitChannelDuration`, `SetTimerDuration` vorhanden | Duration-Objekte direkt an den Timer; keine eigene Echtzeit-Timingrechnung |
| Text | Unit-Namen und weitere Werte können geheim sein | Vor Bedingungen/Formatierung prüfen; geheime Werte auslassen |
| Texture | Farbe, Rotation, Texture-Pfade vorhanden | Originale prozedurale Silhouetten; geprüfte lokale TGA-Artwork-Dateien |
| MaskTexture | `CreateMaskTexture`/Mask-APIs vorhanden | Für spätere validierte Formen vorgesehen; keine Kreis-/Arc-Füllung behauptet |
| AnimationGroups | Frame-Animationen sind dokumentiert | Im ersten Stand keine automatischen Gameplay-Effekte oder Daueranimationen |
| Combat | Frame-Schutz und Secret Values werden dynamisch geprüft | Editor pausiert; neue Live-Frames werden außerhalb des Kampfes erstellt |
| Unit-Identität | `UnitClassBase`, `UnitClassification`, `UnitReaction`, `UnitIsPlayer`, `UnitPlayerControlled` dokumentiert | Nur öffentliche normalisierte Rückgaben; kein Identitätscache, Unknown-Fallback |
| Identitätsrestriktion | `C_Secrets.ShouldUnitIdentityBeSecret(unit)` dokumentiert | Bei öffentlichem `true` keine Name-/Level-/Klassen-/Reaktions-/Zielabfragen; ansonsten jede Rückgabe einzeln prüfen |
| Raidmarker | `GetRaidTargetIndex(target)` und `RAID_TARGET_UPDATE` dokumentiert | Index 1–8; lokales Client-Texturatlas über exportierten UI-Helper `SetRaidTargetIconTexture`; Marker fehlt bei geheimer Rückgabe |
| Regelaktualisierung | `UNIT_FACTION`, `UNIT_CLASSIFICATION_CHANGED`, Target-/Raid-Events dokumentiert | Ereignisbasierte Farbe/Sichtbarkeit/Skalierung nur am eigenen ungeschützten Overlay |
| Threat/Auras | Exakte Werte und Aura-Zugriffe können gesperrt sein | Keine eigene Threat-Rechnung oder Aura-/Quest-Erkennung implementiert |
| SavedVariables | Kit meldet Schreiben ohne Laden bei Client-Neustart | Reguläre SavedVariables plus manueller Share-Code-Backup; kein ausführbarer Daten-Bridge-Code |

## Derzeitige Grenzen

Das Overlay ist bewusst eine zusätzliche Darstellung über der Standardplate. Ein vollständiger
Blizzard-Renderer-Ersatz ist vor einem konkreten Client-Audit nicht implementiert. Auch ungeschützte
Kinder eines geschützten Elternframes werden abgelehnt. Das kann einzelne oder sämtliche Liveplates
auf einem konkreten Build ausschließen; die Diagnose zählt abgelehnte Basen.

Bereits erstellte zulässige Frames aktualisieren sich eventbasiert im Kampf. Neue Sichtbarkeit
im Kampf wird bis `PLAYER_REGEN_ENABLED` zurückgestellt. Die erstmalige Discovery ist auf 200
Unit-Tokens begrenzt und läuft nicht in einem `OnUpdate`-Loop. Der Editor benutzt `OnUpdate`
ausschließlich während eines aktiven Vorschau-Drags.

Secret-Prädikate werden vor jeder Auswertung geprüft. Secret-Health wird nur im Widget-Forwarding
verwendet; an Fehlerbehandlung werden keine Secret-Werte oder vertraulichen Dumps übergeben.
Unbekannte Events werden pro Registrierung mit `pcall` erkannt und protokolliert.

Die GUI unterstützt Layout-Elemente relativ zur gemeinsamen Plate-Mitte, exakte Ausrichtung,
Drag-Skalierung und vier parallel angezeigte simulierte Units. `SimpleFrameAPI.SetClipsChildren`
begrenzt Canvas und Sandbox-Karten; `SimpleButtonAPI.IsEnabled` sichert deaktivierte Menüeinträge.
Beide Methoden sind in der Forever-Referenz dokumentiert und im Widget-Mock abgebildet.
Freie Ankergruppen,
Maskenformen, grafische Klassenicons, Questmarker, Casticons, Threat,
vollständige Localization, Animationen und die restlichen Spezialseiten folgen separat.

## Regeln und Marker ab 0.3.0

`UnitClassBase` liefert den Klassentoken im ersten Rückgabewert; damit ist kein ungeprüfter
Mehrfach-Rückgabewert von `UnitClass` nötig. Reaktion und Raidindex werden auf Ganzzahlen
1–8 begrenzt. Spieler-/Kontrollflags müssen öffentlich und boolesch sein. Fehlende Kontrollinformation
bei Nicht-Spielern führt zu Unknown statt zur ungesicherten Unterscheidung NPC/Pet.
Ein unbekannter Zielstatus aktiviert keine NonTarget-Regel. Farben fallen auf das Preset zurück,
wenn die für den gewünschten Modus nötigen öffentlichen Angaben fehlen.

Die zwölf Regeln liegen im versionierten Profil, mit Priorität Kategorie → Elite → Rare → Boss
→ Ziel/andere Units. Regeln ersetzen nur eigene Overlay-Eigenschaften. Die Datenmigration fügt
standardmäßig deaktivierte Regeln hinzu; FN1-Import bleibt erhalten, FN2 speichert die neuen Felder.
Die Rule-Vorschau und Editor-Zoom multiplizieren dieselbe Skalierung wie der Renderer.

Raidmarker referenzieren `Interface\\TargetingFrame\\UI-RaidTargetingIcons` im installierten Client.
Es wird keine Spielgrafik in dieses Repository kopiert. `SetRaidTargetIconTexture` ist im
Forever-Kit-Export `data/forever_api.json` enthalten, besitzt in der generierten API-Dokumentation
aber keine eigenständige Signatur. Der Renderer delegiert den Ausschnitt an diesen UI-Helper;
fehlt er oder wird der Aufruf abgelehnt, bleibt der Marker ausgeblendet. Die allgemeine Mainline-
FrameXML-Referenz benutzt ein 4×4-Sprite-Raster, keinen 4×2-Atlas; dieses Raster wird ausschließlich
im Mock simuliert, nicht im Addon festgeschrieben. Der Dateipfad, tatsächliche Helper-Implementierung,
Orientierung und alle acht Ausschnitte gehören zur Ingame-Prüfung. Klassenmarker sind
derzeit prozedurale, farbige Textkürzel; eigenständige Klassenicon-Artwork-Aufträge folgen erst mit
einer festgelegten grafischen Komponente. Die vorhandenen 13 Grafikaufträge bleiben unverändert.

## Ingame noch zu klären

1. Sind öffentliche Nameplate-Basen in Build 70170 tatsächlich ungeschützt, inklusive Vererbung?
2. Akzeptieren StatusBar-Widgets Secret-Health auch in Dungeons/PvP mit tainted Addon-Kontext?
3. Liefern Casting-/Channel-Duration-APIs zulässige Objekte für Nameplate-Units in allen Situationen?
4. Welche Masken und Effekte erfüllen Combat- und Secret-Regeln unter Last?
5. Lädt der aktuelle Forever-Build SavedVariables inzwischen wieder korrekt?
6. Ist der Raid-Atlaspfad korrekt und werden alle acht Marker ohne Verschiebung angezeigt?
7. Bleiben öffentliche Klassen-/Reaktionsangaben in Solo, Dungeon, Raid und PvP nutzbar?
8. Sind Regeländerungen von Alpha, Scale und Sichtbarkeit an vorhandenen Overlays im Kampf zulässig?
9. Entstehen Blocked-Action-/Taint-Fehler oder Interaktionen mit anderen Nameplate-Addons?

Abweichungen zu diesen Quellen sind bislang **nicht gemessen**, da kein Client vorhanden ist.

## Nameplate-only-Quellenlayouts ab 0.4.0

Die Original-Nameplate-Struktur von Classic 1.15.8 und Dragonflight 10.2.7 wurde gesondert aus
historischen FrameXML-Tags abgeleitet; sie ersetzt nicht die Forever-API als Laufzeitreferenz.
Die Quellen dienen ausschließlich dem Look der Nameplates, nicht Targetframes/HUDs. Runtime-
Aufrufe verwenden weiterhin die Forever-Definitionen. Neue recherchierte Methoden sind
SetBlendMode, SetAtlas, GetAtlasInfo sowie FontString SetShadowColor/SetShadowOffset.
Native/Owned-Texture-Crops und Blend-Modi werden beim Pool-Reuse zurückgesetzt. SetTexture-
Ergebnis muss öffentlich `true` sein; fehlgeschlagene/abgelehnte Image-Texturen bleiben unsichtbar.
Native Atlasverfügbarkeit wird anhand öffentlicher GetAtlasInfo-Daten geprüft; der Aufruf darf
keine heimliche Alternative für blockierte Geheimwerte verwenden.

[Quellen, genaue Geometrie und Einschränkungen](NAMEPLATE_REFERENCES.md). Die übrigen vier
Fremdspiele haben noch keine visuell geprüfte Nameplate-Vorlage; es wird kein Original-Look behauptet.
