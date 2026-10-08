"""Check required API signatures exist in the pinned Forever reference, not in a live client."""
import argparse
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--reference", type=Path, default=root.parent / "research/forever-api")
parser.add_argument("--kit", type=Path, default=root.parent / "research/forever-addon-kit")
args = parser.parse_args()
docs = args.reference / "docs/api"
required = {
    "Guild-Social-Chat/RaidMarkers.md": ["RaidMarkers.GetRaidTargetIndex"],
    "UI-Widgets-Frames/C_Texture.md": ["C_Texture.GetAtlasInfo"],
    "System-Config/C_Secrets.md": ["C_Secrets.ShouldUnitIdentityBeSecret"],
    "UI-Systems-Input/C_NamePlate.md": ["C_NamePlate.GetNamePlateForUnit"],
    "UI-Widgets-Frames/SimpleStatusBarAPI.md": ["SimpleStatusBarAPI.SetValue", "SimpleStatusBarAPI.SetMinMaxValues", "SimpleStatusBarAPI.SetTimerDuration", "SimpleStatusBarAPI.SetOrientation", "SimpleStatusBarAPI.SetReverseFill", "SimpleStatusBarAPI.SetStatusBarTexture"],
    "UI-Widgets-Frames/SimpleTextureBaseAPI.md": ["SimpleTextureBaseAPI.SetRotation", "SimpleTextureBaseAPI.SetTexture", "SimpleTextureBaseAPI.SetTexCoord", "SimpleTextureBaseAPI.SetBlendMode", "SimpleTextureBaseAPI.SetAtlas"],
    "UI-Widgets-Frames/SimpleFrameAPI.md": ["SimpleFrameAPI.CreateMaskTexture", "SimpleFrameAPI.RegisterEvent", "SimpleFrameAPI.SetClipsChildren"],
    "UI-Widgets-Frames/SimpleButtonAPI.md": ["SimpleButtonAPI.IsEnabled", "SimpleButtonAPI.RegisterForClicks", "SimpleButtonAPI.SetHighlightTexture"],
    "UI-Widgets-Frames/SimpleEditBoxAPI.md": ["SimpleEditBoxAPI.SetFont"],
    "UI-Widgets-Frames/SimpleScriptRegionAPI.md": ["SimpleScriptRegionAPI.GetCenter", "SimpleScriptRegionAPI.GetWidth"],
    "UI-Widgets-Frames/SimpleFontStringAPI.md": ["SimpleFontStringAPI.SetText", "SimpleFontStringAPI.SetFont", "SimpleFontStringAPI.SetShadowColor", "SimpleFontStringAPI.SetShadowOffset"],
    "Units-Combat-PvP/Unit.md": ["Unit.UnitHealth", "Unit.UnitHealthMax", "Unit.UnitCastingDuration", "Unit.UnitChannelDuration", "Unit.UnitClassBase", "Unit.UnitClassification", "Unit.UnitReaction", "Unit.UnitIsPlayer", "Unit.UnitPlayerControlled"],
}
count = 0
for filename, names in required.items():
    text = (docs / filename).read_text()
    for name in names:
        if f"### {name}\n" not in text:
            raise SystemExit(f"Missing API signature: {name}")
        count += 1
print(f"{count} required/researched signatures present; runtime permissions and in-game behavior remain unverified")

export = args.kit / "data/forever_api.json"
if export.is_file():
    if "SetRaidTargetIconTexture" not in json.loads(export.read_text())["functions"]:
        raise SystemExit("Client UI helper missing from Forever export")
    print("SetRaidTargetIconTexture present in Forever kit's client export; runtime atlas behavior remains unverified")
else:
    print("Forever kit export unavailable: native raid helper presence not checked")
