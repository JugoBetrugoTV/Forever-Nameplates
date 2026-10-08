from pathlib import Path
import pytest
from lupa.lua51 import LuaRuntime
from conftest import ROOT, ADDON

def test_lua51_syntax_and_tocs():
    lua = LuaRuntime(unpack_returned_tuples=True)
    compile_lua = lua.eval("function(s) local f,e=loadstring(s); return f,e end")
    for p in list(ADDON.rglob("*.lua")) + list((ROOT / "Tests").glob("*.lua")):
        fn, err = compile_lua(p.read_text())
        assert fn is not None, f"{p}: {err}"
    toc = (ADDON / "ForeverNameplates.toc").read_text()
    assert toc == (ADDON / "ForeverNameplates_Camelot.toc").read_text()
    assert "## Interface: 16001" in toc
    assert "## SavedVariables: ForeverNameplatesDB" in toc
    for line in toc.splitlines():
        if line and not line.startswith("#"):
            assert (ADDON / line).is_file(), line

def test_all_presets_valid_and_different(runtime):
    runtime.execute('''
        assert(#NS.Presets==12)
        local signatures={}
        for _,p in ipairs(NS.Presets) do
            assert(NS.Model.Validate(p.layout))
            local s=""
            for _,e in ipairs(p.layout.elements) do
                s=s..e.kind..":"..e.width..":"..e.height..":"..e.x..":"..e.y..":"..e.shape..";"
            end
            assert(not signatures[s],"Duplicate silhouette"); signatures[s]=true
        end
    ''')

@pytest.mark.parametrize("expression", [
    'p.version=999', 'p.name="|Hbad"', 'p.elements[1].width=0',
    'p.elements[1].x=0/0', 'p.elements[1].color[1]=2',
    'p.elements[2].id=p.elements[1].id', 'p.elements[1].script="print(1)"',
    'p.elements[1].asset="../../bad"', 'p.elements[1].layer=1.5',
    'p.elements[1].locked="true"', 'p.elements[1].color[5]=1',
    'p.elements[1].kind="script"', 'p.elements[1].text="hello\\nworld"',
    'p.elements[65]=p.elements[1]', 'setmetatable(p,{})',
])
def test_invalid_data_rejected(runtime, expression):
    runtime.execute('local p=NS.Copy(NS.Presets[1].layout); ' + expression + '; assert(not NS.Model.Validate(p))')

def test_share_roundtrip_all_presets(runtime):
    runtime.execute('''
        for _,p in ipairs(NS.Presets) do
            local code=assert(NS.Share.Export(p.layout))
            local result=assert(NS.Share.Import(code))
            assert(result.name==p.layout.name and #result.elements==#p.layout.elements)
            for i,e in ipairs(result.elements) do
                for k,v in pairs(e) do
                    local original=p.layout.elements[i][k]
                    if type(v)=="number" then assert(math.abs(v-original)<0.00001)
                    elseif type(v)=="table" then for j=1,4 do assert(math.abs(v[j]-original[j])<0.00001) end
                    else assert(v==original) end
                end
            end
        end
    ''')

@pytest.mark.parametrize("code", ["", "FN2:x", "FN1:", "FN1:...", "FN1:@@@@", "FN1:" + "a" * 48001, "loadstring('bad')"])
def test_share_invalid_envelopes(runtime, code):
    imported, error = runtime.globals().NS.Share.Import(code)
    assert imported is None
    assert "rejected" in error

def test_share_decompression_and_schema_limits(runtime):
    runtime.execute('''
        local d=LibStub("LibDeflate")
        local bomb="FN1:"..d:EncodeForPrint(d:CompressDeflate(string.rep("a",10000)))
        assert(not NS.Share.Import(bomb))
        local script="FN1:"..d:EncodeForPrint(d:CompressDeflate("1\\n44656d6f\\nprint('boom')"))
        assert(not NS.Share.Import(script))
    ''')

def test_session_undo_redo_snap_lock_and_copy(runtime):
    runtime.execute('''
        local s=assert(NS.Session.New(NS.DB.Current(),NS.DB.Save))
        s.selected="health"
        assert(s:Move("health",13,18)); assert(s:Element().x==12 and s:Element().y==20)
        assert(NS.DB.Current().elements[2].x==12)
        assert(s:Undo()); assert(s:Element().x==0)
        assert(s:Redo()); assert(s:Element().x==12)
        assert(s:Update("health",{locked=true})); assert(not s:Move("health",10,10))
        assert(s:Update("health",{locked=false})); assert(s:Copy()); assert(s:Paste())
        assert(s:Element().id=="copy1"); assert(s:Delete())
        assert(s:Undo()); assert(s:Redo())
    ''')

def test_session_invalid_and_combat_changes_are_atomic(runtime):
    runtime.execute('''
        local s=assert(NS.Session.New(NS.DB.Current(),NS.DB.Save))
        local before=s.layout.elements[1].width
        assert(not s:Update("back",{width=-1})); assert(s.layout.elements[1].width==before)
        Mock.combat=true; assert(not s:Move("back",20,20)); assert(#s.undo==0)
        Mock.combat=false
        local rejecting=NS.Session.New(NS.DB.Current(),function() return nil,"reject" end)
        assert(not rejecting:Move("back",20,20)); assert(#rejecting.undo==0)
    ''')

def test_profiles_account_character_rename_and_migration(runtime):
    runtime.execute('''
        assert(NS.DB.Create("Arena")); assert(NS.DB.CurrentName()=="Arena")
        assert(NS.DB.SetCharacter(true)); assert(NS.DB.Select("Default"))
        assert(NS.DB.data.active=="Arena" and NS.DB.CurrentName()=="Default")
        assert(NS.DB.SetCharacter(false)); assert(NS.DB.CurrentName()=="Arena")
        assert(NS.DB.Rename("Duel")); assert(NS.DB.CurrentName()=="Duel")
        assert(not NS.DB.Create("Duel"))
        local old={version=0,layout=NS.Copy(NS.Presets[4].layout)}
        assert(NS.DB.Initialize(old).profiles.Default.name=="Galactic Interface")
        local future={version=99,doNotDelete=true}; assert(not NS.DB.Initialize(future)); assert(future.doNotDelete)
    ''')

def test_live_health_cast_events_and_frame_reuse(runtime):
    runtime.execute('''
        NS.DB.data.live=true; local base=Mock.AddUnit("nameplate1")
        Mock.units.nameplate1.castName="Fireball"; Mock.units.nameplate1.duration={timer=true}
        Mock.Fire(NS.events,"NAME_PLATE_UNIT_ADDED","nameplate1")
        local view=NS.Engine.units.nameplate1; assert(view and view.root:IsShown())
        local hp,cast
        for _,p in ipairs(view.parts) do if p.kind=="health" then hp=p.bar elseif p.kind=="cast" then cast=p.bar end end
        assert(hp.value==70 and hp.max==100); assert(cast.duration==Mock.units.nameplate1.duration)
        Mock.units.nameplate1.health=30; Mock.Fire(NS.events,"UNIT_HEALTH","nameplate1"); assert(hp.value==30)
        Mock.target="nameplate1"; Mock.Fire(NS.events,"PLAYER_TARGET_CHANGED")
        for _,p in ipairs(view.parts) do if p.kind=="target" then assert(p.frame:IsShown()) end end
        local frameCount=#Mock.frames
        Mock.Fire(NS.events,"NAME_PLATE_UNIT_REMOVED","nameplate1"); assert(not view.root:IsShown())
        Mock.Fire(NS.events,"NAME_PLATE_UNIT_ADDED","nameplate1"); assert(#Mock.frames==frameCount)
        assert(NS.Engine.units.nameplate1==view)
    ''')

def test_secret_health_forwarded_without_math_and_secret_text_omitted(runtime):
    runtime.execute('''
        NS.DB.data.live=true; Mock.AddUnit("nameplate1")
        local secret=Mock.Secret()
        Mock.units.nameplate1.health=secret; Mock.units.nameplate1.maximum=secret
        Mock.units.nameplate1.name=secret; Mock.units.nameplate1.level=secret; Mock.units.nameplate1.castName=secret
        Mock.Fire(NS.events,"NAME_PLATE_UNIT_ADDED","nameplate1")
        local view=assert(NS.Engine.units.nameplate1)
        for _,p in ipairs(view.parts) do
            if p.kind=="health" then assert(p.bar.value==secret and p.bar.max==secret) end
            if p.element.source=="name" then assert(p.text.text=="") end
            if p.element.source=="health" then assert(p.text.text=="—") end
        end
        assert(NS.Compat.failures==0)
        Mock.Fire(NS.events,"NAME_PLATE_UNIT_ADDED",secret)
    ''')

def test_protected_forbidden_and_combat_attachments(runtime):
    runtime.execute('''
        NS.DB.data.live=true
        local f=Mock.AddUnit("nameplate1"); f.forbidden=true; NS.Engine.Add("nameplate1"); assert(not NS.Engine.units.nameplate1)
        f.forbidden=false; f.protected=true; NS.Engine.Add("nameplate1"); assert(not NS.Engine.units.nameplate1)
        f.protected=false; Mock.combat=true; NS.Engine.Add("nameplate1"); assert(NS.Engine.pending.nameplate1 and not NS.Engine.units.nameplate1)
        Mock.combat=false; Mock.Fire(NS.events,"PLAYER_REGEN_ENABLED"); assert(NS.Engine.units.nameplate1)
    ''')

def test_gui_load_controls_drag_history_and_combat_pause(runtime):
    runtime.execute('''
        SlashCmdList.FOREVERNAMEPLATES("")
        assert(NS.Studio.root:IsShown() and NS.Studio.page=="studio")
        NS.Studio.ShowPage("studio"); NS.Studio.Select("health")
        NS.Studio.Change({width=220}); assert(NS.DB.Current().elements[2].width==220)
        assert(NS.Studio.session:Undo()); NS.Studio.Refresh(); assert(NS.DB.Current().elements[2].width==180)
        local handle=NS.Studio.handles[2]
        handle.scripts.OnDragStart(handle)
        Mock.cursorX=16; Mock.cursorY=8
        NS.Studio.canvas.scripts.OnUpdate()
        handle.scripts.OnDragStop(handle)
        assert(NS.Studio.session:Element("health").x==16)
        NS.Studio.ShowPage("profiles"); NS.Studio.ShowPage("diagnostics")
        assert(NS.Studio.diagnosticText:GetText():find("16001"))
        Mock.combat=true; Mock.Fire(NS.events,"PLAYER_REGEN_DISABLED"); assert(not NS.Studio.root:IsShown())
        NS.Studio.Open(); assert(not NS.Studio.root:IsShown())
    ''')

def test_renderer_pool_no_rebuild_and_many_units(runtime):
    runtime.execute('''
        NS.DB.data.live=true
        for i=1,40 do Mock.AddUnit("nameplate"..i); NS.Engine.Add("nameplate"..i) end
        assert(NS.Engine.stats.created==40)
        local count=#Mock.frames
        for j=1,20 do for i=1,40 do NS.Engine.Update("nameplate"..i) end end
        assert(#Mock.frames==count)
        for _,view in pairs(NS.Engine.units) do NS.Renderer.Apply(view,NS.DB.Current()) end
        assert(#Mock.frames==count)
    ''')

def test_interface_detection_and_other_clients_blocked(runtime):
    runtime.execute('''
        assert(NS.Compat.interface==16001 and NS.Compat.expected)
        GetBuildInfo=function() return "12.0","","",120000 end
        NS.Compat.Audit(); assert(not NS.Compat.expected)
        NS.DB.data.live=true; Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        assert(not NS.Engine.units.nameplate1)
    ''')

def test_widget_failure_hides_health_and_counts_diagnostic(runtime):
    runtime.execute('''
        NS.DB.data.live=true; Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local hp
        for _,p in ipairs(NS.Engine.units.nameplate1.parts) do if p.kind=="health" then hp=p.bar end end
        hp.SetValue=function() error("Widget forwarding denied") end
        NS.Engine.Update("nameplate1")
        assert(not hp:IsShown() and NS.Compat.failures==1)
    ''')

def test_recycled_base_clears_old_unit_binding(runtime):
    runtime.execute('''
        NS.DB.data.live=true; local base=Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1
        Mock.AddUnit("nameplate2"); Mock.plates.nameplate2=base; NS.Engine.Add("nameplate2")
        assert(NS.Engine.units.nameplate2==view and not NS.Engine.units.nameplate1)
        NS.Engine.Remove("nameplate1"); assert(view.root:IsShown())
    ''')

def test_asset_contract_matches_registered_keys(runtime):
    import json
    contract = json.loads((ROOT / "Tools/art_requests.json").read_text())
    for asset in contract["assets"]:
        assert runtime.globals().NS.Model.assets[asset["id"]] is True
    assert len(contract["assets"]) == 9
    assert sum(asset.get("role", "frame") == "frame" for asset in contract["assets"]) == 7
    assert all(a["reference"]["element"] == "overhead unit nameplate" for a in contract["assets"])

def test_undo_paste_keeps_selection_valid(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        s.selected="health"; assert(s:Copy()); assert(s:Paste()); assert(s:Undo())
        assert(s:Element() and s.selected=="back")
    ''')
