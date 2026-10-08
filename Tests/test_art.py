import importlib.util
import json
from pathlib import Path
import pytest
from PIL import Image
from conftest import ROOT

spec = importlib.util.spec_from_file_location("import_art", ROOT / "Tools/import_art.py")
art = importlib.util.module_from_spec(spec)
spec.loader.exec_module(art)

@pytest.fixture
def folders(tmp_path):
    drop, addon = tmp_path / "drop", tmp_path / "addon"
    drop.mkdir()
    return drop, addon

def make_valid(path):
    image = Image.new("RGBA", (128, 16), (0, 0, 0, 0))
    for x in range(128):
        image.putpixel((x, 0), (190, 130, 50, 255))
    image.save(path)

def test_import_tga_alpha_manifest_and_idempotence(folders):
    drop, addon = folders
    make_valid(drop / "classic_frame.png")
    errors, messages = art.run(drop, addon)
    assert errors == 0 and any("IMPORTED" in x for x in messages)
    target = addon / "Media/classic_frame.tga"
    with Image.open(target) as output:
        assert output.size == (128, 16)
        assert output.mode == "RGBA"
        assert output.getpixel((64, 8))[3] == 0
    before = target.stat().st_mtime_ns
    errors, _ = art.run(drop, addon)
    assert errors == 0 and target.stat().st_mtime_ns == before
    manifest = json.loads((addon / "Media/manifest.json").read_text())
    assert manifest["assets"]["classic_frame"]["status"] == "imported"
    assert '["classic_frame"]="classic_frame.tga"' in (addon / "Media/Assets.lua").read_text()

@pytest.mark.parametrize("mode,size,color", [
    ("RGB", (128, 16), "white"),
    ("RGBA", (256, 64), (1, 2, 3, 0)),
    ("RGBA", (128, 16), (1, 2, 3, 255)),
    ("RGBA", (256, 64), (1, 2, 3, 0)),
])
def test_invalid_images_rejected(folders, mode, size, color):
    drop, addon = folders
    Image.new(mode, size, color).save(drop / "classic_frame.png")
    errors, _ = art.run(drop, addon)
    assert errors == 1
    assert not (addon / "Media/classic_frame.tga").exists()

def test_bad_window_and_unknown_name(folders):
    drop, addon = folders
    image = Image.new("RGBA", (128, 16), (1, 2, 3, 255))
    image.putpixel((0, 0), (0, 0, 0, 0))
    image.save(drop / "classic_frame.png")
    make_valid(drop / "unexpected.png")
    errors, _ = art.run(drop, addon)
    assert errors == 2

def test_reject_preserves_existing_and_marks_damaged_outputs(folders):
    drop, addon = folders
    source = drop / "classic_frame.png"
    make_valid(source)
    art.run(drop, addon)
    target = addon / "Media/classic_frame.tga"
    good = target.read_bytes()
    source.write_bytes(b"broken image")
    errors, _ = art.run(drop, addon)
    assert errors == 1 and target.read_bytes() == good
    target.write_bytes(b"damaged output")
    art.run(drop, addon)
    manifest = json.loads((addon / "Media/manifest.json").read_text())
    assert manifest["assets"]["classic_frame"]["status"] == "obsolete"
    assert "classic_frame.tga" not in (addon / "Media/Assets.lua").read_text()

def test_symlink_rejected(folders, tmp_path):
    drop, addon = folders
    outside = tmp_path / "outside.png"
    make_valid(outside)
    (drop / "classic_frame.png").symlink_to(outside)
    errors, _ = art.run(drop, addon)
    assert errors == 1


def test_classic_window_is_measured_off_center(tmp_path):
    from PIL import ImageDraw
    spec = next(a for a in json.loads(art.CONTRACT.read_text())["assets"] if a["id"] == "classic_frame")
    source = tmp_path / "classic_frame.png"
    wrong = Image.new("RGBA", (128, 16), (60, 60, 60, 255))
    ImageDraw.Draw(wrong).rectangle((13, 3, 115, 12), fill=(0, 0, 0, 0))
    wrong.save(source)
    with pytest.raises(ValueError, match="95% transparent"):
        art.validate(source, spec)
    right = Image.new("RGBA", (128, 16), (60, 60, 60, 255))
    ImageDraw.Draw(right).rectangle((4, 3, 106, 12), fill=(0, 0, 0, 0))
    right.save(source)
    assert art.validate(source, spec).size == (128, 16)


def test_changed_contract_marks_old_dimensions_obsolete_without_deleting(folders, tmp_path):
    drop, addon = folders
    legacy_contract = json.loads(art.CONTRACT.read_text())
    classic = next(a for a in legacy_contract["assets"] if a["id"] == "classic_frame")
    classic.update(width=256, height=64, window=[180, 14]); classic.pop("window_box")
    old_contract = tmp_path / "old_contract.json"
    old_contract.write_text(json.dumps(legacy_contract))
    old = Image.new("RGBA", (256, 64), (0, 0, 0, 0)); old.putpixel((0, 0), (20, 20, 20, 255))
    old.save(drop / "classic_frame.png")
    assert art.run(drop, addon, old_contract)[0] == 0
    target = addon / "Media/classic_frame.tga"; original = target.read_bytes()
    assert art.run(drop, addon)[0] == 1
    manifest = json.loads((addon / "Media/manifest.json").read_text())
    assert manifest["assets"]["classic_frame"]["status"] == "obsolete"
    assert target.read_bytes() == original
    assert '["classic_frame"]=' not in (addon / "Media/Assets.lua").read_text()
