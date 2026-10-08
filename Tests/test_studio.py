import pytest

@pytest.mark.parametrize("kind", ["health", "cast", "text", "panel", "target", "ornament"])
def test_add_component_select_and_undo(runtime, kind):
    runtime.globals().component_kind = kind
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        local count=#s.layout.elements
        assert(s:Add(component_kind)); assert(#s.layout.elements==count+1)
        assert(s:Element().kind==component_kind and NS.Model.Validate(NS.DB.Current()))
        assert(s:Undo()); assert(#s.layout.elements==count)
        assert(s:Redo()); assert(#s.layout.elements==count+1)
    ''')

def test_artwork_requires_import_and_tint_applies(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        assert(not s:Add("artwork"))
        NS.Media.files.classic_frame="classic_frame.tga"
        assert(s:Add("artwork")); assert(s:Element().asset=="classic_frame")
        assert(s:Update(s.selected,{color={.2,.3,.4,.5}}))
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,s.layout)
        local p=view.parts[#view.parts]; assert(p.image.vertexColor[1]==.2 and p.image.vertexColor[4]==.5)
    ''')

def test_component_limits_invalid_kind_and_combat_are_atomic(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        assert(not s:Add(nil)); assert(not s:Add("script"))
        Mock.combat=true; local count=#s.layout.elements; assert(not s:Add("text")); assert(#s.layout.elements==count)
        Mock.combat=false
        while #s.layout.elements<64 do assert(s:Add("text")) end
        assert(not s:Add("text")); assert(#s.layout.elements==64)
    ''')

def test_resize_snap_keeps_top_left_and_lock(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        local e=s:Element("health"); local left,top=e.x-e.width/2,e.y+e.height/2
        assert(s:Resize("health",197,23,true)); e=s:Element("health")
        assert(e.width==196 and e.height==24)
        assert(e.x-e.width/2==left and e.y+e.height/2==top)
        assert(s:Undo()); assert(s:Element("health").width==180)
        assert(s:Update("health",{locked=true})); assert(not s:Resize("health",200,20))
        assert(s:Update("health",{locked=false})); assert(not s:Resize("health",999,20))
    ''')

@pytest.mark.parametrize("mode", ["left", "right", "top", "bottom", "centerX", "centerY"])
def test_alignment_exact_even_with_snap(runtime, mode):
    runtime.globals().align_mode = mode
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        assert(s:Update("health",{x=13,y=17,width=179,height=13}))
        assert(s:Align("back",align_mode,"health"))
        local a,b=s:Element("back"),s:Element("health")
        if align_mode=="left" then assert(a.x-a.width/2==b.x-b.width/2)
        elseif align_mode=="right" then assert(a.x+a.width/2==b.x+b.width/2)
        elseif align_mode=="top" then assert(a.y+a.height/2==b.y+b.height/2)
        elseif align_mode=="bottom" then assert(a.y-a.height/2==b.y-b.height/2)
        elseif align_mode=="centerX" then assert(a.x==13)
        elseif align_mode=="centerY" then assert(a.y==17) end
        assert(s:Align("back","centerX")); assert(s:Element("back").x==0)
        assert(not s:Align("back","invalid")); assert(not s:Align("back","left","missing"))
    ''')

def test_custom_reset_and_last_element_protection(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        assert(s:Add("text")); local id=s.selected
        assert(s:Update(id,{width=280,text="Changed"})); assert(s:ResetElement())
        assert(s:Element().width==160 and s:Element().text=="Custom text")
        assert(s:Update(id,{locked=true})); assert(not s:ResetElement())
        local single={version=1,name="Solo",elements={NS.Copy(s.layout.elements[1])}}
        local solo=NS.Session.New(single); assert(not solo:Delete())
    ''')

def test_profile_delete_rebinds_all_characters_and_keeps_default(runtime):
    runtime.execute('''
        assert(NS.DB.Create("Shared"))
        NS.DB.data.characters.A="Shared"; NS.DB.data.characters.B="Shared"
        assert(NS.DB.Delete("Shared")); assert(NS.DB.CurrentName()=="Default")
        assert(NS.DB.data.characters.A=="Default" and NS.DB.data.characters.B=="Default")
        assert(not NS.DB.Delete("Default")); assert(not NS.DB.Delete("missing"))
    ''')

def test_profile_mutations_blocked_during_combat_and_future_schema(runtime):
    runtime.execute('''
        assert(NS.DB.Create("Arena"))
        Mock.combat=true
        assert(not NS.DB.Create("New")); assert(not NS.DB.Select("Default"))
        assert(not NS.DB.Rename("Renamed")); assert(not NS.DB.Delete("Arena"))
        assert(not NS.DB.SetCharacter(true)); assert(not NS.DB.Save(NS.Presets[2].layout))
        assert(NS.DB.CurrentName()=="Arena")
        Mock.combat=false; assert(not NS.DB.Initialize({version=10}))
        assert(not NS.DB.Create("New")); assert(not NS.DB.Select("Default")); assert(not NS.DB.Delete("Arena"))
    ''')

def test_saved_profile_limit_reserves_default(runtime):
    runtime.execute('''
        local saved={version=1,profiles={},characters={}}
        for i=1,40 do saved.profiles["Profile"..i]=NS.Copy(NS.Presets[1].layout) end
        local data=NS.DB.Initialize(saved); local count=0
        for _ in pairs(data.profiles) do count=count+1 end
        assert(count==32 and data.profiles.Default and data.active=="Default")
    ''')

def test_theme_updates_labels_editboxes_but_keeps_custom_art_colors(runtime):
    runtime.execute('''
        NS.Studio.Open(); NS.Studio.ShowPage("studio")
        local i=NS.Studio.inspector
        NS.W.Skin("Light Fantasy")
        assert(i.title.textColor[1]==.15 and i.fields.x.textColor[1]==.15)
        NS.W.Skin("Modern Studio")
        assert(i.title.textColor[1]==.87 and i.fields.x.textColor[1]==.87)
        assert(NS.Studio.view.parts[2].bar.statusColor[1]==NS.DB.Current().elements[2].color[1])
    ''')

def test_menu_pagination_disabled_choices_and_rejected_dropdown(runtime):
    runtime.execute('''
        NS.Studio.Open()
        local options={}; for i=1,12 do options[i]={value=i,label="Item "..i} end
        options[1].disabled=true
        local selected
        NS.W.Menu(NS.Studio.addButton,options,function(value) selected=value end)
        local menu=NS.W.menu; menu.items[1].scripts.OnClick(); assert(not selected)
        menu.next.scripts.OnClick(); assert(menu.page==2)
        menu.items[4].scripts.OnClick(); assert(selected==12 and not NS.W.menuOverlay:IsShown())
        local b=NS.W.Dropdown(UIParent,0,0,220,options,function() return false end)
        b:SetValue(2); b.scripts.OnClick(); NS.W.menu.items[3].scripts.OnClick()
        assert(b.value==2)
    ''')

def test_gui_add_resize_zoom_cancel_and_grid(runtime):
    runtime.execute('''
        NS.Studio.Open(); NS.Studio.ShowPage("studio")
        local s=NS.Studio
        s.addButton.scripts.OnClick(); NS.W.menu.items[3].scripts.OnClick()
        assert(s.session:Element().kind=="text" and s.elementPicker.value==s.session.selected)
        s.Select("health"); s.zoom=2; s.Refresh()
        Mock.cursorX=0; Mock.cursorY=0
        s.resizeHandle.scripts.OnDragStart(s.resizeHandle)
        Mock.cursorX=32; Mock.cursorY=-16; s.canvas.scripts.OnUpdate(); s.resizeHandle.scripts.OnDragStop()
        local e=s.session:Element("health")
        assert(e.width==196 and e.height==24 and e.x==8 and e.y==-5)
        local before=e.width
        s.resizeHandle.scripts.OnDragStart(s.resizeHandle); Mock.cursorX=64
        s.canvas.scripts.OnUpdate(); s.EndDrag(false); assert(s.session:Element("health").width==before)
        assert(s.grid[1]:IsShown())
        s.gridButton.scripts.OnClick(); for _,line in ipairs(s.grid) do assert(not line:IsShown()) end
        assert(s.gridButton.label.text=="Grid: off")
    ''')

def test_sandbox_four_states_and_reuses_widgets(runtime):
    runtime.execute('''
        NS.Studio.Open(); NS.Studio.ShowPage("sandbox")
        local s=NS.Studio; assert(#s.sandboxViews==4)
        local count=#Mock.frames
        s.sandboxViews[1].scenario=6; s.RefreshSandbox()
        for _,p in ipairs(s.sandboxViews[1].view.parts) do if p.kind=="health" then assert(p.bar.value==12) end end
        assert(#Mock.frames==count)
        assert(s.session:Add("text")); s.Refresh()
        for _,tile in ipairs(s.sandboxViews) do assert(#tile.view.parts==#s.session.layout.elements) end
    ''')

def test_confirm_delete_reset_cancel_and_combat_close(runtime):
    runtime.execute('''
        NS.Studio.Open(); assert(NS.DB.Create("Disposable")); NS.Studio.LoadSession(); NS.Studio.ShowPage("profiles")
        NS.Studio.deleteProfile.scripts.OnClick(); assert(NS.W.confirmOverlay:IsShown())
        NS.W.ClosePopups(); assert(NS.DB.data.profiles.Disposable)
        NS.Studio.deleteProfile.scripts.OnClick(); NS.W.confirmAccept.scripts.OnClick()
        assert(not NS.DB.data.profiles.Disposable and NS.DB.CurrentName()=="Default")
        NS.Studio.resetPreset=4; NS.Studio.resetProfile.scripts.OnClick(); NS.W.confirmAccept.scripts.OnClick()
        assert(NS.DB.Current().name=="Galactic Interface")
        NS.W.Confirm(NS.Studio.root,"Should not run",function() error("Combat action executed") end)
        Mock.combat=true; Mock.Fire(NS.events,"PLAYER_REGEN_DISABLED")
        assert(not NS.W.confirmOverlay:IsShown() and not NS.W.confirmAction)
    ''')

def test_gallery_change_can_be_undone_and_clears_missing_selection(runtime):
    runtime.execute('''
        NS.Studio.Open(); NS.Studio.ShowPage("studio")
        local s=NS.Studio
        assert(s.session:Add("text")); assert(s.session.selected=="text1")
        s.ShowPage("gallery"); s.galleryCards[4].scripts.OnClick()
        assert(NS.DB.Current().name=="Galactic Interface")
        assert(s.session:Element() and s.session.selected~="text1")
        assert(s.session:Undo()); s.Refresh()
        assert(NS.DB.Current().name=="Classic Azeroth" and s.session:Element("text1"))
    ''')

def test_paste_clamps_coordinates_at_layout_boundary(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        s.selected="health"; assert(s:Update("health",{x=512,y=-512})); assert(s:Copy())
        assert(s:Paste()); assert(s:Element().x==512 and s:Element().y==-512)
    ''')


def test_use_frame_artwork_removes_preset_ornaments_preserves_custom_and_undo(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        assert(not s:UseFrameArtwork() and #s.undo==0)
        NS.Media.files.classic_frame="classic_frame.tga"
        assert(s:Add("ornament")); local custom=s.selected
        assert(s:Update("artFrame",{enabled=false,color={.2,.3,.4,.5},width=300}))
        assert(s:UseFrameArtwork())
        assert(s:Element("artFrame").enabled and s:Element("artFrame").color[1]==1)
        assert(s:Element("artFrame").width==256)
        assert(not s:Element("leftWing").enabled and not s:Element("rightWing").enabled)
        assert(s:Element(custom).enabled and s:Element("health").enabled and s:Element("name").enabled)
        assert(NS.DB.Current().elements[8].enabled==false)
        assert(s:Undo()); assert(s:Element("leftWing").enabled and not s:Element("artFrame").enabled)
        assert(s:Redo()); assert(not s:Element("leftWing").enabled)
        assert(NS.Share.Import(NS.Share.Export(s.layout)).elements[8].enabled==false)
    ''')


def test_frame_artwork_respects_locks_and_combat_atomically(runtime):
    runtime.execute('''
        local s=NS.Session.New(NS.DB.Current(),NS.DB.Save)
        NS.Media.files.classic_frame="classic_frame.tga"
        assert(s:Update("leftWing",{locked=true}))
        local count=#s.undo
        assert(not s:UseFrameArtwork() and s:Element("leftWing").enabled and #s.undo==count)
        assert(s:Update("leftWing",{locked=false})); assert(s:Update("artFrame",{locked=true}))
        assert(not s:UseFrameArtwork() and s:Element("leftWing").enabled)
        assert(s:Update("artFrame",{locked=false}))
        Mock.combat=true; count=#s.undo
        assert(not s:UseFrameArtwork() and s:Element("leftWing").enabled and #s.undo==count)
    ''')


def test_artwork_catalog_respects_native_asset_dimensions(runtime):
    runtime.execute('''
        NS.Media.files.arena_frame="arena_frame.tga"
        local item=assert(NS.Catalog.Create("artwork","arena"))
        assert(item.width==256 and item.height==128)
        NS.Media.files.arena_frame=nil; NS.Media.files.studio_header="studio_header.tga"
        item=assert(NS.Catalog.Create("artwork","header"))
        assert(item.width==512 and item.height==64)
    ''')


def test_frame_artwork_button_requires_import_and_applies_operation(runtime):
    runtime.execute('''
        NS.Studio.Open(); NS.Studio.ShowPage("studio")
        assert(not NS.Studio.useFrameArt:IsEnabled())
        NS.Studio.useFrameArt.scripts.OnClick(); assert(#NS.Studio.session.undo==0)
        NS.Media.files.classic_frame="classic_frame.tga"; NS.Studio.Refresh()
        assert(NS.Studio.useFrameArt:IsEnabled())
        NS.Studio.useFrameArt.scripts.OnClick()
        assert(not NS.Studio.session:Element("leftWing").enabled)
        assert(NS.Studio.session:Element("artFrame").enabled)
    ''')
