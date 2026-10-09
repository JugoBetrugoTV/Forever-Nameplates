# Forever Nameplates development

The repository owner requests ongoing development and wants validated changes committed
and pushed directly to the existing `origin/main`. Keep that publishing preference unless
the owner changes it. Verify origin identity and remote state, commit coherent changes,
and push normally; never force-push or discard someone else's changes.

Each cloud task is already isolated. Use this checkout; do not create a Git worktree unless
the user asks. Inspect and preserve existing changes before editing.

ReferenceAddons/Plater is a pinned comparison submodule outside the runtime addon.
For source comparisons, initialize it with `git submodule update --init ReferenceAddons/Plater`
if needed. Keep its pinned commit and upstream files unchanged unless updating the reference
is explicitly requested. Normal tests/packaging do not require the submodule.

Target WoW Forever Beta 1.60.1, Interface 16001, using its modern client-specific API.
Read README.md, PROGRESS.md and docs/API_AUDIT.md. No game client is installed here.
Never claim an in-game result from the Lua mock; distinguish API documentation, mock tests
and actual client behavior. Do not circumvent secret values or protected-frame restrictions.

Run functional checks with `/workspace/forever-tools/bin/python -m pytest -q` when available,
otherwise create a local venv and install requirements-dev.lock. Verify bundled libraries
with `python Tools/vendor_libraries.py`, check generated prompts with
`python Tools/art_prompts.py --check`, then package with `python Tools/package.py`.
The GitHub workflow repeats tests and packaging; do not report a remote CI pass without evidence.

The owner requests ONLY overhead unit nameplates from WoW Classic, Dragonflight, Guild Wars 2,
SWTOR, ESO, FFXIV and Diablo IV, matching their originals. Do not substitute target portraits,
player HUDs, screen-wide boss bars or new editor artwork. Generic-inspired designs do not satisfy
this scope. Read docs/NAMEPLATE_REFERENCES.md and docs/INTERNET_IMAGE_REFERENCES.md for current sources and access evidence. Four FFXIV originals are now inspected; its red-plate geometry is a JPEG measurement with unknown patch/UI scale and a local font fallback, not a confirmed match. Require all three imported FFXIV assets before enabling its menu choice. Exact game versions and screenshots/links are required before
claiming a matched design. The existing presets and AI illustration are placeholders, not
reference-accurate or approved visuals. Use reference-bound ART_ASSET_REQUESTS.md prompts;
do not invent a source or promise pixel identity from image generation. If reference geometry
differs, change the contract/layout rather than distorting the design.

Artwork comes from the owner separately. Keep ART_ASSET_REQUESTS.md accurate; use procedural
fallbacks until real assets arrive. Import only requested files through Tools/import_art.py.
Do not substitute generated-looking placeholders for completed art or copy game graphics.

For a version bump keep both TOCs, Core/Namespace.lua, user docs and PROGRESS.md consistent.
Tools/package.py derives the ZIP version from the TOC. Update the in-game checklist when a
feature needs client validation. SavedVariables and FN1/FN2/FN3 share-code schemas are versioned;
preserve compatibility and validation when changing them.
