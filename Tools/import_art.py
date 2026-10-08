"""Validate user-supplied PNGs and publish uncompressed 32-bit WoW TGA assets."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import tempfile
import os
import time
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = Path(__file__).with_name("art_requests.json")

def atomic_write(path: Path, data: bytes):
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as f:
        temporary = Path(f.name)
        f.write(data)
    try:
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)

def validate(source: Path, spec: dict) -> Image.Image:
    if source.is_symlink() or source.stat().st_size > 20 * 1024 * 1024:
        raise ValueError("Symlinks and images larger than 20 MiB are rejected")
    with Image.open(source) as original:
        if original.format != "PNG" or original.size != (spec["width"], spec["height"]):
            raise ValueError(f"Expected PNG {spec['width']}x{spec['height']}; got {original.format} {original.size}")
        if "A" not in original.getbands():
            raise ValueError("An explicit alpha channel is required")
        image = original.convert("RGBA")
    low, high = image.getchannel("A").getextrema()
    if low == 255 or high == 0:
        raise ValueError("Image is entirely opaque or invisible; genuine transparency is required")
    if spec.get("window"):
        w, h = spec["window"]
        x, y = image.width // 2, image.height // 2
        box = spec.get("window_box", (x-w//2, y-h//2, x+(w+1)//2, y+(h+1)//2))
        if (len(box) != 4 or any(type(v) is not int for v in box)
                or box[2]-box[0] != w or box[3]-box[1] != h
                or not (0 <= box[0] < box[2] <= image.width and 0 <= box[1] < box[3] <= image.height)):
            raise ValueError("Invalid health-fill window box")
        values = list(image.getchannel("A").crop(box).getdata())
        if sum(v < 16 for v in values) / len(values) < .95:
            raise ValueError("Health-fill window must be at least 95% transparent")
    return image

def run(drop: Path, addon: Path, contract: Path = CONTRACT) -> tuple[int, list[str]]:
    specs = {s["file"]: s for s in json.loads(contract.read_text())["assets"]}
    media = addon / "Media"
    manifest_path = media / "manifest.json"
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {"version": 1, "assets": {}}
    messages, errors = [], 0
    drop.mkdir(parents=True, exist_ok=True)
    for source in sorted(drop.iterdir()):
        if source.name == "README.md":
            continue
        if source.name not in specs or not source.is_file():
            messages.append(f"REJECT {source.name}: unknown filename; see ART_ASSET_REQUESTS.md")
            errors += 1
            continue
        spec = specs[source.name]
        try:
            image = validate(source, spec)
            digest = hashlib.sha256(source.read_bytes()).hexdigest()
            old = manifest["assets"].get(spec["id"], {})
            target = media / (spec["id"] + ".tga")
            if old.get("status") == "imported" and old.get("source_sha256") == digest and target.exists() and hashlib.sha256(target.read_bytes()).hexdigest() == old.get("sha256"):
                continue
            import io
            buffer = io.BytesIO()
            image.save(buffer, format="TGA", compression=None)
            payload = buffer.getvalue()
            atomic_write(target, payload)
            manifest["assets"][spec["id"]] = {
                "file": target.name, "width": image.width, "height": image.height,
                "source_sha256": digest, "sha256": hashlib.sha256(payload).hexdigest(), "status": "imported",
            }
            messages.append(f"IMPORTED {source.name} -> {target.name}; visual inspection still required")
        except (ValueError, OSError, Image.DecompressionBombError) as exc:
            errors += 1
            messages.append(f"REJECT {source.name}: {exc}")
    known = {s["id"] for s in specs.values()}
    specs_by_id = {s["id"]: s for s in specs.values()}
    for key, item in manifest["assets"].items():
        # A replaced contract or missing/damaged output marks stale entries, never deletes them.
        filename = item.get("file", "")
        valid_filename = filename == key + ".tga" and key in known
        target = media / filename if valid_filename else None
        dimensions_match = (key in known and item.get("width") == specs_by_id[key]["width"]
                            and item.get("height") == specs_by_id[key]["height"])
        if not dimensions_match or target is None or not target.is_file() or target.is_symlink() or hashlib.sha256(target.read_bytes()).hexdigest() != item.get("sha256"):
            item["status"] = "obsolete"
            messages.append(f"OBSOLETE {key}: output missing, altered or outside current contract dimensions")
    for key in sorted(known):
        if key not in manifest["assets"] or manifest["assets"][key]["status"] != "imported":
            messages.append(f"MISSING {key}: procedural fallback remains active")
    rows = ['-- Generated by Tools/import_art.py; no user-provided Lua is evaluated.', 'local _, NS = ...', 'NS.Media = {files={']
    for key, item in sorted(manifest["assets"].items()):
        if key in known and item["status"] == "imported":
            rows.append(f'    ["{key}"]="{item["file"]}",')
    rows.append('}}')
    atomic_write(media / "Assets.lua", ("\n".join(rows) + "\n").encode())
    atomic_write(manifest_path, (json.dumps(manifest, indent=2, sort_keys=True) + "\n").encode())
    return errors, messages

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--drop", type=Path, default=ROOT / "ArtDrop")
    parser.add_argument("--addon", type=Path, default=ROOT / "ForeverNameplates")
    parser.add_argument("--watch", action="store_true", help="Check for new assets every two seconds; Ctrl+C to stop")
    args = parser.parse_args()
    while True:
        errors, messages = run(args.drop, args.addon)
        print("\n".join(messages))
        if not args.watch:
            return min(errors, 1)
        time.sleep(2)

if __name__ == "__main__":
    raise SystemExit(main())
