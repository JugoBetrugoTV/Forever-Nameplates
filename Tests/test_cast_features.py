"""Cast direction, shield metadata and relevant global events in the Lua mock."""
import pytest


def test_channel_uses_remaining_duration_and_cast_uses_elapsed_duration(runtime):
    runtime.execute('''
        Enum={StatusBarInterpolation={Immediate=0},StatusBarTimerDirection={ElapsedTime=0,RemainingTime=1}}
        local duration=Mock.Secret(); local bar=CreateFrame("StatusBar")
        bar.SetTimerDuration=function(self,value,interpolation,direction)
            assert(value==duration and interpolation==0); self.direction=direction
        end
        UnitCastingDuration=function() return nil end
        UnitChannelDuration=function() return duration end
        -- A secret duration is intentionally unavailable; never unwrap it.
        assert(not NS.Compat.Cast(bar,"nameplate1"))
        duration={timer=true}; assert(NS.Compat.Cast(bar,"nameplate1") and bar.direction==1)
        UnitCastingDuration=function() return duration end
        assert(NS.Compat.Cast(bar,"nameplate1") and bar.direction==0)
    ''')


def test_global_events_skip_layouts_without_target_raid_or_level_dependencies(runtime):
    runtime.execute('''
        local layout={version=2,name="Health only",rules=NS.Rules.Defaults(),elements={NS.Catalog.Create("health","hp")}}
        assert(NS.DB.Save(layout)); Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local before=NS.Engine.stats.updates
        for i=1,100 do
            Mock.Fire(NS.events,"PLAYER_TARGET_CHANGED")
            Mock.Fire(NS.events,"RAID_TARGET_UPDATE")
            Mock.Fire(NS.events,"PLAYER_LEVEL_UP",61)
        end
        assert(NS.Engine.stats.updates==before,"Unrelated global events refreshed health-only plate")
        Mock.Fire(NS.events,"UNIT_HEALTH","nameplate1"); assert(NS.Engine.stats.updates==before+1)
    ''')


@pytest.mark.parametrize("broken_enum", ["nil", "Mock.Secret()", "{}", "{StatusBarInterpolation={Immediate=Mock.Secret()}}", "{StatusBarInterpolation={Immediate=0},StatusBarTimerDirection={RemainingTime=-1}}"])
def test_missing_or_secret_channel_direction_hides_channel_without_breaking_cast(runtime, broken_enum):
    runtime.execute(f'''
        Enum={broken_enum}
        local calls=0; local bar=CreateFrame("StatusBar")
        bar.SetTimerDuration=function() calls=calls+1 end
        UnitCastingDuration=function() return nil end; UnitChannelDuration=function() return {{timer=true}} end
        assert(not NS.Compat.Cast(bar,"nameplate1") and calls==0)
        UnitCastingDuration=function() return {{timer=true}} end
        assert(NS.Compat.Cast(bar,"nameplate1") and calls==1)
    ''')


@pytest.mark.parametrize("channel", [False, True])
def test_shield_flag_uses_documented_cast_or_channel_position_and_ignores_secret_times(runtime, channel):
    runtime.globals().channelCase = channel
    runtime.execute('''
        local flag=true; local secret=Mock.Secret()
        if channelCase then
            UnitCastingInfo=function() return nil end
            UnitChannelInfo=function() return "Drain",nil,136168,secret,secret,false,flag,999 end
        else
            UnitCastingInfo=function() return "Fireball",nil,135812,secret,secret,false,999,flag end
            UnitChannelInfo=function() error("Unexpected fallback") end
        end
        local state=NS.Compat.State("nameplate1",{cast=true,shield=true})
        assert(state.castShield==true)
        flag=false; state=NS.Compat.State("nameplate1",{cast=true,shield=true})
        assert(state.castShield==false)
        flag=Mock.Secret(); state=NS.Compat.State("nameplate1",{cast=true,shield=true})
        assert(state.castShield==nil and state.castName~="")
        flag=true; state=NS.Compat.State("nameplate1",{cast=true})
        assert(state.castShield==nil)
    ''')


@pytest.mark.parametrize("reverse_order", [False, True])
def test_live_shield_tracks_interruptibility_events_and_visible_castbar(runtime, reverse_order):
    runtime.globals().reverseOrder = reverse_order
    runtime.execute('''
        local layout=NS.Copy(NS.GameNameplates[2].layout)
        table.insert(layout.elements,reverseOrder and 1 or #layout.elements+1,NS.Catalog.Create("castShield","shield"))
        Mock.atlases={["nameplates-InterruptShield"]={width=14,height=16}}
        assert(NS.DB.Save(layout)); Mock.AddUnit("nameplate1")
        local flag=true
        UnitCastingInfo=function() return "Fireball",nil,135812,Mock.Secret(),Mock.Secret(),false,77,flag end
        Mock.units.nameplate1.duration={timer=true}; NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; local shield,bar
        for _,p in ipairs(view.parts) do if p.kind=="castShield" then shield=p elseif p.kind=="cast" then bar=p end end
        assert(shield.frame:IsShown() and shield.icon.atlas=="nameplates-InterruptShield")
        flag=false; Mock.Fire(NS.events,"UNIT_SPELLCAST_INTERRUPTIBLE","nameplate1")
        assert(not shield.frame:IsShown())
        flag=true; Mock.Fire(NS.events,"UNIT_SPELLCAST_NOT_INTERRUPTIBLE","nameplate1")
        assert(shield.frame:IsShown())
        flag=Mock.Secret(); Mock.Fire(NS.events,"UNIT_SPELLCAST_NOT_INTERRUPTIBLE","nameplate1")
        assert(not shield.frame:IsShown() and view.replaced)
        flag=true; Mock.units.nameplate1.duration=nil
        Mock.Fire(NS.events,"UNIT_SPELLCAST_STOP","nameplate1"); assert(not shield.frame:IsShown())
        Mock.units.nameplate1.duration={timer=true}; bar.bar.SetTimerDuration=function() error("Timer denied") end
        Mock.Fire(NS.events,"UNIT_SPELLCAST_START","nameplate1"); assert(not shield.frame:IsShown() and view.replaced)
    ''')


def test_shield_missing_atlas_refused_atlas_standalone_disabled_and_pooling(runtime):
    runtime.execute('''
        local layout={version=2,name="Shield",rules=NS.Rules.Defaults(),elements={NS.Catalog.Create("castShield","shield")}}
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,layout)
        local p=view.parts[1]; local state={casting=true,castShield=true}
        NS.Renderer.Update(view,state); assert(not p.frame:IsShown())
        Mock.atlases={["nameplates-InterruptShield"]={width=14,height=16}}
        NS.Renderer.Update(view,state); assert(p.frame:IsShown())
        local count=#Mock.frames
        for _,flag in ipairs({false,Mock.Secret(),1,"true"}) do
            NS.Renderer.Update(view,{casting=true,castShield=flag}); assert(not p.frame:IsShown())
        end
        NS.Renderer.Update(view,{casting=false,castShield=true}); assert(not p.frame:IsShown())
        local setAtlas=p.icon.SetAtlas; p.icon.SetAtlas=function() error("Atlas denied") end
        NS.Renderer.Update(view,state); assert(not p.frame:IsShown())
        p.icon.SetAtlas=setAtlas
        layout.elements[1].enabled=false; NS.Renderer.Apply(view,layout)
        NS.Renderer.Update(view,state); assert(not p.frame:IsShown() and not view.needs.shield)
        layout.elements[1].enabled=true; NS.Renderer.Apply(view,layout)
        assert(p.icon.atlas==nil and not p.icon:IsShown())
        NS.Renderer.Update(view,state); assert(p.frame:IsShown() and #Mock.frames==count)
    ''')


def test_shield_editor_share_and_undo_preserve_existing_layout_fields(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        assert(s:Add("castShield")); local id=s.selected
        assert(s:Move(id,40,-32) and s:Resize(id,24,28,false))
        local result=assert(NS.Share.Import(NS.Share.Export(s.layout)))
        local e=result.elements[#result.elements]
        assert(e.kind=="castShield" and e.source=="cast" and e.width==24 and e.y==-32)
        assert(s:Undo() and s:Redo()); assert(not s:Update(id,{source="static"}))
        Mock.combat=true; assert(not s:Add("castShield")); Mock.combat=false
        assert(s:ResetElement() and s:Element().width==10)
    ''')


def test_dependency_flags_include_target_rules_and_skip_unrequested_unit_queries(runtime):
    runtime.execute('''
        local layout={version=2,name="Plain",rules=NS.Rules.Defaults(),elements={NS.Catalog.Create("health","hp")}}
        local targets,raids=0,0
        UnitIsUnit=function() targets=targets+1; return true end
        GetRaidTargetIndex=function() raids=raids+1; return 8 end
        assert(NS.DB.Save(layout)); Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1
        assert(targets==0 and raids==0 and NS.Compat.State("nameplate1",view.needs).target==nil)
        layout.rules.overrides.target.enabled=true; layout.rules.overrides.target.alpha=.3
        assert(NS.DB.Save(layout)); local before=NS.Engine.stats.updates
        Mock.Fire(NS.events,"PLAYER_TARGET_CHANGED")
        assert(NS.Engine.stats.updates==before+1 and view.effect.alpha==.3 and targets>0)
        layout.rules.overrides.target.enabled=false; layout.rules.overrides.nonTarget.enabled=true
        assert(NS.DB.Save(layout)); assert(view.needs.target)
        layout.elements[#layout.elements+1]=NS.Catalog.Create("raid","raid")
        layout.elements[#layout.elements+1]=NS.Model.Element("level","text",0,0,20,12,{1,1,1,1},{source="level"})
        assert(NS.DB.Save(layout)); before=NS.Engine.stats.updates
        Mock.Fire(NS.events,"RAID_TARGET_UPDATE"); Mock.Fire(NS.events,"PLAYER_LEVEL_UP",61)
        assert(NS.Engine.stats.updates==before+2 and raids>0)
    ''')


def test_global_update_batch_tolerates_removal_and_new_bindings(runtime):
    runtime.execute('''
        NS.Engine.units={nameplate1={needs={target=true}},nameplate2={needs={target=true}},nameplate3={needs={}}}
        local calls={}
        NS.Engine.Update=function(unit)
            calls[#calls+1]=unit; NS.Engine.units[unit]=nil
            NS.Engine.units.nameplate4={needs={target=true}}
        end
        NS.Engine.UpdateAll("target")
        assert(#calls==2 and calls[1]~=calls[2])
        for _,unit in ipairs(calls) do assert(unit=="nameplate1" or unit=="nameplate2") end
        assert(NS.Engine.units.nameplate3 and NS.Engine.units.nameplate4)
    ''')


def test_forty_health_only_plates_skip_three_hundred_global_events_and_still_receive_health(runtime):
    runtime.execute('''
        local layout={version=2,name="Health",rules=NS.Rules.Defaults(),elements={NS.Catalog.Create("health","hp")}}
        assert(NS.DB.Save(layout))
        for i=1,40 do local token="nameplate"..i; Mock.AddUnit(token); NS.Engine.Add(token) end
        local before=NS.Engine.stats.updates; local widgets=#Mock.frames
        for i=1,100 do
            Mock.Fire(NS.events,"PLAYER_TARGET_CHANGED")
            Mock.Fire(NS.events,"RAID_TARGET_UPDATE")
            Mock.Fire(NS.events,"PLAYER_LEVEL_UP",61)
        end
        assert(NS.Engine.stats.updates==before)
        for i=1,40 do Mock.Fire(NS.events,"UNIT_HEALTH","nameplate"..i) end
        assert(NS.Engine.stats.updates==before+40 and #Mock.frames==widgets)
    ''')
