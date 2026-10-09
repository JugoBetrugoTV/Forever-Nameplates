# Die fünf neuen Funktionen — 0.10.0

Nach `/reload` öffnet `/fnp` den Designer. Alle neuen Optionen liegen unter **Anker / Auren /
Casts** links in der Navigation oder im Layout-Studio über den gleichnamigen Button.
Oben auf dieser Seite wird das Element gewählt; unten stehen Vorschau, Testzustand und
Undo/Redo. Änderungen gehören zum aktiven Profil und aktualisieren zulässige Live-Plates.

## Einstellungen finden und verstehen

Im Suchfeld oben z. B. `Deckkraft`, `Aura Spalten`, `Cast Spark` oder `minimap` eingeben
und **Suche** klicken. Die Suchseite filtert beim Tippen, hat Folgeseiten und öffnet per
Treffer die passende Einstellung mit kurzer Markierung. Deutsch und Englisch sind suchbar.
Bei Aura-/Castoptionen wird eine passende vorhandene Komponente gewählt; gibt es keine,
bleibt das Control gesperrt. Zuerst eine Komponente hinzufügen und entsperren.

Hilfetexte erscheinen beim Überfahren der katalogisierten Controls, einschließlich
Reglern und Plus/Minus. Sie erklären Wertebereiche und Zustandsabhängigkeiten.
Die vorhandene Oberfläche ist noch nicht vollständig deutsch übersetzt.

## Icons am Balkenrand halten

Ein Icon wählen, **Ankerbezug → health**, **Eigener Ankerpunkt → LEFT** und
**Ankerpunkt am Bezug → RIGHT** setzen. **An Anker setzen** setzt die Abstände auf null:
Das Icon sitzt rechts am Healthbalken. Breite oder Position des Balkens im Studio ändern;
das Icon folgt automatisch. X/Y im Inspector sind jetzt Abstände zu diesen Ankerpunkten.
Bei Bezugwechsel bleibt die Position erhalten, bis Snap geklickt wird.

Alle neun Punkte und Ankerketten sind möglich. Selbstbezug/Zyklen/fehlende Bezüge werden
abgelehnt. **Plate-Mitte / absolut** löst den Bezug unter Erhalt der Position. Beim Löschen
eines Bezugs werden direkte abhängige Elemente ebenso abgelöst; ein gesperrtes abhängiges
Element blockiert das Löschen. Undo/Redo bleibt verfügbar. Vorhandene absolute Layouts
werden nicht automatisch umgestellt.

## Aura-/Debuff-Reihen

**+ Add component → zweite Menüseite → Aura / debuff icons** hinzufügen. In der Mitte der
Komponentenseite Buff/Debuff, nur eigene Auren, Sortierung und Richtung wählen. Der Client
sortiert nach Ablaufzeit oder Zaubername; das Addon berechnet keine geheimen Zeiten.
Limit 1–12, Spalten 1–12, Icongröße 8–32 und Abstand 0–8 lassen sich per Maus einstellen.
Breite/Höhe der Reihe werden daraus abgeleitet; sie werden nicht separat per Eckgriff verändert.
Für getrennte Buff-/Debuff-Reihen zwei Komponenten hinzufügen und verankern.

**Alle / Nur gelistete / Gelistete ausblenden** und eine kommagetrennte Liste von höchstens
32 Spell-IDs steuern den ID-Filter. Fehlende/geheime IDs erscheinen bei expliziten Listen
nicht. Öffentlich verfügbare Stackcounts werden angezeigt. Cooldownswipes verwenden direkt
die Duration-Objekte des Clients; in der lokalen Vorschau gibt es feste Beispielicons.
Der Adapter untersucht höchstens die ersten 40 vom Client zurückgegebenen Einträge pro Reihe;
ID-Listen suchen nicht unbeschränkt alle Auren einer Unit.

Die Forever-Definitionen dokumentieren die APIs, enthalten aber keine vollständigen AuraData-
Felder oder Sort-Enums. Fehlende API/Enums, gesperrte Unitdaten oder abgelehnte Texturen
verbergen die Reihe beziehungsweise das Icon; fehlender Cooldown verbirgt nur den Swipe.
Diese neue Funktion ist noch nicht am Forever-Client bestätigt. [API-Lücken](API_AUDIT.md).

## Castfarben und Spark

Eine Castbar wählen. **Zustandsfarben verwenden** aktivieren und Farben für normale Casts,
Channels und nicht unterbrechbare Casts per ColorPicker einstellen. Der bestätigte öffentliche
Nicht-unterbrechbar-Status hat Vorrang. Bei unbekanntem Status gilt die Normal-/Kanalfarbe.
Ohne Aktivierung bleibt die bisherige Komponentenfarbe maßgeblich.

**Cast-Spark anzeigen** ist unabhängig aktivierbar; Farbe, Breite und Deckkraft einstellen.
Der Spark verwendet eine native Clienttextur und folgt direkt der Fülltexturkante, auch bei
vertikaler/umgekehrter Füllung. Keine eigene Zeit-/Prozentrechnung oder Daueranimation.
Fehlende Textur/Anker verbirgt nur den Spark. Der Vorschauzustand **Channel** zeigt die Kanalfarbe.

## Updates, Seiten und Austausch

Health-, Cast-, Aura-, Name- und Level-Events bearbeiten passende Teile der Plate. Angezeigte
öffentliche Identität und Regeln bleiben aktuell; es gibt keinen geheimen Healthcache.
Die sieben Zusatzseiten werden erst beim ersten Besuch gebaut und wiederverwendet;
ein Aufbaufehler lässt die bisherige Seite bedienbar und kann erneut versucht werden.

Im selben Widget-Mock erzeugt das erste Öffnen **550 statt 1498 Objekte**. 40 Health-Events
einer vorbereiteten Plate machen keine Cast-/Aura-Abfragen und ändern keine statischen Panels.
**329 lokale Tests** bestehen; reale FPS, Öffnungsdauer, Combat/Taint und Grafikgeometrie
sind noch anhand der [Ingame-Checkliste](INGAME_TESTS.md) zu prüfen.

Layouts mit Ankern, Aura-Reihen oder Caststilen exportieren **FN3** und benötigen mindestens
0.10.0. Andere Layouts exportieren weiter FN2; FN1/FN2 bleiben importierbar. SavedVariables
migrieren auf **3**, das Layoutmodell bleibt **2** mit optionalen Erweiterungen.
Ältere Addonversionen verweigern die neuere Datenbank statt neue Einstellungen zu verlieren.
Vor einem Clientneustart einen Share-Code extern sichern; der gemeldete Beta-Ladefehler
ist weiterhin nicht auf deinem Build geprüft.

Originalspiel-Assets/Fonts, Questmarker, zusätzliche Aura-Prioritätsgruppen und freie
Animationen bleiben offen. Diese Funktionen bestätigen keinen 1:1-Originaldesignvergleich.
