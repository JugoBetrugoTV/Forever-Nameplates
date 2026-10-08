"""Create an installable ZIP containing only the addon and its bundled libraries."""
from pathlib import Path
import zipfile

root = Path(__file__).resolve().parents[1]
addon = root / "ForeverNameplates"
output = root / "dist" / "ForeverNameplates-0.1.0.zip"
output.parent.mkdir(exist_ok=True)
with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as archive:
    for file in sorted(addon.rglob("*")):
        if file.is_file():
            archive.write(file, file.relative_to(root))
print(output)
