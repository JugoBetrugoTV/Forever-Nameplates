# Nameplate-Grafikaufträge — sieben Originalspiele

Ausschließlich Nameplates über Units aus WoW Classic, Dragonflight, GW2, SWTOR, ESO, FFXIV und Diablo IV.
Keine Target-Portraitframes, Player-HUDs, Bossleisten am Bildschirmrand oder GUI-Artwork.
Die Liste enthält sieben Rahmen sowie die separat nötige FFXIV-HP-Füllung und den Gegnerindikator.

## Originalreferenzen und Maßstab

Classic/Dragonflight beruhen auf gepinnten FrameXML-Definitionen. Die vier offiziellen FFXIV-Bilder
wurden heruntergeladen und angesehen. [Originalbilder und Vermessung](docs/INTERNET_IMAGE_REFERENCES.md).
Die FFXIV-Maße beziehen sich auf JPEG-Pixel; Patch/UI-Scale sind unbekannt, Kanten etwa ±2 Pixel unsicher.
Der FFXIV-Entwurf bildet die rote beanspruchte Gegner-Plate ab. Originalschrift, Spawn-Buchstabe und
automatische FFXIV-Claim-Zustände sind im WoW-Client nicht nachgewiesen. Keine 1:1-Abnahme behauptet.
Die anderen vier Fremdspiel-Referenzen fehlen weiterhin; deren Maße sind vorläufig.

## Assets liefern

Jeweils das tatsächliche ORIGINAL-NAMEPLATE-BILD zusammen mit dem Prompt an den Bildgenerator anhängen.
Ein Markdown-Link allein liefert keine Referenzpixel. Die offiziellen FFXIV-JPEGs sind unten verlinkt.
Die fertigen PNGs in `ArtDrop/` ablegen, `python Tools/import_art.py` ausführen und im Spiel `/reload`.
Der FFXIV-Eintrag wird erst mit `fantasy_frame.png`, `ffxiv_hp_fill.png` und `ffxiv_enemy_icon.png` auswählbar.
Rahmen/Icons benötigen echte Transparenz; die HP-Füllung benötigt vollständig deckende RGBA-Pixel.
Fehler bewahren vorhandene Dateien. Frühere Vertragsmaße werden als obsolete markiert und nicht gelöscht.
Technische PNG- und Alpha-Prüfungen bestätigen keine Originaltreue; bei 100 % neben der Vorlage vergleichen.

Diese Datei entsteht aus `Tools/art_requests.json`: `python Tools/art_prompts.py`.

## Batch 1

### World of Warcraft Classic — classic_frame.png

- Version: **1.15.8**.
- Status: `framexml_reconstructed_pixels_unverified`.
- Canvas: **128 × 16**.
- Aufgabe: Frame of the overhead unit NAMEPLATE only.
- Alpha: echte Transparenz.
- Healthöffnung: **103 × 10**; Box `[4, 3, 107, 13]`.
- [Quelle](https://github.com/Gethe/wow-ui-source/blob/e0099491e5ce94ef87c791b053f1e1509b5fd7ac/Interface/AddOns/Blizzard_NamePlates/Vanilla/Blizzard_NamePlates.xml).

```text
Reconstruct ONLY the overhead unit NAMEPLATE of World of Warcraft Classic version 1.15.8. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 128 x 16 pixels, RGBA PNG with real transparent alpha; geometry status: SOURCE-BASED. Transparent health-fill opening 103 x 10 pixels. Health opening bounding box (left, top, right, bottom): [4, 3, 107, 13]. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

### World of Warcraft Dragonflight — dragonflight_frame.png

- Version: **10.2.7**.
- Status: `framexml_reconstructed_pixels_unverified`.
- Canvas: **128 × 32**.
- Aufgabe: Frame of the overhead unit NAMEPLATE only.
- Alpha: echte Transparenz.
- Healthöffnung: **86 × 4**; zentriert.
- [Quelle](https://github.com/Gethe/wow-ui-source/blob/6b65c2922baca3db5a28fb39b69c95cef1047bec/Interface/AddOns/Blizzard_NamePlates/Blizzard_NamePlates.xml).

```text
Reconstruct ONLY the overhead unit NAMEPLATE of World of Warcraft Dragonflight version 10.2.7. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 128 x 32 pixels, RGBA PNG with real transparent alpha; geometry status: SOURCE-BASED. Transparent health-fill opening 86 x 4 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

### Final Fantasy XIV — fantasy_frame.png

- Version: **noch nicht verifiziert**.
- Status: `official_images_inspected_geometry_measured`.
- Canvas: **256 × 32**.
- Aufgabe: Frame of the overhead unit NAMEPLATE only.
- Alpha: echte Transparenz.
- Healthöffnung: **236 × 12**; Box `[10, 10, 246, 22]`.
- [Quelle](https://na.finalfantasyxiv.com/uiguide/battle/battle-np/battle_np_bar.html).
- Originalbilder: [Bild 1](https://lds-img.finalfantasyxiv.com/uiguide/na/5e/9e139cf87504d0b6e816c272c1515abd38faed.jpg) · [Bild 2](https://lds-img.finalfantasyxiv.com/uiguide/na/51/66741e445c904df9cd7f06f839b03551192e53.jpg) · [Bild 3](https://lds-img.finalfantasyxiv.com/uiguide/na/71/bfd57bcf3542c45e03da53cefbd8999f9d1057.jpg) · [Bild 4](https://lds-img.finalfantasyxiv.com/uiguide/na/37/0faba07d80ef234d73f8e584613faf85630ff5.jpg).

```text
Use the attached OFFICIAL FFXIV overhead enemy NAMEPLATE image, the red/pink Claimed by you or your party Lost Lamb example. Reconstruct ONLY the static HP-bar border and soft shadow, not a fantasy frame. The downloaded reference is 896 x 192 JPEG pixels. Working measurement: outer bar/shadow box [334,102,582,122], body [336,104,580,120], fill window [340,106,576,118]; JPEG edges have approximately +/-2 pixel uncertainty and in-game UI scale is unknown. Preserve the simple thin burgundy outline, small softened corners and dark offset shadow. NO wings, gems, emblems or invented ornaments. Export fantasy_frame.png, RGBA with real transparent alpha, 256 x 32 pixels. Place the 248 x 20 outer bar at [4,6,252,26], keeping the 236 x 12 health opening transparent at [10,10,246,22]. Canvas padding is export padding, not original decoration. Remove screenshot background, HP fill, text, level, letters and skull icon; those are separate runtime elements/assets. Do not copy a target HUD or a screen-wide boss bar. If closer inspection changes the working geometry, report it instead of stretching the reference. Provide one isolated border only, no contact sheet or checkerboard. This reconstructed output must be compared at source scale before it is accepted as a match.
```

### Final Fantasy XIV — ffxiv_hp_fill.png

- Version: **noch nicht verifiziert**.
- Status: `official_images_inspected_geometry_measured`.
- Canvas: **236 × 12**.
- Aufgabe: Dynamic fill texture of the overhead enemy NAMEPLATE.
- Alpha: vollständig deckendes RGBA, alpha=255.
- [Quelle](https://na.finalfantasyxiv.com/uiguide/battle/battle-np/battle_np_bar.html).
- Originalbilder: [Bild 1](https://lds-img.finalfantasyxiv.com/uiguide/na/5e/9e139cf87504d0b6e816c272c1515abd38faed.jpg) · [Bild 2](https://lds-img.finalfantasyxiv.com/uiguide/na/51/66741e445c904df9cd7f06f839b03551192e53.jpg) · [Bild 3](https://lds-img.finalfantasyxiv.com/uiguide/na/71/bfd57bcf3542c45e03da53cefbd8999f9d1057.jpg) · [Bild 4](https://lds-img.finalfantasyxiv.com/uiguide/na/37/0faba07d80ef234d73f8e584613faf85630ff5.jpg).

```text
Use the attached OFFICIAL FFXIV overhead enemy NAMEPLATE image, the red/pink Claimed by you or your party Lost Lamb example. Reference: https://lds-img.finalfantasyxiv.com/uiguide/na/51/66741e445c904df9cd7f06f839b03551192e53.jpg. Use the supplied image pixels as the binding reference; the URL alone does not attach an image. Reconstruct ONLY the light pink health FILL texture, expanded horizontally to its full 236 x 12 working interior dimensions. The visible filled section in the source is only a partial HP value: do not bake the empty burgundy remainder or the current health percentage into the texture. Preserve the subtle vertical highlight, approximately RGB(234,170,171) at the top and RGB(253,187,189) through the main body; these are JPEG observations, not authoritative client RGB values. No border, end caps, shadow, letters, numbers, skull, HUD, screenshot background or transparency inside the fill. Export ffxiv_hp_fill.png as 236 x 12 RGBA PNG with alpha 255 at every pixel. Do not generate an ornate frame or generic red-to-green gradient. The runtime StatusBar supplies clipping and the separate frame supplies the outline. If reference geometry differs on closer inspection, report it before export.
```

### Final Fantasy XIV — ffxiv_enemy_icon.png

- Version: **noch nicht verifiziert**.
- Status: `official_images_inspected_geometry_measured`.
- Canvas: **32 × 32**.
- Aufgabe: Small cyan enemy indicator on the overhead NAMEPLATE.
- Alpha: echte Transparenz.
- [Quelle](https://na.finalfantasyxiv.com/uiguide/battle/battle-np/battle_np_bar.html).
- Originalbilder: [Bild 1](https://lds-img.finalfantasyxiv.com/uiguide/na/5e/9e139cf87504d0b6e816c272c1515abd38faed.jpg) · [Bild 2](https://lds-img.finalfantasyxiv.com/uiguide/na/51/66741e445c904df9cd7f06f839b03551192e53.jpg) · [Bild 3](https://lds-img.finalfantasyxiv.com/uiguide/na/71/bfd57bcf3542c45e03da53cefbd8999f9d1057.jpg) · [Bild 4](https://lds-img.finalfantasyxiv.com/uiguide/na/37/0faba07d80ef234d73f8e584613faf85630ff5.jpg).

```text
Use the attached OFFICIAL FFXIV overhead enemy NAMEPLATE image, the red/pink Claimed by you or your party Lost Lamb example. Reference: https://lds-img.finalfantasyxiv.com/uiguide/na/51/66741e445c904df9cd7f06f839b03551192e53.jpg. Use the supplied image pixels as the binding reference; the URL alone does not attach an image. Reconstruct ONLY the small cyan enemy/skull indicator immediately before the level. Working source box is approximately [278,74,304,104] in the 896 x 192 JPEG; preserve the actual rounded cyan silhouette, light center and soft glow without inventing a Warcraft skull or raid marker. Export ffxiv_enemy_icon.png on a 32 x 32 RGBA transparent canvas, center the measured approximately 26 x 30 indicator without stretching. Keep outside pixels truly transparent. No text, level, health bar, background, portrait, UI window, checkerboard, contact sheet or new ornament. This icon is separate from raid markers. Compare at source scale; JPEG edges and unspecified game scale prevent automatic pixel-identity claims.
```

## Batch 2

### Guild Wars 2 — guildwars_frame.png

- Version: **noch nicht verifiziert**.
- Status: `website_access_blocked`.
- Canvas: **256 × 64**.
- Aufgabe: Frame of the overhead unit NAMEPLATE only.
- Alpha: echte Transparenz.
- Healthöffnung: **174 × 12**; zentriert.
- Originalreferenz fehlt; keine bestätigte Bildgeometrie.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of Guild Wars 2. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 256 x 64 pixels, RGBA PNG with real transparent alpha; geometry status: PROVISIONAL until the original nameplate is measured. Transparent health-fill opening 174 x 12 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

### Star Wars: The Old Republic — galactic_frame.png

- Version: **noch nicht verifiziert**.
- Status: `website_access_blocked`.
- Canvas: **256 × 64**.
- Aufgabe: Frame of the overhead unit NAMEPLATE only.
- Alpha: echte Transparenz.
- Healthöffnung: **176 × 8**; zentriert.
- Originalreferenz fehlt; keine bestätigte Bildgeometrie.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of Star Wars: The Old Republic. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 256 x 64 pixels, RGBA PNG with real transparent alpha; geometry status: PROVISIONAL until the original nameplate is measured. Transparent health-fill opening 176 x 8 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

### Diablo IV — medieval_frame.png

- Version: **noch nicht verifiziert**.
- Status: `original_reference_unverified`.
- Canvas: **256 × 64**.
- Aufgabe: Frame of the overhead unit NAMEPLATE only.
- Alpha: echte Transparenz.
- Healthöffnung: **158 × 18**; zentriert.
- Originalreferenz fehlt; keine bestätigte Bildgeometrie.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of Diablo IV. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 256 x 64 pixels, RGBA PNG with real transparent alpha; geometry status: PROVISIONAL until the original nameplate is measured. Transparent health-fill opening 158 x 18 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```

### The Elder Scrolls Online — celestial_frame.png

- Version: **noch nicht verifiziert**.
- Status: `original_reference_unverified`.
- Canvas: **256 × 64**.
- Aufgabe: Frame of the overhead unit NAMEPLATE only.
- Alpha: echte Transparenz.
- Healthöffnung: **182 × 6**; zentriert.
- Originalreferenz fehlt; keine bestätigte Bildgeometrie.

```text
Reconstruct ONLY the overhead unit NAMEPLATE of The Elder Scrolls Online. Use the attached ORIGINAL NAMEPLATE crop as binding pixel reference. Preserve exact silhouette, edge construction, border thickness, corner shape, material, highlights, color, and ornament position. Only reconstruct features actually present on that original overhead nameplate. No target portrait frame, player HUD, action bar, world-boss screen header, inventory panel, editor interface or logos. Do not reinterpret a target frame as a nameplate. No generic MMORPG frame, invented wings, diamonds, runes, foliage or thematic recoloring. Export static decoration only; health fill, name, numbers, level and icons are separate runtime elements. Export canvas 256 x 64 pixels, RGBA PNG with real transparent alpha; geometry status: PROVISIONAL until the original nameplate is measured. Transparent health-fill opening 182 x 6 pixels. Do not distort original geometry to fit a provisional export contract; report measured original dimensions first if they differ. One isolated frame only, no screenshot background, baked lettering, health fill, checkerboard, atlas or contact sheet. If the original nameplate has no ornate frame, preserve its simple original contour; do not invent decoration to make it look premium. If the reference image is missing, ask for it rather than fabricate the game design. FrameXML structure alone is not a visual reference for pixel-identical artwork; generated output requires native-scale comparison against original pixels.
```
