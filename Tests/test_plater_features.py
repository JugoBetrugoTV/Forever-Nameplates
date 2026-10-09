import pytest


def test_anchor_follows_resized_moved_reference_and_fn3_roundtrip(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        assert(s:Add("castIcon")); local id=s.selected
        assert(s:SetAnchor("health","RIGHT","LEFT",true))
        local pos=NS.Features.Positions(s.layout)[id]; local hp=s:Element("health")
        assert(pos.x==hp.x-hp.width/2-s:Element().width/2 and pos.y==hp.y)
        assert(s:Update("health",{width=256,x=30,y=12}))
        pos=NS.Features.Positions(s.layout)[id]
        assert(pos.x==30-128-s:Element().width/2 and pos.y==12)
        local view=NS.Renderer.Create(UIParent); assert(NS.Renderer.Apply(view,s.layout))
        local part=view.parts[#view.parts]
        assert(part.frame.point[1]=="RIGHT" and part.frame.point[2]==view.parts[2].frame and part.frame.point[3]=="LEFT")
        local code=assert(NS.Share.Export(s.layout)); assert(code:sub(1,4)=="FN3:")
        local decoded=assert(NS.Share.Import(code)); assert(decoded.elements[#decoded.elements].anchor.ref=="health")
        assert(NS.Features.Positions(decoded)[id].x==pos.x)
        assert(s:SetAnchor("","CENTER","CENTER")); assert(not s:Element().anchor and s:Element().x==pos.x)
        assert(s:Undo()); assert(s:Element().anchor.ref=="health")
        assert(s:Redo()); assert(not s:Element().anchor)
    ''')


@pytest.mark.parametrize("point", ["CENTER", "LEFT", "RIGHT", "TOP", "BOTTOM", "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"])
def test_relative_resize_preserves_top_left_for_every_anchor(runtime, point):
    runtime.globals().anchor_point = point
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current()); assert(s:Add("classIcon")); s.snap=0
        assert(s:SetAnchor("health",anchor_point,"TOPRIGHT",true))
        local e=s:Element(); local before=NS.Features.Positions(s.layout)[e.id]
        local left,top=before.x-e.width/2,before.y+e.height/2
        assert(s:Resize(e.id,40,30,true)); e=s:Element()
        local after=NS.Features.Positions(s.layout)[e.id]
        assert(after.x-e.width/2==left and after.y+e.height/2==top)
        assert(s:Align(e.id,"right","health")); after=NS.Features.Positions(s.layout)[e.id]
        local hp=s:Element("health"); assert(after.x+e.width/2==hp.x+hp.width/2)
    ''')


def test_anchor_cycles_missing_refs_delete_locks_and_combat_are_atomic(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current()); s.selected="name"
        local count=#s.undo
        assert(not s:SetAnchor("name","LEFT","RIGHT") and #s.undo==count)
        assert(not s:SetAnchor("missing","LEFT","RIGHT") and #s.undo==count)
        assert(s:SetAnchor("health","LEFT","RIGHT",true))
        s.selected="health"; count=#s.undo
        assert(not s:SetAnchor("name","LEFT","RIGHT") and #s.undo==count)
        assert(s:Update("name",{locked=true})); count=#s.undo
        assert(not s:Delete() and s:Element("health") and #s.undo==count)
        assert(s:Update("name",{locked=false}))
        local position=NS.Features.Positions(s.layout).name
        assert(s:Delete()); local name=s:Element("name")
        assert(not name.anchor and name.x==position.x and name.y==position.y)
        assert(s:Undo() and s:Element("name").anchor.ref=="health")
        Mock.combat=true; s.selected="name"; count=#s.undo
        assert(not s:SetAnchor("back","CENTER","CENTER") and #s.undo==count)
    ''')


@pytest.mark.parametrize("patch", ["e.anchor={ref='missing',point='CENTER',relativePoint='CENTER'}",
    "e.anchor={ref='health',point='INVALID',relativePoint='CENTER'}", "e.castStyle={enabled=true}",
    "a.limit=13", "a.columns=0", "a.size=100", "a.gap=-1", "a.own='yes'", "a.sort='evil'",
    "a.listMode='code'", "a.spells='loadstring()'", "a.spells='0'", "a.spells='999999999999999999999'"])
def test_feature_validation_rejects_invalid_data(runtime, patch):
    runtime.globals().bad_patch = patch
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current())
        layout.elements[#layout.elements+1]=NS.Catalog.Create("auras","row")
        local e=layout.elements[#layout.elements]; local a=e.aura
        local mutate=assert(loadstring("return function(e,a) "..bad_patch.." end"))()
        mutate(e,a)
        assert(not NS.Model.Validate(layout)); assert(not NS.Share.Export(layout))
    ''')


def test_fn3_extensions_savedvariables_migrate_and_reject_malformed_header(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        assert(NS.Share.Export(s.layout):sub(1,4)=="FN2:")
        assert(s:Add("auras")); assert(s:UpdateFeature("aura",{filter="HELPFUL",sort="NameOnly",direction="Reverse",own=true,
            limit=12,columns=3,size=24,gap=4,listMode="include",spells="116, 172"}))
        assert(s:SetAnchor("health","BOTTOM","TOP",true))
        assert(s:Add("cast")); assert(s:UpdateFeature("castStyle",{enabled=true,spark=true,sparkWidth=15,sparkAlpha=.4}))
        local code=assert(NS.Share.Export(s.layout)); local decoded=assert(NS.Share.Import(code))
        local aura=decoded.elements[#decoded.elements-1]
        assert(aura.anchor.ref=="health" and aura.aura.columns==3 and aura.aura.spells=="116, 172")
        assert(decoded.elements[#decoded.elements].castStyle.sparkWidth==15)
        assert(decoded.elements[#decoded.elements].castStyle.sparkAlpha==.4)
        local saved=NS.Copy(NS.DB.data); saved.version=2; local copy=NS.DB.Initialize(saved)
        assert(copy.version==3 and copy.profiles.Default.elements[#decoded.elements].castStyle.spark)
        local plain=NS.Share.Export(NS.Presets[1].layout)
        assert(not NS.Share.Import("FN3:"..plain:sub(5)))
        assert(not NS.Share.Import("FN2:"..code:sub(5)))
    ''')


def test_aura_client_filter_sort_public_metadata_and_duration_forwarding(runtime):
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current()); local e=NS.Catalog.Create("auras","row")
        e.aura.sort="ExpirationOnly"; e.aura.direction="Reverse"; e.aura.own=true
        layout.elements[#layout.elements+1]=e
        Enum={UnitAuraSortRule={ExpirationOnly=4},UnitAuraSortDirection={Reverse=1}}
        local duration=Mock.Secret(); local calls=0
        C_UnitAuras={GetUnitAuras=function(unit,filter,maximum,rule,direction)
            calls=calls+1; assert(filter=="HARMFUL|PLAYER" and maximum==40 and rule==4 and direction==1)
            return {Mock.Secret(),{icon=Mock.Secret(),auraInstanceID=1},
                {icon=136118,auraInstanceID=2,spellId=172,applications=3,expirationTime=Mock.Secret(),sourceUnit=Mock.Secret()},
                {icon=135846,auraInstanceID=Mock.Secret(),spellId=Mock.Secret(),applications=Mock.Secret()}}
        end,GetAuraDuration=function(unit,id) assert(id==2); return duration end}
        assert(NS.DB.Save(layout)); Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; local part=view.parts[#view.parts]; local slots=part.auraSlots
        assert(view.replaced and part.frame:IsShown() and slots[1].icon.texture==136118 and slots[2].icon.texture==135846)
        assert(slots[1].count:GetText()=="3" and slots[2].count:GetText()=="")
        assert(slots[1].cooldown.cooldownDuration==duration and slots[1].cooldown:IsShown())
        assert(not slots[2].cooldown:IsShown())
        local widgets=#Mock.frames
        for i=1,20 do Mock.Fire(NS.events,"UNIT_HEALTH","nameplate1") end
        assert(calls==1 and #Mock.frames==widgets)
        Mock.Fire(NS.events,"UNIT_AURA","nameplate1"); assert(calls==2 and #Mock.frames==widgets)
        C_UnitAuras.GetUnitAuras=function() return {} end
        Mock.Fire(NS.events,"UNIT_AURA","nameplate1")
        assert(not part.frame:IsShown() and slots[1].count:GetText()=="" and not slots[1].cooldown.cooldownDuration and view.replaced)
    ''')


@pytest.mark.parametrize("mode,expected", [("all", 3), ("include", 1), ("exclude", 1)])
def test_aura_spell_filters_exclude_unknown_ids_in_explicit_lists(runtime, mode, expected):
    runtime.globals().list_mode = mode
    runtime.globals().expected_icons = expected
    runtime.execute('''
        C_UnitAuras={GetUnitAuras=function() return {{icon=1,spellId=116},{icon=2,spellId=172},{icon=3,spellId=Mock.Secret()}} end}
        local config=NS.Features.AuraDefaults(); config.listMode=list_mode; config.spells="116"
        local values=NS.Auras.Read("nameplate1",config)
        assert(#values==expected_icons)
        if list_mode=="include" then assert(values[1].icon==1) elseif list_mode=="exclude" then assert(values[1].icon==2) end
    ''')


@pytest.mark.parametrize("failure", ["missing_api", "secret_list", "missing_enum", "secret_enum", "texture", "duration"])
def test_optional_aura_failure_preserves_health_replacement(runtime, failure):
    runtime.globals().aura_failure = failure
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current()); local e=NS.Catalog.Create("auras","row"); layout.elements[#layout.elements+1]=e
        C_UnitAuras={GetUnitAuras=function() return {{icon=135846,auraInstanceID=1}} end,GetAuraDuration=function() error("Denied") end}
        if aura_failure=="missing_api" then C_UnitAuras=nil
        elseif aura_failure=="secret_list" then C_UnitAuras.GetUnitAuras=function() return Mock.Secret() end
        elseif aura_failure=="missing_enum" then e.aura.sort="NameOnly"
        elseif aura_failure=="secret_enum" then e.aura.sort="NameOnly"; Enum={UnitAuraSortRule={NameOnly=Mock.Secret()}} end
        assert(NS.DB.Save(layout)); Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; local part=view.parts[#view.parts]
        if aura_failure=="texture" then
            part.auraSlots[1].icon.SetTexture=function() return Mock.Secret() end
            Mock.Fire(NS.events,"UNIT_AURA","nameplate1")
        end
        assert(view.replaced and view.parts[2].bar.value==70)
        if aura_failure=="duration" then assert(part.frame:IsShown() and not part.auraSlots[1].cooldown:IsShown())
        else assert(not part.frame:IsShown()) end
    ''')


def test_cast_colors_and_texture_spark_direction_stop_pool_and_no_timing_math(runtime):
    runtime.execute('''
        local layout=NS.Copy(NS.GameNameplates[1].layout); local e=NS.Catalog.Create("cast","spell")
        e.castStyle=NS.Features.CastDefaults(); e.castStyle.enabled=true; e.castStyle.spark=true
        e.reverse=true; layout.elements[#layout.elements+1]=e
        Enum={StatusBarInterpolation={Immediate=0},StatusBarTimerDirection={ElapsedTime=0,RemainingTime=1}}
        local duration=Mock.Secret()
        UnitCastingDuration=function() return nil end
        UnitChannelDuration=function() return {opaque=true} end
        UnitChannelInfo=function() return Mock.Secret(),nil,136096,Mock.Secret(),Mock.Secret(),nil,false end
        assert(NS.DB.Save(layout)); Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; local part=view.parts[#view.parts]
        assert(part.frame:IsShown() and part.spark:IsShown() and part.bar.statusColor[1]==e.castStyle.channel[1])
        assert(part.spark.point[2]==part.bar:GetStatusBarTexture() and part.spark.point[3]=="LEFT")
        UnitChannelInfo=function() return "Channel",nil,136096,Mock.Secret(),Mock.Secret(),nil,true end
        Mock.Fire(NS.events,"UNIT_SPELLCAST_NOT_INTERRUPTIBLE","nameplate1")
        assert(part.bar.statusColor[1]==e.castStyle.shield[1])
        UnitChannelDuration=function() return nil end; UnitChannelInfo=function() return nil end
        Mock.Fire(NS.events,"UNIT_SPELLCAST_CHANNEL_STOP","nameplate1")
        assert(not part.frame:IsShown() and not part.spark:IsShown() and view.replaced)
        local before=#Mock.frames
        UnitCastingDuration=function() return {opaque=true} end
        UnitCastingInfo=function() return "Bolt",nil,136096,Mock.Secret(),Mock.Secret(),nil,nil,Mock.Secret() end
        Mock.Fire(NS.events,"UNIT_SPELLCAST_START","nameplate1")
        assert(part.spark:IsShown() and part.bar.statusColor[1]==e.castStyle.normal[1] and #Mock.frames==before)
    ''')


def test_unit_updates_skip_cast_auras_health_and_static_decorations_when_unrelated(runtime):
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current()); layout.elements[#layout.elements+1]=NS.Catalog.Create("auras","row")
        assert(NS.DB.Save(layout)); Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; local castCalls,healthCalls,auraCalls,staticCalls=0,0,0,0
        UnitCastingInfo=function() castCalls=castCalls+1; return "Bolt" end
        UnitCastingDuration=function() castCalls=castCalls+1; return {} end
        UnitHealth=function() healthCalls=healthCalls+1; return 70 end
        C_UnitAuras={GetUnitAuras=function() auraCalls=auraCalls+1; return {} end}
        local panel=view.parts[1]; local setShown=panel.frame.SetShown
        panel.frame.SetShown=function(self,value) staticCalls=staticCalls+1; setShown(self,value) end
        for i=1,40 do Mock.Fire(NS.events,"UNIT_HEALTH","nameplate1") end
        assert(castCalls==0 and auraCalls==0 and healthCalls>0 and staticCalls==0)
        healthCalls=0
        Mock.Fire(NS.events,"UNIT_AURA","nameplate1")
        assert(auraCalls==1 and healthCalls==0 and castCalls==0 and staticCalls==0)
        Mock.Fire(NS.events,"UNIT_SPELLCAST_START","nameplate1")
        assert(castCalls>0 and healthCalls==0 and auraCalls==1 and staticCalls==0)
    ''')


@pytest.mark.parametrize("page,builder", [("gallery", "CreateGallery"), ("sandbox", "CreateSandbox"), ("rules", "CreateRules"),
    ("profiles", "CreateProfiles"), ("diagnostics", "CreateDiagnostics"), ("components", "CreateComponents"), ("search", "CreateSearch")])
def test_lazy_pages_build_once_and_discard_partial_failures(runtime, page, builder):
    runtime.globals().lazy_page = page
    runtime.globals().lazy_builder = builder
    runtime.execute('''
        local s=NS.Studio; s.Open()
        assert(s.built.studio and not s.built[lazy_page] and #s.sandboxViews==0)
        local root=s.root; local build=s[lazy_builder]
        local fonts,surfaces,numbers=#NS.W.fonts,#NS.W.surfaces,#NS.W.numbers
        s[lazy_builder]=function(page) build(page); error("Lazy construction failure") end
        assert(not s.ShowPage(lazy_page))
        assert(s.ready and s.root==root and not s.built[lazy_page] and s.page=="studio")
        assert(#NS.W.fonts==fonts and #NS.W.surfaces==surfaces and #NS.W.numbers==numbers and #s.sandboxViews==0)
        s[lazy_builder]=build; assert(s.ShowPage(lazy_page) and s.built[lazy_page])
        local widgets=#Mock.frames
        s.ShowPage("studio"); s.ShowPage(lazy_page)
        assert(#Mock.frames==widgets and #UISpecialFrames==1)
        Mock.combat=true; assert(not s.ShowPage("profiles"))
    ''')


def test_search_finds_german_english_keywords_opens_lazy_page_and_marks_control(runtime):
    runtime.execute('''
        local s=NS.Studio; s.Open()
        assert(#NS.Settings.Find("Deckkraft")>=1 and #NS.Settings.Find("Aura Spalten")==1)
        assert(#NS.Settings.Find("%[]") == 0)
        s.SearchCommand("minimap"); assert(s.built.search and not s.built.diagnostics)
        local ui=s.searchUI; assert(ui.results[1]:IsShown())
        ui.results[1].scripts.OnClick()
        assert(s.page=="diagnostics" and s.built.diagnostics and s.minimapVisible.searchMark:IsShown())
        Mock.RunTimers(); assert(not s.minimapVisible.searchMark:IsShown())
        s.SearchCommand(""); assert(ui.next:IsEnabled()); ui.next.scripts.OnClick(); assert(ui.page==2)
        ui.query:SetText("no such setting"); assert(not ui.results[1]:IsShown() and not ui.next:IsEnabled())
        assert(s.session:Add("auras")); s.Refresh(); s.SearchCommand("Aura Spalten")
        ui.results[1].scripts.OnClick(); assert(s.page=="components" and s.session:Element().kind=="auras")
        assert(s.componentUI.aura.columns:IsEnabled() and s.componentUI.aura.columns.searchMark:IsShown())
        Mock.combat=true; assert(not NS.Settings.Open(NS.Settings.Find("minimap")[1]))
    ''')


def test_settings_tooltips_explain_numeric_bounds_and_disabled_controls(runtime):
    runtime.execute('''
        local s=NS.Studio; s.Open()
        GameTooltip=CreateFrame("Frame",nil,UIParent)
        function GameTooltip:SetOwner(owner,anchor) self.owner=owner end
        function GameTooltip:AddLine(text) self.lastLine=text; self.lines=(self.lines or "")..text end
        local f=s.inspector.fields.x; f.scripts.OnEnter(f)
        assert(GameTooltip.owner==f and GameTooltip.lines:find("512",1,true) and GameTooltip:IsShown())
        f.scripts.OnLeave(f); assert(not GameTooltip:IsShown())
        s.ShowPage("components"); local c=s.componentUI.aura.columns
        assert(not c:IsEnabled()); c.scripts.OnEnter(c)
        assert(GameTooltip.lastLine:find("Unlock",1,true))
    ''')


def test_component_gui_controls_aura_filters_anchors_casts_and_undo(runtime):
    runtime.execute('''
        local s=NS.Studio; s.Open(); s.addButton.scripts.OnClick()
        NS.W.menu.next.scripts.OnClick(); NS.W.menu.items[5].scripts.OnClick()
        assert(s.session:Element().kind=="auras")
        s.componentButton.scripts.OnClick(); local ui=s.componentUI
        ui.aura.columns.minus.scripts.OnClick(); assert(s.session:Element().aura.columns==7)
        ui.aura.size.plus.scripts.OnClick(); assert(s.session:Element().aura.size==21)
        ui.aura.filter.scripts.OnClick(); NS.W.menu.items[2].scripts.OnClick(); assert(s.session:Element().aura.filter=="HELPFUL")
        ui.aura.own.scripts.OnClick(); assert(s.session:Element().aura.own)
        ui.aura.spells:SetFocus(); ui.aura.spells:SetText("1459"); ui.aura.spells:ClearFocus()
        assert(s.session:Element().aura.spells=="1459")
        ui.reference.scripts.OnClick(); NS.W.menu.items[3].scripts.OnClick()
        assert(s.session:Element().anchor.ref=="health")
        ui.snap.scripts.OnClick(); assert(s.session:Element().x==0 and s.session:Element().y==0)
        local p=NS.Features.Positions(s.session.layout)[s.session.selected]
        assert(p.x==s.session:Element("health").width/2+s.session:Element().width/2)
        assert(s.session:Undo()); s.Refresh()
        assert(s.session:Add("cast")); s.Refresh(); ui.cast.enabled.scripts.OnClick(); ui.cast.spark.scripts.OnClick()
        assert(s.session:Element().castStyle.enabled and s.session:Element().castStyle.spark)
        s.scenario=14; s.Refresh(); local part=s.view.parts[#s.view.parts]
        assert(part.spark:IsShown() and part.bar.statusColor[1]==s.session:Element().castStyle.channel[1])
        assert(s.Change({locked=true})); assert(not ui.cast.enabled:IsEnabled() and not ui.reference:IsEnabled())
    ''')


@pytest.mark.parametrize("action", ["release", "page", "selection", "hide", "combat"])
def test_component_slider_preview_commits_once_or_discards_without_saving(runtime, action):
    runtime.globals().slider_action = action
    runtime.execute('''
        local s=NS.Studio; s.Open(); assert(s.session:Add("auras")); s.ShowPage("components")
        local id=s.session.selected; local f=s.componentUI.aura.size; local original=s.session:Element().aura.size
        local count=#s.session.undo
        f.slider.scripts.OnMouseDown(f.slider,"LeftButton"); f.slider:SetValue(28,true)
        local part=s.componentUI.view.parts[#s.componentUI.view.parts]
        assert(part.element.aura.size==28 and part.auraSlots[1].frame:GetWidth()==28)
        assert(s.session:Element().aura.size==original and NS.DB.Current().elements[#s.session.layout.elements].aura.size==original)
        assert(#s.session.undo==count)
        if slider_action=="page" then s.ShowPage("rules")
        elseif slider_action=="selection" then s.Select("health")
        elseif slider_action=="hide" then s.root:Hide()
        elseif slider_action=="combat" then Mock.combat=true; Mock.Fire(NS.events,"PLAYER_REGEN_DISABLED") end
        f.slider.scripts.OnMouseUp(f.slider,"LeftButton")
        if slider_action=="release" then
            assert(s.session:Element(id).aura.size==28 and #s.session.undo==count+1)
            assert(s.session:Undo() and s.session:Element(id).aura.size==original)
        else
            assert(s.session:Element(id).aura.size==original and #s.session.undo==count)
            assert(s.componentUI.view.parts[#s.componentUI.view.parts].element.aura.size==original)
        end
        assert(not f.dragging)
    ''')


def test_aura_preview_applies_client_equivalent_filters_and_sorting_to_explicit_samples(runtime):
    runtime.execute('''
        local samples=NS.Studio.scenarios[1].auras; local config=NS.Features.AuraDefaults()
        local a=NS.Auras.Preview(samples,config); assert(#a==2 and a[1].icon==135846 and a[2].count==3)
        config.sort="ExpirationOnly"; config.direction="Reverse"
        a=NS.Auras.Preview(samples,config); assert(a[1].icon==136118)
        config.own=true; a=NS.Auras.Preview(samples,config); assert(#a==1 and a[1].icon==135846)
        config.own=false; config.listMode="include"; config.spells="172"
        a=NS.Auras.Preview(samples,config); assert(#a==1 and a[1].icon==136118)
        config.filter="HELPFUL"; config.listMode="all"; a=NS.Auras.Preview(samples,config)
        assert(#a==1 and a[1].icon==135932)
    ''')


def test_partial_updates_cannot_replace_blizzard_after_health_forwarding_failure(runtime):
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current()); layout.elements[#layout.elements+1]=NS.Catalog.Create("auras","row")
        assert(NS.DB.Save(layout)); local base=Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; local hp=view.parts[2].bar; local setter=hp.SetValue
        hp.SetValue=function() error("Health forwarding denied") end
        Mock.Fire(NS.events,"UNIT_HEALTH","nameplate1"); assert(not view.replaced and base.UnitFrame:GetAlpha()==1)
        Mock.Fire(NS.events,"UNIT_AURA","nameplate1")
        Mock.Fire(NS.events,"UNIT_SPELLCAST_START","nameplate1")
        assert(not view.replaced and not view.root:IsShown() and base.UnitFrame:GetAlpha()==1)
        hp.SetValue=setter; Mock.Fire(NS.events,"UNIT_HEALTH","nameplate1")
        assert(view.replaced and view.root:IsShown() and base.UnitFrame:GetAlpha()==0)
    ''')


def test_aura_recycling_in_combat_clears_previous_icons_counts_and_cooldowns(runtime):
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current()); layout.elements[#layout.elements+1]=NS.Catalog.Create("auras","row")
        C_UnitAuras={GetUnitAuras=function() return {{icon=135846,applications=5,auraInstanceID=1}} end,
            GetAuraDuration=function() return {opaque=true} end}
        assert(NS.DB.Save(layout)); Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; local row=view.parts[#view.parts]
        assert(row.auraSlots[1].count:GetText()=="5" and row.auraSlots[1].cooldown:IsShown())
        NS.Engine.Remove("nameplate1"); local before=#Mock.frames
        C_UnitAuras.GetUnitAuras=function() return {} end
        Mock.combat=true; NS.Engine.Add("nameplate1")
        assert(NS.Engine.units.nameplate1==view and #Mock.frames==before and view.replaced)
        assert(not row.frame:IsShown() and row.auraSlots[1].count:GetText()=="")
        assert(not row.auraSlots[1].cooldown:IsShown() and row.auraSlots[1].cooldown.cooldownDuration==nil)
    ''')


@pytest.mark.parametrize("vertical,reverse,edge", [(False,False,"RIGHT"),(False,True,"LEFT"),(True,False,"TOP"),(True,True,"BOTTOM")])
def test_spark_tracks_the_correct_fill_edge_without_timer_updates(runtime, vertical, reverse, edge):
    runtime.globals().spark_vertical = vertical
    runtime.globals().spark_reverse = reverse
    runtime.globals().spark_edge = edge
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current()); local e=NS.Catalog.Create("cast","spark")
        e.castStyle=NS.Features.CastDefaults(); e.castStyle.spark=true; e.vertical=spark_vertical; e.reverse=spark_reverse
        layout.elements[#layout.elements+1]=e
        local view=NS.Renderer.Create(UIParent); assert(NS.Renderer.Apply(view,layout)); NS.Renderer.Update(view,{casting=true})
        local part=view.parts[#view.parts]
        assert(part.spark:IsShown() and part.spark.point[3]==spark_edge and not part.frame.scripts.OnUpdate)
        e.castStyle.spark=false; NS.Renderer.Apply(view,layout); NS.Renderer.Update(view,{casting=true})
        assert(not view.parts[#view.parts].spark:IsShown())
    ''')


@pytest.mark.parametrize("failure", ["texture", "fill", "anchor"])
def test_optional_spark_failure_does_not_hide_cast_or_health(runtime, failure):
    runtime.globals().spark_failure = failure
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current()); local e=NS.Catalog.Create("cast","spark")
        e.castStyle=NS.Features.CastDefaults(); e.castStyle.spark=true; layout.elements[#layout.elements+1]=e
        local view=NS.Renderer.Create(UIParent); assert(NS.Renderer.Apply(view,layout)); local part
        for _,p in ipairs(view.parts) do if p.kind=="cast" then
            if spark_failure=="texture" then p.spark.SetTexture=function() return Mock.Secret() end
            elseif spark_failure=="fill" then p.bar.GetStatusBarTexture=function() return Mock.Secret() end
            else p.spark.SetPoint=function() error("Anchor unavailable") end end
        end end
        assert(NS.Renderer.Apply(view,layout)); assert(NS.Renderer.Update(view,{casting=true}))
        part=view.parts[#view.parts]; assert(part.frame:IsShown() and not part.spark:IsShown() and view.healthReady)
    ''')


@pytest.mark.parametrize("extension", ["00", "zz", "", "09", "09" + "31" + "09", "09" + "00" + "09"])
def test_fn3_rejects_malformed_extension_fields_without_saving(runtime, extension):
    runtime.globals().bad_extension = extension
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current()); assert(s:Add("auras")); local code=NS.Share.Export(s.layout)
        local d=LibStub("LibDeflate"); local raw={}
        for block in code:sub(5):gmatch("[^.]+") do raw[#raw+1]=d:DecompressDeflate(d:DecodeForPrint(block)) end
        local text=table.concat(raw):gsub(";[^;]*$",";"..bad_extension)
        local blocks={}; for i=1,#text,160 do blocks[#blocks+1]=d:EncodeForPrint(d:CompressDeflate(text:sub(i,i+159))) end
        local before=NS.Share.Export(NS.DB.Current())
        assert(not NS.Share.Import("FN3:"..table.concat(blocks,".")))
        assert(NS.Share.Export(NS.DB.Current())==before)
    ''')


def test_search_indexes_existing_reaction_colors_and_handles_capital_umlauts(runtime):
    runtime.execute('''
        local s=NS.Studio; s.Open(); assert(#NS.Settings.Find("GRÖSSE")>=1)
        local entry=NS.Settings.Find("Feindliche Healthfarbe")[1]; assert(entry and NS.Settings.Open(entry))
        assert(s.page=="rules" and s.ruleUI.hostileColor.searchMark:IsShown())
        assert(NS.Settings.Open(NS.Settings.Find("Feste Regelfarbe")[1]) and s.ruleUI.fixedColor.searchMark:IsShown())
    ''')


def test_lazy_tooltip_binding_failure_rolls_back_page_and_can_retry(runtime):
    runtime.execute('''
        local s=NS.Studio; s.Open(); local bind=NS.Settings.Bind
        NS.Settings.Bind=function() error("Tooltip binding unavailable") end
        assert(not s.ShowPage("components") and not s.built.components and s.componentUI==nil and s.page=="studio")
        NS.Settings.Bind=bind; assert(s.ShowPage("components") and s.componentUI and s.built.components)
    ''')


def test_cast_bound_aura_row_preserves_visibility_across_partial_aura_events(runtime):
    runtime.execute('''
        local layout=NS.Copy(NS.DB.Current()); local e=NS.Catalog.Create("auras","row"); e.source="cast"
        layout.elements[#layout.elements+1]=e
        C_UnitAuras={GetUnitAuras=function() return {{icon=135846}} end}
        local casting=false
        UnitCastingDuration=function() if casting then return {} end end
        UnitChannelDuration=function() return nil end
        UnitCastingInfo=function() if casting then return "Bolt" end end
        UnitChannelInfo=function() return nil end
        assert(NS.DB.Save(layout)); Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; local row=view.parts[#view.parts]
        Mock.Fire(NS.events,"UNIT_AURA","nameplate1"); assert(not row.frame:IsShown())
        casting=true; Mock.Fire(NS.events,"UNIT_SPELLCAST_START","nameplate1")
        assert(row.frame:IsShown())
        Mock.Fire(NS.events,"UNIT_AURA","nameplate1"); assert(row.frame:IsShown())
        casting=false; Mock.Fire(NS.events,"UNIT_SPELLCAST_STOP","nameplate1")
        Mock.Fire(NS.events,"UNIT_AURA","nameplate1"); assert(not row.frame:IsShown() and view.replaced)
    ''')


@pytest.mark.parametrize("corruption", ["bool", "number", "extra", "missing"])
def test_fn3_rejects_corrupt_aura_values_in_otherwise_valid_extension(runtime, corruption):
    runtime.globals().extension_corruption = corruption
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current()); assert(s:Add("auras")); local code=NS.Share.Export(s.layout)
        local d=LibStub("LibDeflate"); local raw={}
        for block in code:sub(5):gmatch("[^.]+") do raw[#raw+1]=d:DecompressDeflate(d:DecodeForPrint(block)) end
        local text=table.concat(raw); local encoded=text:match(";([^;]*)$")
        local decoded=encoded:gsub("..",function(pair) return string.char(tonumber(pair,16)) end)
        if extension_corruption=="bool" then decoded=decoded:gsub(",0,1,",",2,1,")
        elseif extension_corruption=="number" then decoded=decoded:gsub(",8.000000,",",nan,",1)
        elseif extension_corruption=="extra" then decoded=decoded:gsub("\\t$",",0\\t")
        else decoded=decoded:gsub(",8.000000,",",",1) end
        local changed=decoded:gsub(".",function(c) return string.format("%02x",string.byte(c)) end)
        text=text:sub(1,#text-#encoded)..changed
        local blocks={}; for i=1,#text,160 do blocks[#blocks+1]=d:EncodeForPrint(d:CompressDeflate(text:sub(i,i+159))) end
        assert(not NS.Share.Import("FN3:"..table.concat(blocks,".")))
    ''')


def test_search_keeps_matching_selection_and_opens_visible_shape_control(runtime):
    runtime.execute('''
        local s=NS.Studio; s.Open(); assert(s.session:Add("auras")); assert(s.session:Add("auras"))
        local selected=s.session.selected
        assert(NS.Settings.Open(NS.Settings.Find("Aura Spalten")[1]) and s.session.selected==selected)
        s.Select("health"); assert(NS.Settings.Open(NS.Settings.Find("Form")[1]))
        assert(s.session:Element().kind=="panel" and s.inspector.shape:IsShown() and s.inspector.shape:IsEnabled())
        s.Select("back"); assert(NS.Settings.Open(NS.Settings.Find("Schriftgröße")[1]))
        assert(s.session:Element().kind=="text" and s.inspector.fields.fontSize:IsEnabled())
    ''')
