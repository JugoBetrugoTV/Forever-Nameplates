# Referenzgebundene Grafikaufträge für Forever Nameplates

Der gewünschte Maßstab ist jetzt der **konkrete Original-Look einer ausgewählten Spiel-UI**.
Die alten freien „Premium-Fantasy“-Prompts sind ersetzt. Die vorhandenen zwölf Presets sind
technische Platzhalter; sie sind keine Nachbauten dieser Spiele. Die KI-Vorschau in der README
ist ebenfalls keine Originalreferenz und keine Designabnahme.

## Was vor dem ersten fertigen Rahmen feststehen muss

Je Slot: Spiel, Patch/UI-Version, konkretes Element (Nameplate, Targetframe oder Player-HUD),
Skin/Faktion, Zustand (normal, ausgewählt, Elite/Boss) und ein Originalbild oder ein Link genau
dieser Ansicht. „Guild Wars 2“ allein legt keinen bestimmten Rahmen fest. Die erste wichtigste
Vorlage wird vom Nutzer ausgewählt; solange sie fehlt, wird keine erfundene Grafik als 1:1 bezeichnet.

Die bisherigen Maße und Balkenöffnungen unten sind **vorläufige technische Verträge aus den
Platzhaltern**. Bei abweichender Originalgeometrie werden zuerst Layout und Importvertrag angepasst.
Der Original-Look wird nicht passend zu diesen Maßen verzerrt. Originaldateien werden nicht aus
Spielarchiven extrahiert; die sichtbare Gestaltung wird anhand der gewählten Vorlage rekonstruiert.
Generierung ist ein Entwurfsschritt, kein Beweis für Pixelidentität. Rahmen, Fülltextur, Hintergrund,
Schrift, Textabstände und Zielzustand müssen gemeinsam mit der Referenz verglichen werden.

## Lieferung und Verwendung

Die fertigen Assets liefert der Nutzer separat als PNG per Drag-and-Drop in `ArtDrop/`.
`python Tools/import_art.py` prüft technische Daten und erzeugt 32-Bit-TGA-Dateien. Dateimaße und
Alpha sind automatisch prüfbar; Referenztreue und Materialqualität sind es damit nicht.

Nach Import und `/reload` im Studio **Use imported frame; remove preset ornaments** wählen.
Das aktiviert `artFrame` in Weiß ohne Farbtint, übernimmt die für dieses Asset hinterlegten Maße
und blendet die bekannten Preset-Ornamente aus. Eigene hinzugefügte Komponenten bleiben erhalten.
Sperren und Combat-Pause werden respektiert; die Änderung ist mit Undo rückgängig zu machen.
Health-Hintergrund, Text und Zielmarkierung müssen passend zur Referenz separat eingestellt werden.
Die Aktion selbst stellt noch keinen Original-Nachbau her.

## Abnahme direkt neben dem Original

- Original und Rekonstruktion bei 100 % vergleichen; keine gezoomte KI-Collage als Vergleich.
- Außenkontur, freie Balkenöffnung und asymmetrische Details müssen an denselben Stellen liegen.
- Border/Bevel, Material, Farbe und Highlights müssen aus der gewählten Ansicht stammen.
- Keine hinzugefügten Rauten, Blätter, Flügel oder Runen, die das Original nicht besitzt.
- Name, Zahlen, Level, Icons und Castbar: eigene Schrift, Grundlinie, Abstände und Größen prüfen.
- Zustand normal/target/elite separat abgleichen; ein Zustand ersetzt nicht alle Varianten.
- Erst nach dem visuellen Vergleich „Referenz abgeglichen“ dokumentieren. Aktuell: kein Slot abgenommen.

## Konkrete Aufträge

Die Felder `reference` in `Tools/art_requests.json` dokumentieren offene Quellen und UI-Versionen.
Eine leere Quelle ist bewusst kein behaupteter Quellenbeleg. Außer den vier ausdrücklich benannten
Spiel-Presets ist noch kein Spiel einem Slot fest zugeordnet. ESO, FFXIV und Diablo IV aus dem
Briefing sind verfügbare Vorlagen für diese Auswahl, keine heimlich vorgenommenen Zuordnungen.

## Batch 1 — classic_frame.png

- Referenzspiel: **World of Warcraft Classic**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **180 × 14 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from World of Warcraft Classic as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 180 x 14 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 1 — fantasy_frame.png

- Referenzspiel: **Spiel/Originalelement noch zuzuordnen**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **182 × 12 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from the specific game UI assigned to this slot; assignment is still required as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 182 x 12 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 1 — horde_frame.png

- Referenzspiel: **Spiel/Originalelement noch zuzuordnen**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **156 × 20 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from the specific game UI assigned to this slot; assignment is still required as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 156 x 20 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 1 — medieval_frame.png

- Referenzspiel: **Spiel/Originalelement noch zuzuordnen**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **158 × 18 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from the specific game UI assigned to this slot; assignment is still required as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 158 x 18 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 2 — arena_frame.png

- Referenzspiel: **Spiel/Originalelement noch zuzuordnen**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 128 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **22 × 64 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from the specific game UI assigned to this slot; assignment is still required as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 128 pixels, RGBA PNG, real transparent alpha, design centered at (128, 64), central health-fill opening 22 x 64 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 2 — dragonflight_frame.png

- Referenzspiel: **World of Warcraft Dragonflight**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **192 × 9 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from World of Warcraft Dragonflight as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 192 x 9 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 2 — galactic_frame.png

- Referenzspiel: **Star Wars: The Old Republic**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **176 × 8 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from Star Wars: The Old Republic as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 176 x 8 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 2 — minimal_frame.png

- Referenzspiel: **Spiel/Originalelement noch zuzuordnen**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **168 × 5 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from the specific game UI assigned to this slot; assignment is still required as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 168 x 5 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 2 — neon_frame.png

- Referenzspiel: **Spiel/Originalelement noch zuzuordnen**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **194 × 8 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from the specific game UI assigned to this slot; assignment is still required as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 194 x 8 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 3 — arcane_frame.png

- Referenzspiel: **Spiel/Originalelement noch zuzuordnen**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **172 × 10 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from the specific game UI assigned to this slot; assignment is still required as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 172 x 10 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 3 — celestial_frame.png

- Referenzspiel: **Spiel/Originalelement noch zuzuordnen**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **182 × 6 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from the specific game UI assigned to this slot; assignment is still required as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 182 x 6 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 3 — guildwars_frame.png

- Referenzspiel: **Guild Wars 2**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **256 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **174 × 12 Pixel**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original UI crop from Guild Wars 2 as the binding reference for the exact frame component. Identify the game patch, the exact UI element (nameplate versus target frame versus player HUD), faction/theme and selection state before reconstruction. Reconstruct the visible design as closely as possible: exact outer silhouette, border thickness, corner cuts, bevels, materials, highlight direction, palette, surface marks and every ornament position. Do not replace the reference with generic diamonds, wings, botanical leaves, runes or a differently colored rectangular bar. Do not add details absent from the reference. Separate the decorative frame from dynamic health fill, numbers and labels, which will be rendered independently by the addon. Current PROVISIONAL export contract: EXACTLY 256 x 64 pixels, RGBA PNG, real transparent alpha, design centered at (128, 32), central health-fill opening 174 x 12 pixels entirely transparent. Preserve original proportions and native pixel measurements. If the reference does not match this canvas or opening, report the required layout/contract dimensions before generating; never squeeze, stretch or simplify the original design to satisfy this provisional placeholder contract. One isolated asset, no screenshot scenery, text, numbers, baked-in logos, health fill, checkerboard, atlas or contact sheet. No generic MMORPG reinterpretation. A missing reference is a reason to request that reference, not invent one. Image generation alone cannot promise pixel-identical reconstruction; compare output with the original at native scale.
```

## Batch 4 — studio_header.png

- Referenzspiel: **Spiel/Originalelement noch zuzuordnen**.
- Exakte UI-Version/Originalansicht: **fehlt**; Status `awaiting_exact_reference`.
- Vorläufige Ausgabe: **512 × 64 Pixel**, RGBA PNG mit echtem Alpha.
- Vorläufige freie Balkenöffnung: **keine; Textbereich separat freihalten**.
- Ein Einzelasset; keine fertige Grafik vorhanden.

Referenzbild zusammen mit diesem Prompt an die Bildgenerierung übergeben:

```text
Use the attached original-game UI crop as the binding visual reference for this editor header. The source game, patch and UI element must be specified first. Reconstruct its exact visible contour, border construction, materials, highlight placement, palette and small details. Do not improvise a generic fantasy header or add ornament that is absent from the reference. Separate static decoration from title lettering and buttons, which the addon renders independently. Current provisional export contract: EXACTLY 512 x 64 pixels, RGBA PNG, real transparent alpha, one isolated header asset. Keep x=20..430, y=8..48 clear for separate text. If the reference dimensions or text placement conflict with this provisional contract, report the required geometry changes before generating; do not stretch or redesign the reference to fit. No screenshot background, health fill, text, baked-in logos, checkerboard, atlas or contact sheet. A missing reference is a reason to request that reference, not to invent one. Image generation alone does not guarantee pixel-identical output; compare the result with the reference at native scale.
```
