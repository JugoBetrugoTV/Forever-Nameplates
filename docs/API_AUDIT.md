# Forever API-Audit — 2026-10-09

## Cast-Dekorationen ab 0.6.2

Codeprüfung und zwei zunächst scheiternde lokale Tests belegten, dass der native Dragonflight-
Cast-Hintergrund in inaktiven Zuständen sichtbar blieb und castgebundener Text unabhängig
von der Timer-Weitergabe angezeigt wurde. Ein zweiter Durchlauf bindet Casttext und native
Cast-Hintergründe an mindestens eine tatsächlich angezeigte Castbar, unabhängig von Reihenfolge.
Bereits gespeicherte Hintergründe mit `source="static"` werden über ihre vorhandene native
Asset-ID erkannt; kein neues Datenfeld oder Share-Schema. Gibt es überhaupt keine Castbar,
kann eigenständiger Casttext weiter den öffentlichen simulierten/normalisierten Castzustand nutzen.
Geheime Spellnamen werden nicht für zusätzliche Cast-Erkennung ausgewertet. Start/Stop/Interrupt
und die tatsächliche Lebensdauer von Duration-Objekten bleiben im Client zu prüfen.

## Live-Wechsel ab 0.6.1

Codeprüfung und neun zunächst scheiternde lokale Regressionstests belegten zusätzliche Probleme
in 0.6.0: Stale Views beim Token-/Basiswechsel vor Combat-Deferral, Updates am alten Frame,
verlorene hohe Pending-Tokens ohne Frame-Unit-Felder, fehlender Healthbar-Aufbau-Retry,
sowie fehlende Übertragung von Blizzard-Sichtbarkeit und Fade auf den Geschwister-Root.
Das sind belegte lokale Logikfehler, keine neu gemessenen Clientfehler.

`SimpleFrameAPI.IsShown`, `Show`, `Hide` und `SetShown` sind mit ihren bool-/void-Signaturen
im gepinnten Forever-Export geprüft. Der Adapter setzt zusätzliche Secure-Posthooks auf
Show/Hide/SetShown des zulässigen UnitFrame, ersetzt keine Methoden und liest nur öffentliche
boolesche IsShown-Ergebnisse. `SetShown` erhält einen eigenen Hook, weil ein nativer Aufruf
nicht durch die Lua-Methoden Show/Hide gehen muss. Neue öffentliche Fade-Alpha multipliziert
die eigene Regel-Alpha; Client-Hide und Regel-Hide bleiben gemeinsam maßgeblich. Geheime
Alpha/Sichtbarkeit wird weiterhin nicht ausgewertet; die eigene Darstellung fällt zurück.

Jeder Visual-Hook überprüft, dass Token, öffentliche Basis und aktueller UnitFrame noch
zur eigenen View gehören. Beim Poolwechsel wird eine gerade von Blizzard gesetzte neue
öffentliche Alpha vor dem Ablösen der alten View erhalten. Fehlgeschlagene Teilinstallation
wird bei späterer Anwendung vervollständigt, ohne erfolgreiche Hooks zu duplizieren.

Vor Combat-Deferral werden alte Bindungen gelöst, Health-Events prüfen die aktuelle Basis.
Refresh verwendet einen Snapshot bekannter, pending und retry Tokens, zusätzlich öffentliche
API-Discovery und den begrenzten 200er-Pass. Keine Unit erhält doppelte Layout-Anwendung pro
Refresh. Verschwundene Tokens werden auch ohne REMOVED-Event bereinigt. Fehlende Healthbar
und fehlender UnitFrame erhalten maximal drei 50-ms-Retries; verbotene/geschützte Frames
werden nicht über Timer umgangen. Retrys/Combat-Pool- und Fade-Verhalten müssen im echten
Forever-Client erneut geprüft werden. Der Mock simuliert Posthooks, keine Client-Taint-Mechanik.

## Live-Anwendung ab 0.6.0

Nutzerbefund: Änderungen im Designer ließen im Spiel weiterhin nur Blizzard-Standardplates
sichtbar. Codeprüfung bestätigte zwei konkrete Ursachen: Live war standardmäßig `false`,
und der eigene Root hing 45 Punkte oberhalb der Basis, ohne Blizzard-Visuals zu unterdrücken.
Der neue Adapter ist implementiert und im Widget-Mock geprüft; ein Client-Nachtest steht aus.

Die [Forever-C_NamePlate-Referenz](https://atraeau.github.io/WoW-Addons/api/UI-Systems-Input/C_NamePlate/)
zeigt im Beispiel `nameplate.UnitFrame.healthBar`. Als geprüfte Strukturreferenz dient zusätzlich
Gethe/wow-ui-source, Commit `09b9db7948abc9b9648dedaab51eb0cf3ee67b31`,
`Interface/AddOns/Blizzard_NamePlates/Blizzard_NamePlateBase.lua`: UnitFrame wird unabhängig
von der öffentlichen Basis gepoolt und beim Release auf nil gesetzt. Das ist allgemeines
Mainline-FrameXML, kein Nachweis der exakten Forever-Laufzeitstruktur. Der Adapter unterstützt
auch `UnitFrame.HealthBarsContainer.healthBar`; fehlt eine zulässige Struktur, bleibt Blizzard.

Eigener Root als Geschwister von UnitFrame, CENTER-Anker an der Healthbar; keine Änderung
von Basis-Alpha, Hit-Test, globaler Größe, Stacking oder Mouse-Handling. Nur nach erfolgreicher
Layout-/Health-Weitergabe setzt der Adapter die öffentliche Alpha des zulässigen UnitFrame auf 0.
`GetAlpha`, `SetAlpha`, `IsForbidden`, `IsProtected`, `GetNamePlates` und `C_Timer.After` sind
gegen den Forever-Export geprüft. `hooksecurefunc` ist im Kit-Export vorhanden; eine vollständige
eigenständige generierte Signatur fehlt. Ein Secure-Posthook auf `UnitFrame.SetAlpha` hält die
Unterdrückung und bewahrt den jeweils letzten öffentlichen angeforderten Blizzard-Wert für Off,
Entfernen, Pool-Recycling oder Rendering-Fallback. Keine Methodenersetzung im Addon.
Geheime Alpha wird weder verglichen noch gespeichert; bei einer solchen Blizzard-Änderung
endet die eigene Unterdrückung, ohne deren Wert erneut zu setzen. Der Posthook ist pro Visual
einmalig und nach Ablösung inaktiv. Verweigerte oder neu eingeschränkte Wiederherstellung wird
außerhalb des Kampfes erneut versucht und separat gezählt, statt Schutz zu umgehen.

GetNamePlates-Discovery mit öffentlichen Unit-Tokens, ergänzender begrenzter 1–200-Token-Pass.
Wenn Blizzard beim ADDED-Event noch keinen UnitFrame hat, maximal drei 50-ms-Timer-Retries;
Entfernen/Abschalten verwirft veraltete Tickets. Erste Erstellung wartet im Kampf, vorbereitete
zulässige Views dürfen ohne Layout-Neubau wiederverwendet werden. Kein permanenter OnUpdate-Loop.
Fehlende optionale Artwork bleibt verborgen; ein fehlender/abgelehnter aktivierter Health-Fill
oder Health-/Rendering-Fehler stellt Blizzard wieder her. Absichtliches `visible=false` einer
Regel versteckt die ersetzte Plate insgesamt. Das ist eine Änderung gegenüber dem Preview-Modus.

SavedVariables bleiben Schema 2; `liveMode="replacement-v1"` aktiviert das erste Upgrade einmalig,
erhält Profile und speichert nachfolgend ein ausdrückliches Off. FN1/FN2 bleiben unverändert.
Die tatsächliche Zulässigkeit von Alpha-Änderungen/Posthooks, Combat-Reuse, Frame-Ereignisreihenfolge
und pixelgenauer Anbindung bleibt für Build 70170 im Client zu prüfen; Existenz einer API genügt nicht.

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

Der Adapter ersetzt nur zulässige Blizzard-Visuals. Geschützte/verbotene Basis, UnitFrame
oder Healthbar sowie secret/fehlende Ausgangsalpha behalten Blizzard. Das kann einzelne oder
sämtliche Plates auf einem konkreten Build ausschließen; `/fnp status` nennt aktuelle Blockadegründe.
Auch ungeschützte Kinder eines geschützten Elternframes werden abgelehnt.

Bereits erstellte zulässige Frames aktualisieren sich eventbasiert im Kampf und können recycelt
werden. Erste Widget-Erstellung und Layoutänderung werden bis `PLAYER_REGEN_ENABLED` zurückgestellt.
GetNamePlates liefert öffentliche Basen; ein zusätzlicher Discovery-Pass ist auf 200 Unit-Tokens
begrenzt. Der Editor benutzt `OnUpdate` ausschließlich während eines aktiven Vorschau-Drags.

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
→ Ziel/andere Units. Regeln steuern eigene Plate-Eigenschaften; ab 0.6.0 unterdrückt eine erfolgreiche Live-Anwendung
auch die Blizzard-Visuals. Bei einer verborgenen Regel bleibt damit keine Standardplate zurück. Die Datenmigration fügt
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

1. Sind Basis, UnitFrame und Healthbar in Build 70170 zugänglich/ungeschützt, inklusive Vererbung?
   Funktionieren Alpha-Unterdrückung, Secure-Posthook und Wiederherstellung bei allen Pools/Unit-Kategorien?
2. Akzeptieren StatusBar-Widgets Secret-Health auch in Dungeons/PvP mit tainted Addon-Kontext?
3. Liefern Casting-/Channel-Duration-APIs zulässige Objekte für Nameplate-Units in allen Situationen?
4. Welche Masken und Effekte erfüllen Combat- und Secret-Regeln unter Last?
5. Lädt der aktuelle Forever-Build SavedVariables inzwischen wieder korrekt?
6. Ist der Raid-Atlaspfad korrekt und werden alle acht Marker ohne Verschiebung angezeigt?
7. Bleiben öffentliche Klassen-/Reaktionsangaben in Solo, Dungeon, Raid und PvP nutzbar?
8. Sind Regeländerungen von Alpha, Scale und Sichtbarkeit an vorhandenen Overlays im Kampf zulässig?
9. Entstehen Blocked-Action-/Taint-Fehler oder Interaktionen mit anderen Nameplate-Addons?

Der Nutzer meldete SetFont-/Inspector-Fehler und unveränderte Blizzard-Plates. Diese Befunde
sind oben mit Codeursachen dokumentiert. Weitere Abweichungen wurden mangels Client nicht gemessen.

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
