import json
import pytest
from PIL import Image, ImageDraw
from conftest import ROOT
from test_art import art


def test_ffxiv_contract_geometry_and_opaque_fill(tmp_path):
    specs = {s["id"]: s for s in json.loads(art.CONTRACT.read_text())["assets"]}
    assert len(specs) == 9
    frame = specs["fantasy_frame"]
    assert frame["window"] == [236, 12] and frame["window_box"] == [10, 10, 246, 22]
    image = Image.new("RGBA", (256, 32), (70, 20, 20, 255))
    ImageDraw.Draw(image).rectangle((10, 10, 245, 21), fill=(0, 0, 0, 0))
    image.save(tmp_path / "fantasy_frame.png")
    assert art.validate(tmp_path / "fantasy_frame.png", frame).size == (256, 32)
    fill = specs["ffxiv_hp_fill"]
    Image.new("RGBA", (236, 12), (253, 187, 189, 255)).save(tmp_path / fill["file"])
    assert art.validate(tmp_path / fill["file"], fill).getchannel("A").getextrema() == (255, 255)
    for mode, color in [("RGB", (253, 187, 189)), ("RGBA", (253, 187, 189, 254)), ("RGBA", (0, 0, 0, 0))]:
        Image.new(mode, (236, 12), color).save(tmp_path / fill["file"])
        with pytest.raises(ValueError):
            art.validate(tmp_path / fill["file"], fill)


def test_fill_import_remains_opaque_32bit_and_old_frame_preserved(tmp_path):
    drop, addon = tmp_path / "drop", tmp_path / "addon"
    drop.mkdir()
    Image.new("RGBA", (236, 12), (253, 187, 189, 255)).save(drop / "ffxiv_hp_fill.png")
    assert art.run(drop, addon)[0] == 0
    with Image.open(addon / "Media/ffxiv_hp_fill.tga") as image:
        assert image.mode == "RGBA" and image.getpixel((50, 6)) == (253, 187, 189, 255)
    # Already published old artifacts are preserved despite the narrower measured contract.
    old = addon / "Media/fantasy_frame.tga"
    old.write_bytes(b"old frame preserved")
    manifest = json.loads((addon / "Media/manifest.json").read_text())
    manifest["assets"]["fantasy_frame"] = {"file": old.name, "width": 256, "height": 64, "status": "imported"}
    (addon / "Media/manifest.json").write_text(json.dumps(manifest))
    assert art.run(drop, addon)[0] == 0
    assert old.read_bytes() == b"old frame preserved"
    assert '"fantasy_frame"' not in (addon / "Media/Assets.lua").read_text()


def test_imported_fill_white_tint_secret_forwarding_and_pool_reset(runtime):
    runtime.execute('''
        local layout=NS.GameNameplates[6].layout
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,layout)
        NS.Renderer.Update(view,{health=70,name="Lost Lamb",level=3})
        assert(not view.parts[2].frame:IsShown())
        NS.Media.files.ffxiv_hp_fill="ffxiv_hp_fill.tga"
        NS.Renderer.Apply(view,layout)
        local base=Mock.AddUnit("nameplate1"); Mock.units.nameplate1.health=Mock.Secret()
        NS.Renderer.Update(view,{name="Lost Lamb",level=3},"nameplate1")
        local bar=view.parts[2].bar
        assert(view.parts[2].frame:IsShown() and issecretvalue(bar.value))
        assert(bar.statusTexture=="Interface\\\\AddOns\\\\ForeverNameplates\\\\Media\\\\ffxiv_hp_fill.tga")
        assert(bar.statusColor[1]==1 and bar.statusColor[2]==1 and bar.statusColor[3]==1)
        NS.Renderer.Apply(view,NS.Presets[1].layout); NS.Renderer.Update(view,{health=50})
        for _,part in ipairs(view.parts) do
            if part.bar then assert(part.bar.statusTexture=="Interface\\\\Buttons\\\\WHITE8X8") end
            for _,outline in ipairs(part.outlines or {}) do assert(not outline:IsShown()) end
        end
        NS.Renderer.Apply(view,layout); local count=#Mock.frames
        for i=1,10 do NS.Renderer.Apply(view,NS.Presets[1].layout); NS.Renderer.Apply(view,layout) end
        assert(#Mock.frames==count)
    ''')


@pytest.mark.parametrize("failure", ["false", "error", "secret"])
def test_rejected_fill_never_displays_stale_texture(runtime, failure):
    runtime.globals().failure=failure
    runtime.execute('''
        local view=NS.Renderer.Create(UIParent); local layout=NS.Presets[1].layout
        NS.Renderer.Apply(view,layout)
        for _,part in ipairs(view.parts) do if part.bar then part.bar.SetStatusBarTexture=function()
            if failure=="false" then return false elseif failure=="error" then error("Rejected") else return Mock.Secret() end
        end end end
        NS.Renderer.Apply(view,layout)
        for _,part in ipairs(view.parts) do if part.bar then assert(not part.frame:IsShown()) end end
        NS.Renderer.Update(view,{health=70,casting=true})
        for _,part in ipairs(view.parts) do if part.bar then assert(not part.barReady and not part.frame:IsShown()) end end
    ''')


def test_ffxiv_picker_requires_complete_assets_and_supports_undo(runtime):
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; local picker=s.gameNameplatePicker
        picker.scripts.OnClick(); assert(not NS.W.menu.items[6]:IsEnabled())
        local previous=s.session.layout.name
        NS.W.menu.items[6].scripts.OnClick(); assert(s.session.layout.name==previous)
        NS.Media.files.fantasy_frame="fantasy_frame.tga"; NS.Media.files.ffxiv_hp_fill="ffxiv_hp_fill.tga"
        assert(not NS.Catalog.GameReady(NS.GameNameplates[6]))
        NS.Media.files.ffxiv_enemy_icon="ffxiv_enemy_icon.tga"
        assert(NS.Catalog.GameReady(NS.GameNameplates[6]))
        picker.scripts.OnClick(); assert(NS.W.menu.items[6]:IsEnabled()); NS.W.menu.items[6].scripts.OnClick()
        assert(s.session.layout.name==NS.GameNameplates[6].layout.name)
        assert(s.session:Element("health").width==236 and s.session:Element("health").height==12)
        assert(s.session:Undo()); s.Refresh(); assert(s.session.layout.name==previous)
    ''')


def test_fill_choices_do_not_mix_frames_and_reset_to_plain(runtime):
    runtime.execute('''
        NS.Media.files.ffxiv_hp_fill="ffxiv_hp_fill.tga"; NS.Media.files.classic_frame="classic_frame.tga"
        assert(#NS.Catalog.Assets()==1 and NS.Catalog.Assets()[1]=="classic_frame")
        assert(#NS.Catalog.Assets("health")==1 and NS.Catalog.Assets("cast")[1]=="ffxiv_hp_fill")
        NS.Studio.Open(); local s=NS.Studio; s.Select("health")
        assert(s.inspector.asset:IsShown() and not s.inspector.shape:IsShown())
        s.inspector.asset.scripts.OnClick(); NS.W.menu.items[2].scripts.OnClick()
        assert(s.session:Element().asset=="ffxiv_hp_fill")
        assert(s.view.parts[2].bar.statusTexture:find("ffxiv_hp_fill.tga",1,true))
        s.inspector.asset.scripts.OnClick(); NS.W.menu.items[1].scripts.OnClick()
        assert(s.session:Element().asset=="")
        assert(s.view.parts[2].bar.statusTexture=="Interface\\\\Buttons\\\\WHITE8X8")
        assert(s.session:Undo()); assert(s.session:Element().asset=="ffxiv_hp_fill")
    ''')


def test_ffxiv_label_outlines_and_secret_level(runtime):
    runtime.execute('''
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,NS.GameNameplates[6].layout)
        NS.Renderer.Update(view,{name="Lost Lamb",level=3,health=74})
        local label=view.parts[5]
        assert(label.text:GetText()=="Lv3" and label.text.font[1]=="Fonts\\\\ARIALN.TTF")
        assert(#label.outlines==8 and label.outlines[1].textColor[2]==.84)
        for _,outline in ipairs(label.outlines) do assert(outline:GetText()=="Lv3") end
        NS.Renderer.Update(view,{name="Lost Lamb",level=Mock.Secret()})
        assert(label.text:GetText()=="")
        for _,outline in ipairs(label.outlines) do assert(outline:GetText()=="") end
    ''')
