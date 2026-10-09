# Plater-Vergleich und Umsetzung in Forever Nameplates 0.10.0

Geprüft am 2026-10-09, Plater-Commit
[`bcc65131c3f5886fb53a36b3e7858d6c4bfe4f5d`](https://github.com/Tercioo/Plater-Nameplates/tree/bcc65131c3f5886fb53a36b3e7858d6c4bfe4f5d).
Vollständiger Download: [Plater](Plater). Dies ist ein Quellcodevergleich, keine Messung
zweier laufender Addons. Plater wurde nicht ausgeführt oder in Forever getestet.

| Bereich | Konkreter Befund bei Plater | Unser Ausgangsstand 0.9.0 | Sinnvolle Verbesserung |
| --- | --- | --- | --- |
| Einstellungen finden | `options/Plater_O_Search.lua`: `CreateSearchOptions` sammelt die Optionen aus `AllSettingsTable`, sucht Namen und gruppiert Treffer nach Tab/Überschrift | `GUI/Studio.lua`: sechs Seiten; Element- und Kategorie-Dropdowns, aber keine Einstellungssuche | Durchsuchbarer Einstellungskatalog; Treffer öffnet die passende Seite und markiert das Control. Deutsche/englische Suchbegriffe |
| Erklärung der Optionen | `options/Plater_O_CastBar.lua`: Controls mit `name`, `desc`, Wertebereich/Schritt; lokalisierte Optionsschlüssel | `GUI/Widgets.lua`: Buttons/Regler haben Labels, aber keine allgemeine Tooltip-Funktion. Viele Inspector-Texte sind Englisch | Tooltips mit Wirkung, erlaubtem Bereich und Zustandsabhängigkeit. Labels übersetzen; erklären, warum ein Icon/Control verborgen oder gesperrt ist |
| GUI-Aufbau | `Plater_OptionsPanel.lua`: `createOnDemandFunc` für Castbar, Automation, Advanced, Search, BossMods und Designer; Suchseite lädt fehlende Tabs kontrolliert nach | `Studio.createStudio` baut Galerie, Editor, vier Sandbox-Views, Regeln, Profile und Diagnose beim ersten Öffnen komplett | Seiten beim ersten Besuch bauen, danach wiederverwenden. Atomaren Fehler-Rollback und Combat-Abbruch erhalten. Vorher/nachher Widgetanzahl und Öffnungsdauer messen |
| Designer-Anker | `Plater_Designer.lua`: `layoutEditor:RegisterObject` erhält u. a. `profileKeyMap`, Optionsmetadaten und `refFrame`; `Plater_Designer_Objects.lua` enthält Anchor-Settings | `Session.Align` richtet einmalig an Healthbar/Mitte aus. Elemente speichern nur absolute X/Y und folgen späteren Healthbar-Größenänderungen nicht automatisch | Optionale relative Anker und Abstände. Beim Ändern der Barbreite soll z. B. das Casticon am Rand bleiben. Alte absolute Layouts unverändert erhalten |
| Auren | `Plater_Auras.lua`: `getAuraFrameOptions` mit `maxFrameCount`, Sortierung, Filtergruppen und Flow-Layout; `Plater_OptionsPanel.lua` mit Buff Settings/Tracking/Special | `Model.kinds` hat keine Aura-Komponente; Bootstrap registriert kein `UNIT_AURA` | Eigene Aura-Komponente mit Zeilen, Icongröße, Abstand, Limit und Filtern. Erst Forever-Aura-/Sort-/Duration-APIs prüfen; keine geheimen Daten selbst sortieren/berechnen |
| Castzustände | `options/Plater_O_CastBar.lua`: Spark-Textur/Farbe/Breite/Offset/Alpha und verschiedene Farben für normale Casts, Channels und nicht unterbrechbare Casts | Castbar/Casticon/Interrupt shield vorhanden. Barfarbe ist bislang ein Elementwert; keine Spark-Komponente oder eigene Castzustands-Palette | Zuerst optionale Farbpalette für öffentlich bekannte Cast-/Channel-/Interruptzustände. Spark erst nach geprüftem Widget-Ankerpfad, ohne geheime Zeit-/Prozent-Arithmetik |
| Questanzeige | `Plater.lua`: `IsQuestObjective` wertet je nach Client öffentliche GUID-/Tooltipdaten oder Questie aus; `Plater_Designer_Objects.lua`: Questfarben/-Icon | Keine Quest-Komponente oder Questregel | Questicon/Questfarbe nur mit belastbarer Forever-Quelle. Platers GUID-, Tooltip- und Questie-Altpfade sind keine zugesicherte Forever-Lösung |
| Aktualisierungen | `Plater.lua`: getrennte `OnUpdateHealth`, `OnUpdateHealthMax`, `OnHealthChange`, `OnHealthMaxChange` und Performance-Hooks | Bootstrap leitet alle Unit-Events an `Engine.Update`; das rendert die gesamte relevante Plate. Globale Events werden bereits nach Layoutbedarf gefiltert | Unit-Updates ebenfalls nach Ereignis/Komponente trennen. Health-Events sollen Castmetadaten und statische Dekorationen nicht erneut bearbeiten; öffentliche Identität/Regeln müssen aktuell bleiben |

## Prioritäten des Ausgangsvergleichs

1. **GUI-Hilfe und Suche.** Sofort nützlich und ohne neue Unit-APIs umsetzbar. Das beseitigt
   das aktuelle Problem, dass vorhandene Funktionen schwer auffindbar oder erklärungsbedürftig sind.
2. **Relative Anker.** Verbessert die Gestaltung unmittelbar: Name, Level, Raidmarker und
   Casticon behalten definierte Abstände zur veränderbaren Healthbar. Erfordert validierte
   Modell-/Share-Migration und neue GUI-Controls; kein stilles Umstellen vorhandener Profile.
3. **Gezielte Unit-Updates und Seitenaufbau nach Bedarf.** Erst messen, dann optimieren;
   kein Beleg für bessere FPS allein durch den Quellvergleich. Die vorhandenen Tests für
   Secret-Forwarding, Frame-Reuse, Regeln und Combat bleiben verbindlich.
4. **Aura- und Castzustands-Erweiterungen.** Für Spielnutzen wichtig, aber vor Umsetzung
   client-spezifische APIs und öffentliche Rückgaben nachweisen. Questanzeige anschließend.

## Jetzt umgesetzt in 0.10.0

| Bereich | Unsere Umsetzung | Noch zu prüfen |
| --- | --- | --- |
| Suche/Hilfe | Bilingualer Katalog, Treffer öffnet Seite und markiert Control; Tooltips mit Grenzen/Sperren | Lesbarkeit, native Tooltips und vollständige Übersetzung |
| Relative Anker | Neun Punkte, Bezug/Offset, Snap, Zyklusprüfung, Ablösen/Löschen mit Positionserhalt, Undo/FN3 | Tatsächliche Client-Geometrie bei UI-Scale/Zoom |
| Auren | Eigene Iconreihen, Buff/Debuff/eigene Filter, Client-Sortierung, IDs, Größe/Spalten/Abstand/Cooldowns | AuraData-Felder, Sort-Enums und Filter im Forever-Client |
| Castzustände | Optionale Normal-/Channel-/Nicht-unterbrechbar-Palette und nativer Spark an Fill-Textur | Spark-Anker und Textur, Unterbrechbarkeit/Channel-Pixelwirkung |
| Updates / GUI | Komponenten nach Unit-Event; sieben Zusatzseiten beim ersten Besuch gebaut, Fehler-Retry | Reale CPU/FPS und Öffnungsdauer, Combat/Taint |

Der erste Studio-Aufbau erzeugt im identischen Widget-Mock 550 statt 1498 Objekte;
Sandbox-Views entstehen erst beim Seitenbesuch. 40 Health-Events einer vorbereiteten Plate
machen keine Cast-/Aura-Abfragen und bearbeiten keine statischen Panels. 329 lokale Tests
bestehen; kein realer Clientvergleich daraus abgeleitet. Questmarker und zusätzliche
Animationen/Aura-Prioritätsgruppen bleiben offen. [GUI-Abdeckung](../docs/GUI_SETTINGS.md),
[Bedienung und konkrete API-Lücken](../docs/PLATER_FEATURES.md).

## Grenzen der Übernahme

Platers `OnUpdateHealth` enthält neben modernen Zweigen auch direkte Health-Differenzen
und Prozentrechnung. `IsQuestObjective` verwendet GUID-/Tooltip- und Drittaddonpfade.
Diese Implementierungen werden nicht pauschal übernommen. Unser Forever-Adapter muss
weiter geheime Werte direkt an zulässige Widgets weitergeben und bei nicht verfügbaren
Daten auf sichere Darstellung zurückfallen.

Wir haben bereits einen frei zusammensetzbaren Komponenten-Editor, lokale Vorschau,
Undo/Redo, validierte Datenprofile und wiederverwendete Widgets. Platers mehr Funktionen
belegen nicht automatisch bessere Performance oder Forever-Kompatibilität. Auch seine
Scripting-/Wago-/BossMod-Systeme sind für den derzeitigen Nameplate-Designauftrag keine
notwendigen Abhängigkeiten. Kein Plater-Code oder -Artwork wurde in unser Laufzeit-Addon kopiert.
