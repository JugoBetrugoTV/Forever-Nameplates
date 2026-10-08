"""Check required API signatures exist in the pinned Forever reference, not in a live client."""
import argparse
from pathlib import Path

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--reference", type=Path, default=root.parent / "research/forever-api")
args = parser.parse_args()
docs = args.reference / "docs/api"
required = {
    "UI-Systems-Input/C_NamePlate.md": ["C_NamePlate.GetNamePlateForUnit"],
    "UI-Widgets-Frames/SimpleStatusBarAPI.md": ["SimpleStatusBarAPI.SetValue", "SimpleStatusBarAPI.SetMinMaxValues", "SimpleStatusBarAPI.SetTimerDuration", "SimpleStatusBarAPI.SetOrientation", "SimpleStatusBarAPI.SetReverseFill"],
    "UI-Widgets-Frames/SimpleTextureBaseAPI.md": ["SimpleTextureBaseAPI.SetRotation", "SimpleTextureBaseAPI.SetTexture"],
    "UI-Widgets-Frames/SimpleFrameAPI.md": ["SimpleFrameAPI.CreateMaskTexture", "SimpleFrameAPI.RegisterEvent"],
    "UI-Widgets-Frames/SimpleFontStringAPI.md": ["SimpleFontStringAPI.SetText", "SimpleFontStringAPI.SetFont"],
    "Units-Combat-PvP/Unit.md": ["Unit.UnitHealth", "Unit.UnitHealthMax", "Unit.UnitCastingDuration", "Unit.UnitChannelDuration"],
}
count = 0
for filename, names in required.items():
    text = (docs / filename).read_text()
    for name in names:
        if f"### {name}\n" not in text:
            raise SystemExit(f"Missing API signature: {name}")
        count += 1
print(f"{count} required/researched signatures present; runtime permissions and in-game behavior remain unverified")
