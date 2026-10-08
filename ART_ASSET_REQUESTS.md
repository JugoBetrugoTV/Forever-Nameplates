# Nameplate-Grafikaufträge — sieben Originalspiele

**Ausschließlich die Nameplates über Units**: WoW Classic, WoW Dragonflight, Guild Wars 2,
SWTOR, ESO, FFXIV und Diablo IV. Keine Target-Portraitframes, Player-HUDs, Bossleisten am
Bildschirmrand oder GUI-Header. Die früheren generischen Fantasy-Aufträge und der Studio-
Header gehören nicht mehr zum aktiven Grafikauftrag. Alte Asset-IDs bleiben für bestehende
Profile lesbar; die historischen Dateinamen sind keine Stilvorgaben.

## Bereits aus Quellen abgeleitet

Classic 1.15.8 und Dragonflight 10.2.7 wurden über gepinnte FrameXML-Tags untersucht.
Im Studio unter **Game nameplates** stehen zwei `source draft`-Layouts zur Verfügung.
Sie referenzieren clientseitige Nameplate-Texturen, ohne Spielgrafiken in das Repository zu kopieren.
Classic: Fill 103×10, Border 128×16 mit Level rechts. Dragonflight: Fill 86×4 und Castbar 86×8
bei Scale=1. Diese Maße sind strukturell nachgewiesen. Texturpixel und Darstellung im Forever-
Client sind nicht geprüft; deshalb ist dies noch keine bestätigte 1:1-Abnahme.

Für die fünf anderen Spiele scheiterten die Website-Abrufe am Cloud-Proxy mit HTTP 403.
Es wird kein erfundener Ersatz als Originaldesign angeboten. Ihre Canvas-/Fenstermaße bleiben
vorläufig, bis tatsächliche Nameplate-Bilder erreichbar sind. WoW-Importverträge wurden an die
bekannten Maße angepasst; Classic hat eine versetzte Healthöffnung statt einer zentrierten.

## Assets liefern und prüfen

Die separaten fertigen PNGs kommen vom Nutzer in `ArtDrop/`. `python Tools/import_art.py`
prüft Canvas, Alpha und die transparente Healthöffnung, erzeugt 32-Bit-TGA und bewahrt
vorhandene Dateien bei Fehlern. Alte Ausgaben mit nicht mehr passenden Vertragsmaßen werden
als obsolete markiert, nicht gelöscht. Der Nameplate-Katalog kennt die neuen Importmaße.
Die technischen Prüfungen messen keine Referenztreue.

Erzeugung: jeweils ORIGINAL-NAMEPLATE-CROP mit dem zugehörigen Prompt verwenden.
Ein Screenshot eines Targetframes gilt nicht als Nameplate-Vorlage. Rahmen, Fill, Namen,
Level, Icons und normaler/ausgewählter Zustand werden bei 100 % neben dem Original verglichen.
Schrift/Spacing, CVar-Scale und tatsächliche Client-Texturen gehören zur visuellen Prüfung.
**Kein Design wird derzeit als pixelidentisch bestätigt.** Originale Frames dürfen schlicht sein;
zusätzliche Fantasy-Ornamente verfälschen sie.

## World of Warcraft Classic — classic_frame.png

- Version: **1.15.8**.
- Status: `framexml_reconstructed_pixels_unverified`.
- Quelle: https://github.com/Gethe/wow-ui-source/blob/e0099491e5ce94ef87c791b053f1e1509b5fd7ac/Interface/AddOns/Blizzard_NamePlates/Vanilla/Blizzard_NamePlates.xml.
- Canvas: **128 × 16**; Healthöffnung: **103 × 10**; Box [4, 3, 107, 13].
- Kein fertiges PNG geliefert. Außer den zwei WoW-Maßen bleiben die Verträge vorläufig.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of World of Warcraft Classic version 1.15.8. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 128 x 16 pixels, RGBA PNG with real transparent alpha; geometry status: SOURCE-BASED. Transparent health-fill opening 103 x 10 pixels. Health opening bounding box (left, top, right, bottom): [4, 3, 107, 13]. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

## World of Warcraft Dragonflight — dragonflight_frame.png

- Version: **10.2.7**.
- Status: `framexml_reconstructed_pixels_unverified`.
- Quelle: https://github.com/Gethe/wow-ui-source/blob/6b65c2922baca3db5a28fb39b69c95cef1047bec/Interface/AddOns/Blizzard_NamePlates/Blizzard_NamePlates.xml.
- Canvas: **128 × 32**; Healthöffnung: **86 × 4**; zentriert.
- Kein fertiges PNG geliefert. Außer den zwei WoW-Maßen bleiben die Verträge vorläufig.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of World of Warcraft Dragonflight version 10.2.7. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 128 x 32 pixels, RGBA PNG with real transparent alpha; geometry status: SOURCE-BASED. Transparent health-fill opening 86 x 4 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

## Guild Wars 2 — guildwars_frame.png

- Version: **noch nicht verifiziert**.
- Status: `website_access_blocked`.
- Quelle: Originalseite vom Cloud-Proxy blockiert; kein bestätigtes Bild.
- Canvas: **256 × 64**; Healthöffnung: **174 × 12**; zentriert.
- Kein fertiges PNG geliefert. Außer den zwei WoW-Maßen bleiben die Verträge vorläufig.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of Guild Wars 2. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 256 x 64 pixels, RGBA PNG with real transparent alpha; geometry status: PROVISIONAL until the original nameplate is measured. Transparent health-fill opening 174 x 12 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

## Star Wars: The Old Republic — galactic_frame.png

- Version: **noch nicht verifiziert**.
- Status: `website_access_blocked`.
- Quelle: Originalseite vom Cloud-Proxy blockiert; kein bestätigtes Bild.
- Canvas: **256 × 64**; Healthöffnung: **176 × 8**; zentriert.
- Kein fertiges PNG geliefert. Außer den zwei WoW-Maßen bleiben die Verträge vorläufig.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of Star Wars: The Old Republic. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 256 x 64 pixels, RGBA PNG with real transparent alpha; geometry status: PROVISIONAL until the original nameplate is measured. Transparent health-fill opening 176 x 8 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

## Diablo IV — medieval_frame.png

- Version: **noch nicht verifiziert**.
- Status: `website_access_blocked`.
- Quelle: Originalseite vom Cloud-Proxy blockiert; kein bestätigtes Bild.
- Canvas: **256 × 64**; Healthöffnung: **158 × 18**; zentriert.
- Kein fertiges PNG geliefert. Außer den zwei WoW-Maßen bleiben die Verträge vorläufig.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of Diablo IV. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 256 x 64 pixels, RGBA PNG with real transparent alpha; geometry status: PROVISIONAL until the original nameplate is measured. Transparent health-fill opening 158 x 18 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

## Final Fantasy XIV — fantasy_frame.png

- Version: **noch nicht verifiziert**.
- Status: `website_access_blocked`.
- Quelle: Originalseite vom Cloud-Proxy blockiert; kein bestätigtes Bild.
- Canvas: **256 × 64**; Healthöffnung: **182 × 12**; zentriert.
- Kein fertiges PNG geliefert. Außer den zwei WoW-Maßen bleiben die Verträge vorläufig.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of Final Fantasy XIV. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 256 x 64 pixels, RGBA PNG with real transparent alpha; geometry status: PROVISIONAL until the original nameplate is measured. Transparent health-fill opening 182 x 12 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

## The Elder Scrolls Online — celestial_frame.png

- Version: **noch nicht verifiziert**.
- Status: `website_access_blocked`.
- Quelle: Originalseite vom Cloud-Proxy blockiert; kein bestätigtes Bild.
- Canvas: **256 × 64**; Healthöffnung: **182 × 6**; zentriert.
- Kein fertiges PNG geliefert. Außer den zwei WoW-Maßen bleiben die Verträge vorläufig.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of The Elder Scrolls Online. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 256 x 64 pixels, RGBA PNG with real transparent alpha; geometry status: PROVISIONAL until the original nameplate is measured. Transparent health-fill opening 182 x 6 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```
