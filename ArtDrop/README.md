Only overhead NAMEPLATE artwork from the seven games is requested, no HUD or GUI header.
Drop the PNGs named in ../ART_ASSET_REQUESTS.md here. Run:

    python Tools/import_art.py

For continuous detection: python Tools/import_art.py --watch
Original PNGs stay here. Validated TGA files go into ForeverNameplates/Media.
Rejects leave existing assets intact. Technical validation cannot establish art quality
or detect every fake checkerboard; always inspect transparency visually, too.

Classic now uses a 128x16 canvas with an offset 103x10 opening; see the contract.
Old output files with changed contract dimensions are preserved and marked obsolete.
