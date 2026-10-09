Forever Nameplates 0.10.0 - development build

Install this folder into _classic_beta_/Interface/AddOns/ForeverNameplates.
Use /fnp or /forevernameplates to open the studio.
After updating, use /reload, then /fnp apply outside combat to apply your current layout.
Live application is enabled on first upgrade from the old preview mode; later opt-outs persist.
Use /fnp off to restore Blizzard visuals, or /fnp status to inspect application/fallback reasons.
Numeric settings use sliders, +/-, and mouse wheel. Slider movement previews locally;
release saves one undo step. Click away to commit typed numbers/text; Escape cancels.
Right-click overlapping elements to select a layer. Font styles and native textures are selectable.
Component visibility conditions, minimap visibility/angle and Create copy are available in the GUI.
Use the header search to find settings and click a result to open/highlight its control.
Hover controls for help and numeric bounds. Anchors / auras / casts has mouse controls,
a live local preview and Undo/Redo. Add Aura / debuff icons using + Add component.
Relative anchors keep components at a referenced bar edge; Snap zeros their offsets.
Aura rows support client buff/debuff/own filters and sorting, up to 12 icons, columns,
size, spacing, public spell-ID lists and client cooldown swipes. Missing/restricted data hides icons.
Cast state colors and a native spark are optional. The spark follows the fill texture.
Health, cast and aura events update relevant parts; additional GUI pages build on first visit.
New features require 0.10.0 and FN3 codes. Older layouts still export FN2; FN1/FN2 import remains supported.
SavedVariables migrate to version 3; older addons reject the newer database.
GUI skins persist. Profile names, custom text and share codes still require text entry.

This build has been checked in a Lua 5.1 widget simulator, NOT in a running game client.
Forever Beta 1.60.1, Interface 16001 is the intended target. Protected/forbidden nameplates
are skipped and first widget creation during combat is deferred until combat ends.
Successful live application suppresses the permitted Blizzard UnitFrame; removal, off and
rendering failure restore its last public alpha. Client visibility and public fades are respected.
Add Class icon, Cast icon or Interrupt shield in Layout Studio via + Add component. Position and size are editable.
Optional icons use public client resources; missing/secret icons are hidden. Cast icons follow castbar visibility.
Unused text/cast metadata queries are skipped without caching unit identity or secret health.
Class/Cast icons require 0.7.0 to import; Interrupt shield requires 0.8.0. Older layouts remain readable.
Interrupt shield shows only publicly confirmed non-interruptible casts/channels; secret status remains unknown.
Channels use remaining-time direction; absent public direction enums hide the channelbar.
Global target/raid/level events update only layouts that need them.
Classic levels use public client difficulty colors and a native skull for unknown high levels.
Missing skull textures fall back to ??; secret levels are omitted.
Classic/Dragonflight source drafts use client resources; the old presets are placeholders.
FFXIV requires three imported assets. The other four games still lack verified nameplate references.
No layout has a confirmed 1:1 comparison in the Forever client.

Beta SavedVariables loading may be broken on your client build. Export your profile and
keep the share code in an external text file before restarting the client.

Development sources, API audit, test checklist and artwork requests are in the repository:
https://github.com/JugoBetrugoTV/Forever-Nameplates

Bundled libraries: LibStub (Public Domain), LibDeflate 1.0.2-release (zlib license).
Their upstream license notices are preserved in Libraries.
