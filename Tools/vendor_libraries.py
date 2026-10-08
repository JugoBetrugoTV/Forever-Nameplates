"""Verify bundled libraries or refresh their exact pinned upstream versions."""
import argparse
import hashlib
import json
from pathlib import Path
from urllib.request import urlopen
from import_art import atomic_write

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--refresh", action="store_true")
args = parser.parse_args()
entries = json.loads(Path(__file__).with_name("libraries.json").read_text())["libraries"]
pending = []
for item in entries:
    target = root / "ForeverNameplates/Libraries" / item["file"]
    if args.refresh:
        url = f'https://raw.githubusercontent.com/{item["repository"]}/{item["commit"]}/{item["path"]}'
        with urlopen(url, timeout=30) as response:
            payload = response.read(2 * 1024 * 1024)
    else:
        payload = target.read_bytes()
    if hashlib.sha256(payload).hexdigest() != item["sha256"]:
        raise SystemExit(f'Checksum mismatch: {item["file"]}; files have not been replaced')
    pending.append((target, payload))
if args.refresh:
    for target, payload in pending:
        atomic_write(target, payload)
for target, _ in pending:
    print(f"VERIFIED {target.name}")
