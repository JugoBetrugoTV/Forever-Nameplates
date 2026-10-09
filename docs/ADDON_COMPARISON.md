# Vergleich anderer Nameplate-Addons — 2026-10-09

Ziel: die eigenen Overhead-Nameplates zuverlässiger und sparsamer machen und fehlende
Komponenten ergänzen. Gelesen wurden die folgenden tatsächlichen Git-Checkouts; keine
Quelldateien, Bibliotheken, Profile oder Grafiken daraus wurden ins Addon übernommen.
Diese Upstreams beweisen keine Kompatibilität mit WoW Forever 1.60.1.

Auf Nutzerwunsch liegt jetzt zusätzlich ein vollständiger gepinnter Plater-Checkout im
Projektordner [ReferenceAddons/Plater](../ReferenceAddons/Plater) (Git-Submodule, gleicher
Commit wie unten). Der [vertiefte Vergleich](../ReferenceAddons/PLATER_REVIEW.md) untersucht
Suche/Hilfe, Seitenaufbau, relative Anker, Auren, Cast-/Questdarstellung und Unit-Updates.
Das installierbare Forever-Addon enthält weiterhin keine Plater-Dateien.

| Addon / gepinnter Stand | Gelesene Stellen | Relevanter Befund |
| --- | --- | --- |
| [Plater](https://github.com/Tercioo/Plater-Nameplates/tree/bcc65131c3f5886fb53a36b3e7858d6c4bfe4f5d) | `Plater.lua`: `OnUpdateHealth`, `OnUpdateHealthMax`, `OnHealthChange`, Cast-Icon-Anlage; `options/Plater_O_CastBar.lua` | Health-/MaxHealth-Pfade und Healthtext sind getrennte Aufgaben; Casticons sind separat konfigurierbare Teile der Plate |
| [KuiNameplates](https://github.com/kesava-wow/kuinameplates2/tree/e1bbbc44f3ce398605ccb27dddf4e7308e1b494f) | `Kui_Nameplates/elements/healthbar.lua`, `elements/castbar.lua`; `Kui_Nameplates_Core/create.lua`; `Kui_Nameplates/lib/Kui/Kui.lua` | Elementweise Updates, SpellIcon mit Cast-Lebenszyklus, separat positionierbares Icon und native Klassenressourcen. Alte direkte Health-/Zeit-Arithmetik ist keine Forever-Vorlage |
| [Threat Plates](https://github.com/Backupiseasy/ThreatPlates/tree/64fb6fe443058a1c14cb836a4a9f3e9040bebc6b) | `Elements/Healthbar.lua`, `Elements/StatusText.lua`, `Elements/Castbar.lua`, `Widgets/ClassIconWidget.lua` | Bedarfsgerechte Healthtext-Subscriptions; Cast-/Klassenicon als eigene Elemente. Neuere Secret-Guards, aber auch versionsabhängige Timer-/Threat-Pfade |
| [Forever-gepatchtes BlizzThreatPlates](https://github.com/Atraeau/WoW-Addons/tree/d8c9be3635e756fd90284e02b5a800c796b337a0/vendor/BlizzThreatPlates) | `PATCHES.md`, `BlizzThreatPlates.lua` | `UNIT_HEALTH_FREQUENT`/PixelUtil-Altwege funktionieren dort nicht; direkte Widget-Weitergabe nötig. Geheime Threatwerte und geschützte Blizzard-Aktionen bleiben begrenzt |

Der erste geratene Kui-Repositoryname `kesava-wow/kuinameplates` lieferte „Repository not found“;
verwendet wurde das tatsächlich erreichbare `kuinameplates2`. Forschungscheckouts liegen
außerhalb des installierten Addons unter `/workspace/research/`.

## In 0.7.0 umgesetzt

- **Abfragen nach Layoutbedarf:** Beim Anwenden werden aktive Textquellen/Castattachments
  erfasst. Live-Updates fragen Namen, Level, Prozent-Healthtext und Cast-Metadaten nur ab,
  wenn sie benötigt werden. Regeln erhalten weiterhin aktuelle öffentliche Identität;
  es gibt keinen Identitäts-, Health- oder Timingcache. Ein alleiniger Castbalken braucht
  nur die Duration-API, keine Spellname-Abfrage. Bestehende Profile und Formen bleiben erhalten.
- **Cast icon:** optionale frei platzierbare/skalierbare Komponente. Nur öffentliche positive
  ganzzahlige FileIDs aus dem dritten Rückgabewert von `UnitCastingInfo`/`UnitChannelInfo`.
  Geheimer Name darf neben einem öffentlichen Icon leer bleiben; kein Spell-ID-Lookup zur
  Umgehung eines geheimen Icons. Mit Castbar folgt das Icon deren tatsächlicher Sichtbarkeit,
  auch bei verweigertem Duration-Forwarding und beliebiger Elementreihenfolge.
- **Class icon:** optionale Komponente für Spieler mit öffentlichem bekanntem Klassentoken.
  Native `classicon-<klasse>`-Atlanten werden auf öffentliche Verfügbarkeit geprüft.
  Kein eigenes Classes-Sprite-Sheet oder kopiertes Threat-Plates-Artwork.
- **Pooling:** Icons werden beim Layoutaufbau erstellt, danach wiederverwendet. Beim Reuse
  werden Textur/Atlas/Crop/Sichtbarkeit zurückgesetzt. Ein fehlendes optionales Icon blendet
  keine funktionierende Healthbar aus und beendet nicht die gesamte Live-Anwendung.

Im Studio unter **+ Add component → Class icon / Cast icon** hinzufügen; Position, Größe,
Ebene, Farbe, Deckkraft, Sperre und Sichtbarkeit wie bei anderen Elementen bearbeiten.
Die Icons werden nicht automatisch in die referenzbasierten Original-Layouts eingefügt.
Ein bearbeitetes Quellenlayout ist dann eine eigene Variante. Klassenkürzel bleiben separat
als **Class badge** vorhanden. Keine zusätzlichen PNG-Lieferungen oder Libraries nötig.

Für die Vorschau **Friendly / Enemy Player** für Klassenicons und **Casting / Boss** für
Casticons wählen. Nicht-Spieler beziehungsweise inaktive Casts zeigen absichtlich kein Icon.

## Lokale Evidenz und offene Grenzen

**212 Tests bestanden**, davon 24 neue Fälle für Icons, Metadaten und Datenbedarf.
Für das unveränderte Classic-Quellenlayout wird pro Live-Update jedes Health-API einmal
anstatt zweimal aufgerufen; Cast-/Channel-Metadaten werden gar nicht abgefragt.
Der Test zählt 101 Updates einschließlich initialer Anwendung, auch mit Secret-Health.
Weitere Fälle prüfen Channel-Icons, fehlende APIs, geheime/ungültige Rückgaben, Textur-/Atlas-
Ablehnung, Castreihenfolge, Stop, Pool-Reuse, Combat-Reuse und Editor-/FN2-Roundtrips.

Das sind API-Aufrufzahlen und Widget-Mock-Ergebnisse, **keine FPS-/CPU-Messung im Client**.
Native Atlasnamen stammen aus allgemeinem FrameXML (SharedConstants.lua, Commit
`09b9db7948abc9b9648dedaab51eb0cf3ee67b31`); ihre Forever-Verfügbarkeit und Pixel sind offen.
Bei fehlendem Atlas bleibt das Icon verborgen. Cast/Channel-Eventreihenfolge und Combat/Taint
müssen im Spiel geprüft werden. Quellenstand, neue APIs und offene Tests stehen in
[API_AUDIT.md](API_AUDIT.md) und [INGAME_TESTS.md](INGAME_TESTS.md).

## Weiterer Vergleich und Umsetzung in 0.8.0

[NeatPlates](https://github.com/Luxocracy/NeatPlates/tree/250535d347011e9970292a7781633b10bdf28018),
Commit `250535d347011e9970292a7781633b10bdf28018`, Datum 2025-09-21. Gelesen:
`NeatPlates/NeatPlatesCore.lua` (Cast-/Channel-Aufbau, Unterbrechbarkeit und Target-Events),
`NeatPlatesHub/functions/Color.lua` und `functions/Alpha.lua`. Es trennt Vorwärts-/Rückwärts-
Castpfade und bietet unterschiedliche Castzustandsdarstellung. Seine Classic-Annahme
„notInterruptible = false“ und eigene Zeit-Arithmetik wurden nicht übernommen. Der zunächst
geratene Hubbot-Repositoryname war nicht erreichbar; verwendet wurde Luxocracy/NeatPlates.

Zusätzlich vertieft: Platers `SetTimerDuration` mit ElapsedTime/RemainingTime sowie
Threat Plates/KuiNameplates Unterbrechbarkeit und Schildwechsel. Keine Quellkopien oder
fremden Grafikdateien. Unsere Umsetzung bleibt auf die Forever-Signaturen begrenzt.

- **Interrupt shield**: neue frei editierbare optionale Komponente im Add-Menü. Native
  Atlasressource, nur öffentlich bestätigtes `notInterruptible`. Cast-/Channel-Returnpositionen
  unterscheiden sich; zwei dokumentierte Events aktualisieren den Status.
- **Channel-Richtung**: RemainingTime statt Standard ElapsedTime, mittels öffentlicher
  Runtime-Enums. Fehlende Enums blenden die Channelbar aus; keine Ersatz-Zeitberechnung.
- **Globale Updates nach Bedarf**: Ziel-/Raidmarker-/Level-Events laufen nur für entsprechende
  Layouts/Regeln. Ein Snapshot verhindert veränderte Iteration durch Ablösen/Neubinden von Units.

**228 lokale Tests**, davon 16 neue Fälle. Zwei zunächst scheiternde Regressionen belegten
Channelrichtung und unnötige globale Render-Updates. Bei 40 Health-only-Plates überspringen
300 irrelevante globale Events nun 12.000 vorherige Render-Updates; 40 anschließende Health-
Updates funktionieren ohne Widget-Neuanlage. Das ist kein Ingame-FPS-Benchmark. Schildpixel,
Enum-Verfügbarkeit, Combat/Taint und echte Eventreihenfolge bleiben zu prüfen. Für die
Schildvorschau den vorhandenen **Boss**-Zustand wählen. Alle neun PNG-Aufträge bleiben erhalten.

## GUI-Vergleich und Umsetzung in 0.9.0

Plater `options/Plater_O_CastBar.lua` verwendet Range-Controls mit min/max/step (u. a. 0.01)
statt Enter-pflichtiger Zahlenfelder. Zusätzlich gelesen: KuiNameplates
`Kui_Nameplates_Core/config.lua`, `configChangedAuras` mit Sortierung, Icongröße, eigenen/
fremden und freundlichen/feindlichen Auren. Das begründet eine mögliche Aura-Filterseite;
es beweist nicht, dass dieselben Daten in Forever öffentlich verfügbar sind.

Jetzt umgesetzt: Mausregler/Stepper/Mausrad für vorhandene Zahlen, ein History-Schritt pro
Slider-Drag, sichere Focus-/Klickübernahme, Overlap-Auswahl, Schriftstile/native Texturen,
bedingte Sichtbarkeit und Minimap-Controls. Keine DF/Ace-Bibliothek oder Upstream-Quellkopie.
27 neue Fälle, **255 Tests** insgesamt. Alle bestehenden GUI-Funktionen sind in
[GUI_SETTINGS.md](GUI_SETTINGS.md) mit ihrem Bedienort aufgeführt. Noch nicht implementierte
Features erhalten keine funktionslosen Schalter.

## Zurückgestellt

- Aura-, Threat-, Execute- und automatische Interrupt-Logik nur nach belegter zulässiger Forever-API;
  keine kopierten Retail/Classic-Geheimwertberechnungen oder Combatlog-Rekonstruktion.
- Cast-Spark und weitere Castzustands-Effekte benötigen einen separaten Forever-Abgleich.
  Channel-Richtung und optionaler Interrupt-Shield sind ab 0.8.0 lokal implementiert, noch nicht im Client abgenommen.
- Questmarker, Masken/gebogene Füllungen sowie die vier fehlenden Fremdspiel-Originaldesigns
  bleiben offen. Sie werden durch diese allgemeinen Komponenten nicht als erledigt markiert.
