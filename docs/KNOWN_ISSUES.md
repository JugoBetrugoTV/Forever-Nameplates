# Offene Punkte — 2026-10-09, Version 0.8.0

228 lokale Tests bestehen. Hier läuft kein WoW-Client: Das belegt lokale Logik,
keine realen Combat-Freigaben, Texturpixel, FPS oder fehlerfreie Ingame-Nutzung.
Die jüngsten Korrekturen sind im Client noch nicht nachgetestet.

## Bei dieser Prüfung belegte Fehler und Korrekturen

| Befund | Ergebnis |
| --- | --- |
| Dragonflight-Cast-Hintergrund konnte ohne sichtbaren Castbalken stehen bleiben; Casttext konnte trotz verweigerter Timer-Weitergabe sichtbar sein | In 0.6.2 korrigiert; zwei zuerst scheiternde Regressionstests prüfen Vorschau/Live, fehlende Duration, abgelehnte Weitergabe, deaktivierte Bars und Elementreihenfolge |
| Channels verwendeten dieselbe Standardrichtung wie Casts; reine Healthlayouts wurden bei Ziel-/Raid-/Spielerlevel-Events unnötig komplett aktualisiert | In 0.8.0 mit zwei zuerst scheiternden Mockfällen korrigiert; echte Channel-Pixelwirkung ungeprüft |
| README im installierten Addon nannte 0.2.0 und behauptete zusätzliche, opt-in Overlays | In 0.6.2 korrigiert; Paketinhalt geprüft |

Die früher gemeldeten SetFont-/Inspector-Fehler sowie die fehlende Live-Anwendung haben
Codekorrekturen erhalten. Ein erfolgreicher Client-Nachtest dieser Korrekturen wurde hier
noch nicht gemeldet. Die offenen Punkte unten sind keine pauschale Liste bestätigter Bugs.

## Priorität: echte Live-Anwendung

- **Blizzard bleibt bei eingeschränkten Frames sichtbar.** Geschützte/verbotene Basis,
  UnitFrame oder Healthbar sowie nicht öffentlich nutzbare Alpha/Sichtbarkeit werden nicht
  ersetzt. Das ist eine konservative Laufzeitgrenze; ob/welche Units im tatsächlichen
  Forever-Build betroffen sind, ist offen. Bei sichtbarer Unit `/fnp status` prüfen.
- **Erstmaliger Widget-Aufbau im Kampf wartet.** Bis Kampfende bleibt dafür Blizzard.
  Bereits vorbereitete zulässige Views können recycelt werden. Das ist die aktuelle
  Implementierung, kein Beleg dafür, dass der Client jede neue ungeschützte Erstellung verbietet.
- **Combat/Taint und Pool-Recycling:** Alpha-/Sichtbarkeits-Posthooks, Entfernung, Fallback,
  Ziel-/Zonenwechsel sowie Wiederherstellung unter echten Client-Beschränkungen prüfen.
- **Optionale Icons:** Native Klassenatlanten, Cast-/Channel-FileIDs, Stop/Interrupt und
  Poolwechsel im Forever-Client prüfen. Fehlender Atlas/Secret-Icon blendet die Komponente aus.
  [Addonvergleich und neue Komponenten](ADDON_COMPARISON.md).
- **Casts/Channels:** Start, Delay, Stop, Interrupt und Channel-Ende müssen im Client geprüft
  werden. ElapsedTime/RemainingTime wird ab 0.8.0 über öffentliche Enums gewählt; deren
  tatsächliche Verfügbarkeit und Channel-Wirkung sind ungeprüft. Ohne Enums bleibt die Channelbar verborgen.
  Der optionale Schildmarker benötigt öffentlichen Unterbrechbarkeitsstatus und verfügbaren Atlas. Die dokumentierten Duration-Rückgaben allein beweisen nicht, wann ein tatsächlicher
  Client kein nutzbares Objekt mehr liefert; es gibt keine eigene geheime Timing-Arithmetik.
- **Daten und Last:** SavedVariables nach kaltem Neustart prüfen. Das Kit berichtet einen
  Beta-Ladefehler, hier nicht am Client bestätigt. Externen Share-Code behalten. CPU/FPS und
  Speicher bei 40+ Plates sowie Konflikte mit anderen Nameplate-Addons sind ungeprüft.

[Vollständige Ingame-Checkliste](INGAME_TESTS.md) · [API-Evidenz und Abweichungen](API_AUDIT.md).

## Priorität: die gewünschten Originaldesigns

| Spiel | Was tatsächlich vorhanden ist | Was fehlt |
| --- | --- | --- |
| WoW Classic 1.15.8 | Quellenlayout, native Clientressourcen, Level-Schwierigkeitsfarben/Schädel | Originalbild-/Forever-Pixelvergleich, Font-/UI-/CVar-Scale-Abgleich |
| WoW Dragonflight 10.2.7 | Quellenlayout, native Clientressourcen | Derselbe visuelle Abgleich einschließlich Cast- und Target-Zuständen |
| FFXIV | Vier geprüfte Originalbilder, vermessener roter Gegner-Entwurf | Rahmen, HP-Fill, Gegnericon; Originalschrift und Patch/UI-Scale offen. Menü bleibt bis zu den drei Assets gesperrt |
| Guild Wars 2 | Referenzauftrag | Geeignete geprüfte Original-Nameplate, Maße, Assets und Layout; Auswahl deaktiviert |
| SWTOR | Referenzauftrag | Dasselbe; Auswahl deaktiviert |
| ESO | Referenzauftrag; gepinnter UI-Community-Mirror belegt Anzeigeoptionen | Originalbild, Geometrie, Assets und Layout; Auswahl deaktiviert |
| Diablo IV | Referenzauftrag | Dasselbe; Auswahl deaktiviert |

**Noch kein Design ist als 1:1 im Forever-Client abgenommen.** Die zwölf Legacy-Presets sind
Platzhalter. Alle neun aktiven Nameplate-PNG-Aufträge stehen aus; Classic/Dragonflight können
bis dahin vorhandene Clientressourcen nutzen. Bilder und ihre vorläufigen Maße sind in
[INTERNET_IMAGE_REFERENCES.md](INTERNET_IMAGE_REFERENCES.md) und
[NAMEPLATE_REFERENCES.md](NAMEPLATE_REFERENCES.md) dokumentiert.
[Konkrete Bildprompts](../ART_ASSET_REQUESTS.md) sind für die separate Asset-Lieferung vorbereitet.

Der Recherche-Entwurf ergänzt unter anderem den nachgewiesenen Blizzard-Bildhost
`bnetcmsus-a.akamaihd.net`. Er ist gespeichert, noch nicht veröffentlicht; diese Bilder
konnten hier weiterhin nicht heruntergeladen oder geprüft werden.
[Neue Abrufbefunde und ESO-Quelle](INTERNET_IMAGE_REFERENCES.md#aktualisierung-2026-10-09).

## Noch nicht implementiert

- Maskierte runde/gebogene Health-Füllungen; derzeit sind Health-/Castbars rechteckige StatusBars.
- Questmarker und Cast-Spark. Class-/Casticons (0.7.0) und Interrupt-Shield (0.8.0) sind als
  optionale Komponenten implementiert, noch nicht im Forever-Client abgenommen.
- Freie Ankergruppen und Animationen; zusätzliche Details sollen konkrete Original-Nameplates abbilden.
- Vollständige deutsche Übersetzung; Teile des Editors und der Diagnose sind weiterhin Englisch.
- Eigene exakte Threat-/Aura-Auswertung: nicht implementiert, Client-/Secret-Grenzen müssen berücksichtigt werden.

Sinnvolle Reihenfolge: Live-Anwendung im Client bestätigen, vorhandene WoW-Layouts visuell
abgleichen, FFXIV-Assets importieren, die vier fehlenden Originalvorlagen recherchieren und
anschließend die daraus tatsächlich benötigten Formen/Icons ergänzen.
