Forever Nameplates 0.2.0 - development build

Install this folder into _classic_beta_/Interface/AddOns/ForeverNameplates.
Use /fnp or /forevernameplates to open the studio.
Enable experimental live overlays under Diagnostics; default nameplates remain visible.

This build has been checked in a Lua 5.1 widget simulator, NOT in a running game client.
Forever Beta 1.60.1, Interface 16001 is the intended target. Protected/forbidden nameplates
are skipped and new overlays during combat are deferred until combat ends.
Original artwork is pending; current layouts use procedural placeholders.

Beta SavedVariables loading may be broken on your client build. Export your profile and
keep the share code in an external text file before restarting the client.

Development sources, API audit, test checklist and artwork requests are in the repository:
https://github.com/JugoBetrugoTV/Forever-Nameplates

Bundled libraries: LibStub (Public Domain), LibDeflate 1.0.2-release (zlib license).
Their upstream license notices are preserved in Libraries.
