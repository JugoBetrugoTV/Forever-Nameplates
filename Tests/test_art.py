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
    image = Image.new("RGBA", (256, 64), (0, 0, 0, 0))
    for x in range(256):
        image.putpixel((x, 0), (190, 130, 50, 255))
    image.save(path)

def test_import_tga_alpha_manifest_and_idempotence(folders):
    drop, addon = folders
    make_valid(drop / "classic_frame.png")
    errors, messages = art.run(drop, addon)
    assert errors == 0 and any("IMPORTED" in x for x in messages)
    target = addon / "Media/classic_frame.tga"
    with Image.open(target) as output:
        assert output.size == (256, 64)
        assert output.mode == "RGBA"
        assert output.getpixel((128, 32))[3] == 0
    before = target.stat().st_mtime_ns
    errors, _ = art.run(drop, addon)
    assert errors == 0 and target.stat().st_mtime_ns == before
    manifest = json.loads((addon / "Media/manifest.json").read_text())
    assert manifest["assets"]["classic_frame"]["status"] == "imported"
    assert '["classic_frame"]="classic_frame.tga"' in (addon / "Media/Assets.lua").read_text()

@pytest.mark.parametrize("mode,size,color", [
    ("RGB", (256, 64), "white"),
    ("RGBA", (128, 64), (1, 2, 3, 0)),
    ("RGBA", (256, 64), (1, 2, 3, 255)),
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
    image = Image.new("RGBA", (256, 64), (1, 2, 3, 255))
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
