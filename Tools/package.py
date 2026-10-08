"""Create an installable ZIP containing only the addon and its bundled libraries."""
from pathlib import Path
import re
import tempfile
import zipfile

root = Path(__file__).resolve().parents[1]
addon = root / "ForeverNameplates"
toc = (addon / "ForeverNameplates.toc").read_text()
match = re.search(r"^## Version: (\d+\.\d+\.\d+)$", toc, re.MULTILINE)
if not match:
    raise SystemExit("Missing semantic version in TOC")
output = root / "dist" / f"ForeverNameplates-{match.group(1)}.zip"
output.parent.mkdir(exist_ok=True)
files = sorted(addon.rglob("*"))
if any(file.is_symlink() for file in files):
    raise SystemExit("Symlinks are not allowed in the addon package")
with tempfile.TemporaryDirectory(dir=output.parent) as temporary:
    pending = Path(temporary) / output.name
    with zipfile.ZipFile(pending, "w", zipfile.ZIP_DEFLATED) as archive:
        for file in files:
            if not file.is_file():
                continue
            archive.write(file, file.relative_to(root))
    pending.replace(output)
print(output)
