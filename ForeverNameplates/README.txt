Forever Nameplates 0.6.2 - development build

Install this folder into _classic_beta_/Interface/AddOns/ForeverNameplates.
Use /fnp or /forevernameplates to open the studio.
After updating, use /reload, then /fnp apply outside combat to apply your current layout.
Live application is enabled on first upgrade from the old preview mode; later opt-outs persist.
Use /fnp off to restore Blizzard visuals, or /fnp status to inspect application/fallback reasons.

This build has been checked in a Lua 5.1 widget simulator, NOT in a running game client.
Forever Beta 1.60.1, Interface 16001 is the intended target. Protected/forbidden nameplates
are skipped and first widget creation during combat is deferred until combat ends.
Successful live application suppresses the permitted Blizzard UnitFrame; removal, off and
rendering failure restore its last public alpha. Client visibility and public fades are respected.
Classic/Dragonflight source drafts use client resources; the old presets are placeholders.
FFXIV requires three imported assets. The other four games still lack verified nameplate references.
No layout has a confirmed 1:1 comparison in the Forever client.

Beta SavedVariables loading may be broken on your client build. Export your profile and
keep the share code in an external text file before restarting the client.

Development sources, API audit, test checklist and artwork requests are in the repository:
https://github.com/JugoBetrugoTV/Forever-Nameplates

Bundled libraries: LibStub (Public Domain), LibDeflate 1.0.2-release (zlib license).
Their upstream license notices are preserved in Libraries.
