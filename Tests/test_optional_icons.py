"""Public metadata, cast attachments and pooled optional icons; no real-client claim."""
import pytest


def test_cast_and_channel_metadata_never_inspect_secret_timing_fields(runtime):
    runtime.execute('''
        local secret=Mock.Secret()
        UnitCastingInfo=function() return "Fireball","Fireball",135812,secret,secret end
        UnitChannelInfo=function() error("Casting result should take precedence") end
        local state=NS.Compat.State("nameplate1",{cast=true})
        assert(state.casting and state.castName=="Fireball" and state.castIcon==135812)
        UnitCastingInfo=function() return nil end
        UnitChannelInfo=function() return "Drain","Drain",136168,secret,secret end
        state=NS.Compat.State("nameplate1",{cast=true})
        assert(state.casting and state.castName=="Drain" and state.castIcon==136168)
        UnitChannelInfo=function() return nil end
        state=NS.Compat.State("nameplate1",{cast=true})
        assert(not state.casting and state.castName=="" and state.castIcon==nil)
    ''')


def test_public_icon_with_secret_name_and_public_name_with_secret_icon(runtime):
    runtime.execute('''
        UnitCastingInfo=function() return Mock.Secret(),nil,135812 end
        local state=NS.Compat.State("nameplate1",{cast=true})
        assert(state.castName=="" and state.castIcon==135812 and state.casting)
        UnitCastingInfo=function() return "Fireball",nil,Mock.Secret() end
        state=NS.Compat.State("nameplate1",{cast=true})
        assert(state.castName=="Fireball" and state.castIcon==nil)
        UnitCastingInfo=function() return Mock.Secret(),nil,Mock.Secret() end
        state=NS.Compat.State("nameplate1",{cast=true})
        assert(state.castName=="" and state.castIcon==nil and not state.casting)
    ''')


@pytest.mark.parametrize("bad_icon", ["Mock.Secret()", "0", "-1", "1.5", "0/0", "math.huge", '"Interface/Icons/not-a-fileid"'])
def test_cast_metadata_rejects_invalid_icons(runtime, bad_icon):
    runtime.execute(f'''
        UnitCastingInfo=function() return "Fireball",nil,{bad_icon} end
        assert(NS.Compat.State("nameplate1",{{cast=true}}).castIcon==nil)
    ''')


def test_missing_and_refused_cast_apis_are_optional(runtime):
    runtime.execute('''
        UnitCastingInfo=nil; UnitChannelInfo=function() return "Drain",nil,136168 end
        assert(NS.Compat.State("nameplate1",{cast=true}).castIcon==136168)
        UnitCastingInfo=function() error("Unavailable") end; UnitChannelInfo=nil
        assert(not NS.Compat.State("nameplate1",{cast=true}).casting)
        UnitCastingInfo=nil; UnitChannelInfo=nil
        assert(NS.Compat.State("nameplate1",{cast=true}).castIcon==nil)
    ''')


@pytest.mark.parametrize("reverse_order", [False, True])
def test_cast_icon_follows_visible_castbar_including_stop_and_refusal(runtime, reverse_order):
    runtime.globals().reverseOrder = reverse_order
    runtime.execute('''
        local layout=NS.Copy(NS.GameNameplates[2].layout)
        local icon=NS.Catalog.Create("castIcon","spellIcon")
        table.insert(layout.elements,reverseOrder and 1 or #layout.elements+1,icon)
        assert(NS.DB.Save(layout)); local base=Mock.AddUnit("nameplate1")
        local u=Mock.units.nameplate1; u.duration={timer=true}
        UnitCastingInfo=function() return u.castName,nil,u.castIcon end
        u.castName="Fireball"; u.castIcon=135812
        NS.Engine.Add("nameplate1"); local view=NS.Engine.units.nameplate1
        local spell,bar
        for _,p in ipairs(view.parts) do if p.kind=="castIcon" then spell=p elseif p.kind=="cast" then bar=p end end
        assert(spell.frame:IsShown() and spell.icon.texture==135812 and base.UnitFrame:GetAlpha()==0)
        u.duration=nil; Mock.Fire(NS.events,"UNIT_SPELLCAST_STOP","nameplate1")
        assert(not spell.frame:IsShown() and view.replaced)
        u.duration={timer=true}; Mock.Fire(NS.events,"UNIT_SPELLCAST_START","nameplate1")
        assert(spell.frame:IsShown())
        bar.bar.SetTimerDuration=function() error("Timer refused") end
        Mock.Fire(NS.events,"UNIT_SPELLCAST_DELAYED","nameplate1")
        assert(not spell.frame:IsShown() and view.replaced)
        assert(NS.Engine.SetEnabled(false)); assert(base.UnitFrame:GetAlpha()==1 and not view.root:IsShown())
    ''')


def test_standalone_and_disabled_cast_icon_have_no_stale_preview(runtime):
    runtime.execute('''
        local layout={version=2,name="Spell",rules=NS.Rules.Defaults(),elements={NS.Catalog.Create("castIcon","spell")}}
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,layout)
        NS.Renderer.Update(view,{casting=true,castIcon=135812}); assert(view.parts[1].frame:IsShown())
        NS.Renderer.Update(view,{casting=false,castIcon=135812}); assert(not view.parts[1].frame:IsShown())
        NS.Renderer.Update(view,{casting=true,castIcon=Mock.Secret()}); assert(not view.parts[1].frame:IsShown())
        layout.elements[1].enabled=false; NS.Renderer.Apply(view,layout)
        NS.Renderer.Update(view,{casting=true,castIcon=135812}); assert(not view.parts[1].frame:IsShown() and not view.needs.cast)
    ''')


@pytest.mark.parametrize("result", ["false", "error", "secret"])
def test_refused_cast_icon_does_not_replace_blizzard_health_or_reveal_old_icon(runtime, result):
    runtime.globals().textureResult = result
    runtime.execute('''
        local layout=NS.Copy(NS.GameNameplates[2].layout)
        layout.elements[#layout.elements+1]=NS.Catalog.Create("castIcon","spell")
        assert(NS.DB.Save(layout)); local base=Mock.AddUnit("nameplate1")
        Mock.units.nameplate1.duration={timer=true}
        UnitCastingInfo=function() return "Fireball",nil,135812 end
        NS.Engine.Add("nameplate1"); local view=NS.Engine.units.nameplate1; local icon=view.parts[#view.parts]
        assert(icon.frame:IsShown())
        icon.icon.SetTexture=function()
            if textureResult=="error" then error("Missing icon") end
            if textureResult=="secret" then return Mock.Secret() end
            return false
        end
        Mock.Fire(NS.events,"UNIT_SPELLCAST_START","nameplate1")
        assert(not icon.frame:IsShown() and not icon.icon:IsShown() and view.replaced)
        assert(base.UnitFrame:GetAlpha()==0)
        NS.Engine.Refresh()
        assert(not icon.frame:IsShown() and not icon.icon:IsShown() and view.replaced)
        assert(base.UnitFrame:GetAlpha()==0)
    ''')


def test_class_icon_uses_only_public_player_class_and_available_native_atlas(runtime):
    runtime.execute('''
        local layout={version=2,name="Class",rules=NS.Rules.Defaults(),elements={NS.Catalog.Create("classIcon","job")}}
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,layout); local p=view.parts[1]
        Mock.atlases={["classicon-mage"]={width=64,height=64},["classicon-priest"]={width=64,height=64}}
        NS.Renderer.Update(view,{isPlayer=true,class="MAGE"})
        assert(p.frame:IsShown() and p.icon.atlas=="classicon-mage" and p.icon.atlasReset)
        NS.Renderer.Update(view,{isPlayer=true,class="PRIEST"}); assert(p.icon.atlas=="classicon-priest")
        for _,state in ipairs({{isPlayer=false,class="MAGE"},{isPlayer=true,class=Mock.Secret()},
            {isPlayer=true,class="INVALID"},{isPlayer=true},{class="MAGE"}}) do
            NS.Renderer.Update(view,state); assert(not p.frame:IsShown() and not p.icon:IsShown())
        end
        Mock.atlases["classicon-mage"]=Mock.Secret()
        NS.Renderer.Update(view,{isPlayer=true,class="MAGE"}); assert(not p.frame:IsShown())
        Mock.atlases={}; NS.Renderer.Update(view,{isPlayer=true,class="MAGE"}); assert(not p.frame:IsShown())
        Mock.atlases={["classicon-mage"]={width=64,height=64}}
        p.icon.SetAtlas=function() error("Atlas refused") end
        NS.Renderer.Update(view,{isPlayer=true,class="MAGE"}); assert(not p.frame:IsShown())
    ''')


def test_icon_pool_recycle_clears_old_metadata_and_does_not_allocate_on_update(runtime):
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current())
        layout.elements[#layout.elements+1]=NS.Catalog.Create("castIcon","spell")
        layout.elements[#layout.elements+1]=NS.Catalog.Create("classIcon","job")
        Mock.atlases={["classicon-mage"]={width=64,height=64}}
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,layout)
        local count=#Mock.frames
        for i=1,40 do
            NS.Renderer.Update(view,{casting=true,castIcon=135812,isPlayer=true,class="MAGE"})
            NS.Renderer.Update(view,{casting=false,isPlayer=false})
            for _,p in ipairs(view.parts) do if p.icon then assert(not p.frame:IsShown()) end end
        end
        NS.Renderer.Apply(view,NS.DB.Current()); NS.Renderer.Update(view,{})
        NS.Renderer.Apply(view,layout)
        for _,p in ipairs(view.parts) do if p.icon then assert(not p.icon:IsShown() and p.icon.texture==nil and p.icon.atlas==nil) end end
        NS.Renderer.Update(view,{})
        assert(#Mock.frames==count)
    ''')


@pytest.mark.parametrize("kind", ["castIcon", "classIcon"])
def test_icon_editor_history_share_and_combat_are_compatible(runtime, kind):
    runtime.globals().iconKind = kind
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio.session
        assert(s:Add(iconKind)); local id=s.selected; NS.Studio.Refresh()
        assert(s:Move(id,40,24) and s:Resize(id,32,32,false))
        local code=assert(NS.Share.Export(s.layout)); local imported=assert(NS.Share.Import(code))
        local last=imported.elements[#imported.elements]
        assert(last.kind==iconKind and last.width==32 and last.x==40)
        assert(s:Undo() and s:Redo())
        assert(not s:Update(id,{source="static"})); assert(s:Element().kind==iconKind)
        Mock.combat=true; assert(not s:Add(iconKind)); assert(not s:Update(id,{width=40}))
        Mock.combat=false; assert(s:ResetElement()); assert(s:Element().width==20)
    ''')


def test_live_class_icon_rechecks_identity_and_recycles_prepared_widgets_in_combat(runtime):
    runtime.execute('''
        local layout=NS.Copy(NS.GameNameplates[1].layout)
        layout.elements[#layout.elements+1]=NS.Catalog.Create("classIcon","job")
        Mock.atlases={["classicon-mage"]={width=64,height=64}}
        assert(NS.DB.Save(layout)); local base=Mock.AddUnit("nameplate1")
        Mock.units.nameplate1.isPlayer=true; Mock.units.nameplate1.class="MAGE"
        NS.Engine.Add("nameplate1"); local view=NS.Engine.units.nameplate1; local icon=view.parts[#view.parts]
        assert(icon.frame:IsShown() and view.replaced)
        C_Secrets={ShouldUnitIdentityBeSecret=function() return true end}
        UnitClassBase=function() error("Restricted class must not be queried") end
        Mock.combat=true; Mock.Fire(NS.events,"UNIT_HEALTH","nameplate1")
        assert(not icon.frame:IsShown() and view.replaced)
        NS.Engine.Remove("nameplate1"); Mock.plates.nameplate1=nil
        Mock.plates.nameplate2=base; Mock.units.nameplate2={health=20,maximum=100}
        local count=#Mock.frames; NS.Engine.Add("nameplate2")
        assert(NS.Engine.units.nameplate2==view and view.replaced and #Mock.frames==count)
        assert(not icon.frame:IsShown())
    ''')
