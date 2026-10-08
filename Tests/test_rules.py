"""Rules, schema migration and public identity handling in the explicit Lua widget mock."""
import json
import pytest
from conftest import ROOT


def test_genuine_legacy_fn1_import_and_savedvariables_migration(runtime):
    legacy = json.loads((ROOT / 'Tests/legacy_fn1.json').read_text())
    runtime.globals().legacyCode = legacy['code']
    runtime.globals().legacyName = legacy['name']
    runtime.execute('''
        local layout=assert(NS.Share.Import(legacyCode))
        assert(layout.version==2 and layout.name==legacyName)
        assert(layout.elements[2].id=="health" and layout.elements[2].width==180)
        assert(layout.rules.healthColor=="preset")
        for _,rule in pairs(layout.rules.overrides) do assert(not rule.enabled) end
        local old=NS.Copy(layout); old.version=1; old.rules=nil
        local saved={version=1,profiles={Default=old,Arena=NS.Copy(old)},active="Arena",characters={["Tester-TestRealm"]="Arena"},live=true}
        local data=assert(NS.DB.Initialize(saved))
        assert(data.version==2 and data.profiles.Arena.version==2)
        assert(data.active=="Arena" and data.characters["Tester-TestRealm"]=="Arena" and data.live)
        assert(saved.version==1 and saved.profiles.Arena.rules==nil)
        assert(NS.Share.Export(layout):sub(1,4)=="FN2:")
    ''')


def test_fn2_preserves_rules_and_new_components(runtime):
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current()); local r=layout.rules
        r.healthColor="reaction"; r.friendlyColor={.1,.2,.3,.4}
        for i,category in ipairs(NS.Rules.categories) do
            local rule=r.overrides[category.id]
            rule.enabled=true; rule.visible=i%2==0; rule.alpha=.35; rule.scale=1.5
            rule.colorMode="fixed"; rule.color={.2,.3,.4,.5}
        end
        layout.elements[#layout.elements+1]=assert(NS.Catalog.Create("class","badge"))
        layout.elements[#layout.elements+1]=assert(NS.Catalog.Create("raid","marker"))
        local code=assert(NS.Share.Export(layout)); local copy=assert(NS.Share.Import(code))
        assert(copy.rules.healthColor=="reaction" and copy.rules.friendlyColor[4]==.4)
        for i,category in ipairs(NS.Rules.categories) do
            local rule=copy.rules.overrides[category.id]
            assert(rule.enabled and rule.visible==(i%2==0) and rule.alpha==.35 and rule.scale==1.5)
            assert(rule.colorMode=="fixed" and rule.color[4]==.5)
        end
        assert(copy.elements[#copy.elements].kind=="raid")
        assert(not NS.Share.Import("FN1:"..code:sub(5)))
    ''')


@pytest.mark.parametrize('mutation', [
    'p.rules=nil', 'p.rules.healthColor="script"', 'p.rules.extra=true',
    'p.rules.friendlyColor[1]=0/0', 'p.rules.hostileColor[5]=1',
    'p.rules.overrides.target.scale=2.1', 'p.rules.overrides.target.scale=.49',
    'p.rules.overrides.target.alpha=-.1', 'p.rules.overrides.target.enabled=1',
    'p.rules.overrides.target.colorMode="evil"', 'p.rules.overrides.target.color[1]=2',
    'p.rules.overrides.target=nil', 'p.rules.overrides.fake={}',
])
def test_rules_reject_invalid_data(runtime, mutation):
    runtime.execute('local p=NS.Copy(NS.DB.Current()); '+mutation+'; assert(not NS.Model.Validate(p))')


@pytest.mark.parametrize('state,expected', [
    ('{isPlayer=true,reaction=5}', 'friendlyPlayers'),
    ('{isPlayer=true,reaction=4}', 'enemyPlayers'),
    ('{isPlayer=false,controlled=false,reaction=5}', 'friendlyNPCs'),
    ('{isPlayer=false,controlled=false,reaction=3}', 'hostileNPCs'),
    ('{isPlayer=false,controlled=false,reaction=4}', 'neutralNPCs'),
    ('{isPlayer=false,controlled=true}', 'pets'),
    ('{isPlayer=false,reaction=3}', 'unknown'),
    ('{}', 'unknown'),
])
def test_primary_categories(runtime, state, expected):
    assert runtime.eval('NS.Rules.Category('+state+')') == expected


def test_rule_precedence_and_unknown_target(runtime):
    runtime.execute('''
        local r=NS.Rules.Defaults(); r.healthColor="reaction"
        r.overrides.hostileNPCs={enabled=true,visible=false,alpha=.1,scale=.6,colorMode="fixed",color={1,0,0,1}}
        r.overrides.elite={enabled=true,visible=true,alpha=.2,scale=.8,colorMode="inherit",color={1,1,1,1}}
        r.overrides.rare={enabled=true,visible=false,alpha=.3,scale=1.2,colorMode="class",color={1,1,1,1}}
        r.overrides.target={enabled=true,visible=true,alpha=.4,scale=1.5,colorMode="inherit",color={1,1,1,1}}
        r.overrides.nonTarget={enabled=true,visible=false,alpha=.5,scale=.5,colorMode="preset",color={1,1,1,1}}
        local state={isPlayer=false,controlled=false,reaction=3,classification="rareelite",target=true}
        local result=NS.Rules.Resolve(r,state)
        assert(result.visible and result.alpha==.4 and result.scale==1.5 and result.colorMode=="class")
        state.target=nil; result=NS.Rules.Resolve(r,state)
        assert(not result.visible and result.alpha==.3 and result.colorMode=="class")
        state.target=false; assert(NS.Rules.Resolve(r,state).alpha==.5)
    ''')


def test_secret_identity_and_reaction_never_evaluated_or_retained(runtime):
    runtime.execute('''
        Mock.AddUnit("nameplate1")
        Mock.units.nameplate1.isPlayer=true; Mock.units.nameplate1.class="MAGE"
        Mock.units.nameplate1.reaction=3; Mock.units.nameplate1.raidMarker=8
        assert(NS.Compat.State("nameplate1").class=="MAGE")
        local secret=Mock.Secret()
        for _,key in ipairs({"name","level","isPlayer","controlled","class","reaction","classification","raidMarker"}) do Mock.units.nameplate1[key]=secret end
        UnitIsUnit=function() return secret end
        local state=NS.Compat.State("nameplate1")
        assert(state.name=="" and state.level=="" and state.class==nil and state.target==nil)
        assert(state.raidMarker==nil and state.reaction==nil and NS.Rules.Category(state)=="unknown")
        C_Secrets={ShouldUnitIdentityBeSecret=function() return true end}
        local queries=0
        UnitName=function() queries=queries+1; error("Should not query restricted identity") end
        UnitClassBase=UnitName; UnitIsPlayer=UnitName; UnitIsUnit=UnitName
        state=NS.Compat.State("nameplate1"); assert(state.name=="" and state.class==nil and state.target==nil and queries==0)
    ''')


def test_live_colors_visibility_scale_and_event_updates(runtime):
    runtime.execute('''
        Mock.AddUnit("nameplate1"); NS.DB.data.live=true
        local u=Mock.units.nameplate1; u.isPlayer=true; u.controlled=true; u.class="MAGE"; u.reaction=3
        local layout=NS.DB.Current(); layout.rules.healthColor="class"
        layout.elements[#layout.elements+1]=NS.Catalog.Create("raid","marker")
        layout.elements[#layout.elements+1]=NS.Catalog.Create("class","badge")
        NS.Engine.Add("nameplate1"); local view=NS.Engine.units.nameplate1
        local health,raid,badge
        for _,p in ipairs(view.parts) do
            if p.kind=="health" then health=p end
            if p.kind=="raid" then raid=p end
            if p.kind=="class" then badge=p end
        end
        assert(health.bar.statusColor[1]==.25 and badge.text.text=="MAG" and not raid.frame:IsShown())
        u.raidMarker=8; Mock.Fire(NS.events,"RAID_TARGET_UPDATE")
        assert(raid.frame:IsShown() and raid.raid.texCoord[1]==.75 and raid.raid.texCoord[3]==.25)
        u.class=nil; Mock.Fire(NS.events,"UNIT_FACTION","nameplate1")
        assert(not badge.frame:IsShown() and health.bar.statusColor[1]==health.element.color[1])
        layout.rules.healthColor="reaction"; assert(NS.DB.Save(layout))
        assert(health.bar.statusColor[1]==layout.rules.hostileColor[1])
        u.reaction=5; Mock.Fire(NS.events,"UNIT_FACTION","nameplate1")
        assert(health.bar.statusColor[1]==layout.rules.friendlyColor[1])
        layout.rules.overrides.friendlyPlayers={enabled=true,visible=false,alpha=.2,scale=1.6,colorMode="inherit",color={1,1,1,1}}
        assert(NS.DB.Save(layout)); assert(not view.root:IsShown() and view.root.scale==1.6 and view.root.alpha==.2)
        local count=0; UnitHealth=function() count=count+1; return 40 end
        NS.Renderer.Update(view,{isPlayer=true,reaction=5},"nameplate1"); assert(count==0)
        u.reaction=3; Mock.Fire(NS.events,"UNIT_CLASSIFICATION_CHANGED","nameplate1")
        assert(view.root:IsShown() and view.root.scale==1 and view.root.alpha==1)
        u.raidMarker=nil; Mock.Fire(NS.events,"RAID_TARGET_UPDATE"); assert(not raid.frame:IsShown())
    ''')


def test_rule_editor_autosave_history_invalid_combat_and_preview_scale(runtime):
    runtime.execute('''
        NS.Studio.Open(); NS.Studio.ShowPage("rules")
        local studio=NS.Studio; local ui=studio.ruleUI
        assert(studio.pages.rules:IsShown() and #studio.scenarios==13)
        assert(studio.ChangeRules({healthColor="class"})); assert(NS.DB.Current().rules.healthColor=="class")
        assert(studio.ChangeRules({enabled=true,scale=1.5,alpha=.5},"enemyPlayers"))
        assert(ui.view.root.scale==.65*1.5 and ui.view.root.alpha==.5)
        studio.scenario=5; studio.zoom=2; studio.Refresh()
        assert(studio.view.root.scale==3)
        assert(studio.session:Undo()); studio.Refresh(); assert(ui.view.root.scale==.65)
        assert(studio.session:Redo()); studio.Refresh(); assert(ui.view.root.scale==.65*1.5)
        local count=#studio.session.undo
        assert(not studio.ChangeRules({scale=0},"enemyPlayers")); assert(#studio.session.undo==count)
        Mock.combat=true; assert(not studio.ChangeRules({alpha=.1},"enemyPlayers"))
        assert(NS.DB.Current().rules.overrides.enemyPlayers.alpha==.5)
    ''')


def test_level_unknown_classification_and_component_pooling(runtime):
    runtime.execute('''
        Mock.AddUnit("nameplate1"); Mock.units.nameplate1.level=-1
        assert(NS.Compat.State("nameplate1").level=="??")
        local layout=NS.Copy(NS.DB.Current())
        layout.elements[#layout.elements+1]=NS.Catalog.Create("class","badge")
        layout.elements[#layout.elements+1]=NS.Catalog.Create("raid","marker")
        local e=NS.Catalog.Create("text","rank"); e.source="classification"; layout.elements[#layout.elements+1]=e
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,layout)
        NS.Renderer.Update(view,{isPlayer=true,class="PRIEST",raidMarker=1,classification="worldboss"})
        assert(view.parts[#view.parts].text.text=="worldboss")
        local count=#Mock.frames
        for i=1,50 do NS.Renderer.Apply(view,layout); NS.Renderer.Update(view,{}) end
        assert(#Mock.frames==count)
        assert(not view.parts[#view.parts-1].frame:IsShown())
        assert(not view.parts[#view.parts-2].frame:IsShown())
    ''')


def test_rules_page_actual_widget_callbacks(runtime):
    runtime.execute('''
        NS.Studio.Open(); NS.Studio.ShowPage("rules")
        local ui=NS.Studio.ruleUI
        ui.globalMode.scripts.OnClick(); NS.W.menu.items[2].scripts.OnClick()
        assert(NS.DB.Current().rules.healthColor=="class")
        ui.categoryPicker.scripts.OnClick(); NS.W.menu.next.scripts.OnClick(); NS.W.menu.items[2].scripts.OnClick()
        assert(ui.category=="target")
        ui.enabled.scripts.OnClick(); assert(NS.DB.Current().rules.overrides.target.enabled)
        ui.visible.scripts.OnClick(); assert(not NS.DB.Current().rules.overrides.target.visible)
        ui.scale:SetText("1.8"); ui.scale.scripts.OnEnterPressed(ui.scale)
        assert(NS.DB.Current().rules.overrides.target.scale==1.8)
        ui.alpha:SetText("bad"); ui.alpha.scripts.OnEnterPressed(ui.alpha)
        assert(NS.DB.Current().rules.overrides.target.alpha==1 and ui.alpha:GetText()=="1")
        ui.colorMode.scripts.OnClick(); NS.W.menu.items[2].scripts.OnClick()
        assert(NS.DB.Current().rules.overrides.target.colorMode=="fixed")
        ui.scenarioPicker.scripts.OnClick(); NS.W.menu.next.scripts.OnClick(); NS.W.menu.items[5].scripts.OnClick()
        assert(ui.scenario==13 and ui.view.effect.category=="unknown")
    ''')


def test_fn2_malformed_rule_rows_and_envelope_rejected(runtime):
    runtime.execute('''
        local d=LibStub("LibDeflate")
        local function encode(raw)
            local blocks={}
            for i=1,#raw,160 do blocks[#blocks+1]=d:EncodeForPrint(d:CompressDeflate(raw:sub(i,i+159))) end
            return "FN2:"..table.concat(blocks,".")
        end
        assert(not NS.Share.Import(encode("2\\n44656d6f\\nmalformed")))
        local valid=NS.Share.Export(NS.DB.Current()); local raw={}
        for block in valid:sub(5):gmatch("[^.]+") do
            raw[#raw+1]=d:DecompressDeflate(d:DecodeForPrint(block))
        end
        local text=table.concat(raw)
        text=text:gsub("0;1;1.000000;1.000000;696e6865726974", "evil;1;1.000000;1.000000;696e6865726974",1)
        assert(not NS.Share.Import(encode(text)))
    ''')


def test_unavailable_or_rejected_native_raid_helper_hides_marker(runtime):
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current()); layout.elements[#layout.elements+1]=NS.Catalog.Create("raid","marker")
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,layout)
        local marker=view.parts[#view.parts]
        local helper=SetRaidTargetIconTexture
        SetRaidTargetIconTexture=nil; NS.Renderer.Update(view,{raidMarker=8}); assert(not marker.frame:IsShown())
        SetRaidTargetIconTexture=function() error("Rejected widget") end
        NS.Renderer.Update(view,{raidMarker=8}); assert(not marker.frame:IsShown())
        SetRaidTargetIconTexture=helper; NS.Renderer.Update(view,{raidMarker=8}); assert(marker.frame:IsShown())
    ''')
