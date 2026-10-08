# Forever API-Audit — 2026-10-08

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

Die GUI unterstützt derzeit Layout-Elemente relativ zur gemeinsamen Plate-Mitte. Freie Ankergruppen,
Maskenformen, Regelwerk, Klassenfarben, Raid-/Questmarker, Casticons, Threat, Minimap-Launcher,
vollständige Localization, Animationen und die restlichen Spezialseiten folgen separat.

## Ingame noch zu klären

1. Sind öffentliche Nameplate-Basen in Build 70170 tatsächlich ungeschützt, inklusive Vererbung?
2. Akzeptieren StatusBar-Widgets Secret-Health auch in Dungeons/PvP mit tainted Addon-Kontext?
3. Liefern Casting-/Channel-Duration-APIs zulässige Objekte für Nameplate-Units in allen Situationen?
4. Welche Masken und Effekte erfüllen Combat- und Secret-Regeln unter Last?
5. Lädt der aktuelle Forever-Build SavedVariables inzwischen wieder korrekt?
6. Entstehen Blocked-Action-/Taint-Fehler oder Interaktionen mit anderen Nameplate-Addons?

Abweichungen zu diesen Quellen sind bislang **nicht gemessen**, da kein Client vorhanden ist.
