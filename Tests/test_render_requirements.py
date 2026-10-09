"""Measure unnecessary API calls without caching secret health or public unit identity."""


def test_classic_live_layout_queries_health_once_and_skips_unused_cast_metadata(runtime):
    runtime.execute('''
        assert(NS.DB.Save(NS.GameNameplates[1].layout)); Mock.AddUnit("nameplate1")
        local hp,max,cast,channel=0,0,0,0
        UnitHealth=function() hp=hp+1; return Mock.Secret() end
        UnitHealthMax=function() max=max+1; return Mock.Secret() end
        UnitCastingInfo=function() cast=cast+1; error("Unused cast metadata queried") end
        UnitChannelInfo=function() channel=channel+1; error("Unused channel metadata queried") end
        NS.Engine.Add("nameplate1"); local view=NS.Engine.units.nameplate1
        assert(view.replaced and hp==1 and max==1 and cast==0 and channel==0)
        for i=1,100 do Mock.Fire(NS.events,"UNIT_HEALTH","nameplate1") end
        assert(hp==101 and max==101 and cast==0 and channel==0 and view.replaced)
    ''')


def test_disabled_texts_skip_queries_and_enabled_health_text_updates_secret_safely(runtime):
    runtime.execute('''
        local layout={version=2,name="Needed",rules=NS.Rules.Defaults(),elements={
            NS.Catalog.Create("health","hp"),NS.Catalog.Create("text","label"),NS.Catalog.Create("cast","cast")}}
        layout.elements[2].source="name"; layout.elements[2].enabled=false
        local name,level,cast=0,0,0
        UnitName=function() name=name+1; return "Changed" end
        UnitLevel=function() level=level+1; return 60 end
        UnitCastingInfo=function() cast=cast+1; return nil end
        UnitChannelInfo=UnitCastingInfo
        assert(NS.DB.Save(layout)); Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        assert(name==0 and level==0 and cast==0)
        layout.elements[2].enabled=true; layout.elements[2].source="health"; assert(NS.DB.Save(layout))
        local view=NS.Engine.units.nameplate1; local label=view.parts[2]
        assert(label.text:GetText()=="70%")
        Mock.units.nameplate1.health=Mock.Secret(); Mock.Fire(NS.events,"UNIT_HEALTH","nameplate1")
        assert(label.text:GetText()=="—" and view.replaced)
        layout.elements[2].source="name"; assert(NS.DB.Save(layout))
        assert(label.text:GetText()=="Changed" and name>0)
        local calls=name; UnitName=function() name=name+1; return Mock.Secret() end
        Mock.Fire(NS.events,"UNIT_HEALTH","nameplate1")
        assert(name==calls+1 and label.text:GetText()=="" and view.replaced)
    ''')


def test_standalone_cast_background_still_requests_current_metadata(runtime):
    runtime.execute('''
        local e=NS.Model.Element("bg","artwork",0,0,84,8,{1,1,1,1},{asset="wow_df_cast_background"})
        local layout={version=2,name="Cast background",rules=NS.Rules.Defaults(),elements={e}}
        Mock.atlases={["ui-castingbar-background"]={width=84,height=8}}
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,layout)
        assert(view.needs.cast)
        UnitCastingInfo=function() return "Fireball" end
        NS.Renderer.Update(view,NS.Compat.State("nameplate1",view.needs)); assert(view.parts[1].frame:IsShown())
        UnitCastingInfo=function() return nil end
        NS.Renderer.Update(view,NS.Compat.State("nameplate1",view.needs)); assert(not view.parts[1].frame:IsShown())
    ''')
