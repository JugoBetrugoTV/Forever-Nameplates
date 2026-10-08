Drop the PNGs named in ../ART_ASSET_REQUESTS.md here. Run:

    python Tools/import_art.py

For continuous detection: python Tools/import_art.py --watch
Original PNGs stay here. Validated TGA files go into ForeverNameplates/Media.
Rejects leave existing assets intact. Technical validation cannot establish art quality
or detect every fake checkerboard; always inspect transparency visually, too.
