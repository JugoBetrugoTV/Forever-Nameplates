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
    "UI-Systems-Input/C_NamePlate.md": ["C_NamePlate.GetNamePlateForUnit", "C_NamePlate.GetNamePlates"],
    "AddOns-Scripting/C_Timer.md": ["C_Timer.After"],
    "UI-Widgets-Frames/SimpleFrameScriptObjectAPI.md": ["SimpleFrameScriptObjectAPI.IsForbidden"],
    "UI-Widgets-Frames/SimpleStatusBarAPI.md": ["SimpleStatusBarAPI.SetValue", "SimpleStatusBarAPI.SetMinMaxValues", "SimpleStatusBarAPI.SetTimerDuration", "SimpleStatusBarAPI.SetOrientation", "SimpleStatusBarAPI.SetReverseFill", "SimpleStatusBarAPI.SetStatusBarTexture"],
    "UI-Widgets-Frames/SimpleTextureBaseAPI.md": ["SimpleTextureBaseAPI.SetRotation", "SimpleTextureBaseAPI.SetTexture", "SimpleTextureBaseAPI.SetTexCoord", "SimpleTextureBaseAPI.SetBlendMode", "SimpleTextureBaseAPI.SetAtlas"],
    "UI-Widgets-Frames/SimpleFrameAPI.md": ["SimpleFrameAPI.CreateMaskTexture", "SimpleFrameAPI.RegisterEvent", "SimpleFrameAPI.SetClipsChildren", "SimpleFrameAPI.GetAlpha", "SimpleFrameAPI.SetAlpha", "SimpleFrameAPI.IsShown", "SimpleFrameAPI.Show", "SimpleFrameAPI.Hide", "SimpleFrameAPI.SetShown"],
    "UI-Widgets-Frames/SimpleButtonAPI.md": ["SimpleButtonAPI.IsEnabled", "SimpleButtonAPI.RegisterForClicks", "SimpleButtonAPI.SetHighlightTexture"],
    "UI-Widgets-Frames/SimpleEditBoxAPI.md": ["SimpleEditBoxAPI.SetFont"],
    "UI-Widgets-Frames/SimpleSliderAPI.md": ["SimpleSliderAPI.SetValue", "SimpleSliderAPI.SetMinMaxValues", "SimpleSliderAPI.SetOrientation", "SimpleSliderAPI.SetValueStep", "SimpleSliderAPI.SetObeyStepOnDrag", "SimpleSliderAPI.SetThumbTexture", "SimpleSliderAPI.SetEnabled"],
    "UI-Widgets-Frames/SimpleScriptRegionAPI.md": ["SimpleScriptRegionAPI.GetCenter", "SimpleScriptRegionAPI.GetWidth", "SimpleScriptRegionAPI.IsProtected", "SimpleScriptRegionAPI.EnableMouseWheel"],
    "UI-Widgets-Frames/SimpleFontStringAPI.md": ["SimpleFontStringAPI.SetText", "SimpleFontStringAPI.SetFont", "SimpleFontStringAPI.SetShadowColor", "SimpleFontStringAPI.SetShadowOffset"],
    "Units-Combat-PvP/Unit.md": ["Unit.UnitHealth", "Unit.UnitHealthMax", "Unit.UnitLevel", "Unit.UnitCastingInfo", "Unit.UnitChannelInfo", "Unit.UnitCastingDuration", "Unit.UnitChannelDuration", "Unit.UnitClassBase", "Unit.UnitClassification", "Unit.UnitReaction", "Unit.UnitIsPlayer", "Unit.UnitPlayerControlled"],
}
count = 0
for filename, names in required.items():
    text = (docs / filename).read_text()
    for name in names:
        if f"### {name}\n" not in text:
            raise SystemExit(f"Missing API signature: {name}")
        count += 1
print(f"{count} required/researched signatures present; runtime permissions and in-game behavior remain unverified")
unit_docs=(docs / "Units-Combat-PvP/Unit.md").read_text()
for event in ("PLAYER_LEVEL_UP", "UNIT_SPELLCAST_INTERRUPTIBLE", "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"):
    if f"### {event}\n" not in unit_docs:
        raise SystemExit(f"Missing documented event: {event}")

export = args.kit / "data/forever_api.json"
if export.is_file():
    functions=json.loads(export.read_text())["functions"]
    for helper in ("SetRaidTargetIconTexture", "hooksecurefunc", "GetCreatureDifficultyColor"):
        if helper not in functions:
            raise SystemExit(f"Client UI helper missing from Forever export: {helper}")
    print("Raid, difficulty-color and hook helpers present in Forever kit's client export; runtime behavior remains unverified")
else:
    print("Forever kit export unavailable: optional client UI helper presence not checked")
