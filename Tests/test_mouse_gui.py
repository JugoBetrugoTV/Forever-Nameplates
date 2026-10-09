import pytest


@pytest.mark.parametrize("key,step", [("x", 1), ("y", 1), ("width", 1), ("height", 1),
                                      ("layer", 1), ("fontSize", 1), ("alpha", .01)])
def test_inspector_numbers_mouse_buttons_wheel_bounds_and_undo(runtime, key, step):
    runtime.globals().number_key = key
    runtime.globals().number_step = step
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; s.Select("name")
        local field=s.inspector.fields[number_key]; local original=s.session:Element()[number_key]
        local count=#s.session.undo
        field.minus.scripts.OnClick()
        assert(math.abs(s.session:Element()[number_key]-(original-number_step))<.00001)
        assert(#s.session.undo==count+1 and NS.DB.Current().elements[3][number_key]==s.session:Element()[number_key])
        field.plus.scripts.OnClick(); assert(math.abs(s.session:Element()[number_key]-original)<.00001)
        field.scripts.OnMouseWheel(field,-1)
        assert(math.abs(s.session:Element()[number_key]-(original-number_step))<.00001)
        assert(s.session:Undo()); s.Refresh(); assert(s.session:Element()[number_key]==original)
        field:SetText(tostring(field.slider.max)); field.scripts.OnEnterPressed(field)
        count=#s.session.undo; field.plus.scripts.OnClick()
        assert(s.session:Element()[number_key]==field.slider.max and #s.session.undo==count)
        field:SetText(tostring(field.slider.min)); field.scripts.OnEnterPressed(field)
        count=#s.session.undo; field.minus.scripts.OnClick()
        assert(s.session:Element()[number_key]==field.slider.min and #s.session.undo==count)
    ''')


def test_slider_previews_without_saving_then_releases_as_one_change(runtime):
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; s.Select("health")
        local f=s.inspector.fields.width; local original=s.session:Element().width
        local count=#s.session.undo; local widgets=#Mock.frames
        f.slider.scripts.OnMouseDown(f.slider,"LeftButton")
        for value=200,240 do f.slider:SetValue(value,true) end
        assert(s.view.parts[2].element.width==240 and tonumber(f:GetText())==240)
        assert(s.session:Element().width==original and NS.DB.Current().elements[2].width==original)
        assert(#s.session.undo==count and #Mock.frames==widgets)
        f.slider.scripts.OnMouseUp(f.slider,"LeftButton")
        assert(s.session:Element().width==240 and NS.DB.Current().elements[2].width==240)
        assert(#s.session.undo==count+1 and not f.dragging)
        assert(s.session:Undo()); s.Refresh(); assert(s.view.parts[2].element.width==original)
        assert(s.session:Redo()); s.Refresh(); assert(s.view.parts[2].element.width==240)
        count=#s.session.undo; s.RefreshInspector(); assert(#s.session.undo==count)
    ''')


@pytest.mark.parametrize("action", ["page", "selection", "hide", "combat"])
def test_unfinished_numeric_drag_cancels_on_context_change(runtime, action):
    runtime.globals().cancel_action = action
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; s.Select("health")
        local f=s.inspector.fields.width; local original=s.session:Element().width; local count=#s.session.undo
        f.slider.scripts.OnMouseDown(f.slider,"LeftButton"); f.slider:SetValue(260,true)
        if cancel_action=="page" then s.ShowPage("rules")
        elseif cancel_action=="selection" then s.Select("name")
        elseif cancel_action=="hide" then s.root:Hide()
        else Mock.combat=true; Mock.Fire(NS.events,"PLAYER_REGEN_DISABLED") end
        f.slider.scripts.OnMouseUp(f.slider,"LeftButton")
        assert(not f.dragging and #s.session.undo==count)
        assert(s.session:Element("health").width==original and NS.DB.Current().elements[2].width==original)
        assert(s.view.parts[2].element.width==original)
    ''')


def test_numeric_and_custom_text_commit_on_blur_once_escape_and_invalid_revert(runtime):
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; s.Select("name")
        local f=s.inspector.fields.x; local count=#s.session.undo
        f:SetFocus(); f:SetText("37.5"); f:ClearFocus()
        assert(s.session:Element().x==37.5 and #s.session.undo==count+1)
        count=#s.session.undo
        f:SetFocus(); f:SetText("42"); f.scripts.OnEnterPressed(f)
        assert(s.session:Element().x==42 and #s.session.undo==count+1)
        count=#s.session.undo
        f:SetFocus(); f:SetText("73"); f.scripts.OnEscapePressed(f)
        assert(s.session:Element().x==42 and tonumber(f:GetText())==42 and #s.session.undo==count)
        f:SetFocus(); f:SetText("9999"); f:ClearFocus()
        assert(s.session:Element().x==42 and tonumber(f:GetText())==42 and #s.session.undo==count)
        local text=s.inspector.text; text:SetFocus(); text:SetText("My label"); text:ClearFocus()
        assert(s.session:Element().text=="My label" and NS.DB.Current().elements[3].text=="My label")
    ''')


def test_locked_and_irrelevant_numeric_controls_cannot_mutate_layout(runtime):
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; s.Select("health")
        local f=s.inspector.fields.fontSize; local old=s.session:Element().fontSize
        assert(not f:IsEnabled() and not f.slider:IsEnabled() and not f.plus:IsEnabled())
        f.plus.scripts.OnClick(); f.scripts.OnMouseWheel(f,1); assert(s.session:Element().fontSize==old)
        s.inspector.locked.scripts.OnClick(); f=s.inspector.fields.width
        assert(not f:IsEnabled() and not f.minus:IsEnabled())
        assert(not s.inspector.color:IsEnabled() and not s.inspector.delete:IsEnabled() and not s.inspector.reset:IsEnabled())
        local width=s.session:Element().width; local count=#s.session.undo
        f.plus.scripts.OnClick(); f.slider.scripts.OnMouseDown(f.slider,"LeftButton"); f.slider:SetValue(200,true)
        assert(s.session:Element().width==width and #s.session.undo==count and not f.dragging)
        s.inspector.locked.scripts.OnClick(); assert(f:IsEnabled() and f.slider:IsEnabled())
        Mock.combat=true; f.plus.scripts.OnClick(); f.scripts.OnMouseWheel(f,1)
        assert(s.session:Element().width==width and #s.session.undo==count+1)
    ''')


def test_rules_numbers_mouse_preview_save_and_category_cancel(runtime):
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; s.ShowPage("rules"); local ui=s.ruleUI
        ui.enabled.scripts.OnClick(); ui.alpha.minus.scripts.OnClick(); ui.scale.plus.scripts.OnClick()
        local rule=NS.DB.Current().rules.overrides.enemyPlayers
        assert(math.abs(rule.alpha-.99)<.00001 and math.abs(rule.scale-1.01)<.00001)
        local count=#s.session.undo
        ui.scale.slider.scripts.OnMouseDown(ui.scale.slider,"LeftButton"); ui.scale.slider:SetValue(1.75,true)
        assert(ui.view.root.scale==.65*1.75 and #s.session.undo==count and rule.scale~=1.75)
        ui.scale.slider.scripts.OnMouseUp(ui.scale.slider,"LeftButton")
        assert(NS.DB.Current().rules.overrides.enemyPlayers.scale==1.75 and #s.session.undo==count+1)
        ui.scale.slider.scripts.OnMouseDown(ui.scale.slider,"LeftButton"); ui.scale.slider:SetValue(1.9,true)
        ui.categoryPicker.scripts.OnClick(); NS.W.menu.items[1].scripts.OnClick()
        ui.scale.slider.scripts.OnMouseUp(ui.scale.slider,"LeftButton")
        assert(NS.DB.Current().rules.overrides.enemyPlayers.scale==1.75 and not ui.scale.dragging)
    ''')


def test_overlapping_canvas_selection_respects_scale_and_stale_handle(runtime):
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; s.zoom=2; s.Refresh()
        s.view.root.centerX=100; s.view.root.centerY=200
        Mock.cursorX=100*s.view.root:GetEffectiveScale(); Mock.cursorY=200*s.view.root:GetEffectiveScale()
        local h=s.handles[2]; h.scripts.OnClick(h,"RightButton")
        assert(NS.W.menuOverlay:IsShown())
        local found
        for _,item in ipairs(NS.W.menu.items) do
            if item:IsShown() and item.label:GetText():find("back [panel]",1,true) then item.scripts.OnClick(); found=true; break end
        end
        assert(found and s.session.selected=="back")
        assert(s.session:Update("back",{locked=true})); s.Refresh()
        h.scripts.OnClick(h,"RightButton"); assert(NS.W.menuOverlay:IsShown())
        NS.W.ClosePopups(); Mock.combat=true; h.scripts.OnClick(h,"RightButton"); assert(not NS.W.menuOverlay:IsShown())
        Mock.combat=false; h.element=nil; h.scripts.OnClick(h,"LeftButton")
        assert(s.session.selected=="back")
    ''')


def test_font_style_and_target_text_are_available_by_click_and_shareable(runtime):
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; s.Select("name")
        local assets=s.inspector.asset; assert(assets:IsShown() and not s.inspector.shape:IsShown())
        assets.scripts.OnClick(); local found
        for _,item in ipairs(NS.W.menu.items) do
            if item:IsShown() and item.label:GetText()=="FFXIV: name / fallback font" then item.scripts.OnClick(); found=true; break end
        end
        assert(found and s.session:Element().asset=="ffxiv_name_label")
        assert(s.view.parts[3].text.font[1]=="Fonts\\\\ARIALN.TTF")
        assert(NS.Share.Import(NS.Share.Export(s.session.layout)).elements[3].asset=="ffxiv_name_label")
        assets.scripts.OnClick(); NS.W.menu.items[1].scripts.OnClick()
        assert(s.session:Element().asset=="" and s.view.parts[3].text.font[3]=="OUTLINE")
        s.inspector.source.scripts.OnClick(); NS.W.menu.items[8].scripts.OnClick()
        assert(s.session:Element().source=="target" and not s.view.parts[3].frame:IsShown())
        s.scenario=8; s.Refresh(); assert(s.view.parts[3].frame:IsShown())
    ''')


def test_minimap_settings_and_create_copy_are_available_by_click(runtime):
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; s.ShowPage("diagnostics")
        s.minimapVisible.scripts.OnClick(); assert(NS.DB.data.minimap.hidden and not NS.Minimap.button:IsShown())
        s.minimapVisible.scripts.OnClick(); assert(not NS.DB.data.minimap.hidden and NS.Minimap.button:IsShown())
        local f=s.minimapAngle; f.slider.scripts.OnMouseDown(f.slider,"LeftButton")
        f.slider:SetValue(90,true); f.slider.scripts.OnMouseUp(f.slider,"LeftButton")
        assert(NS.DB.data.minimap.angle==90)
        local saved=NS.Copy(NS.DB.data); NS.DB.Initialize(saved); assert(NS.DB.data.minimap.angle==90)
        s.ShowPage("profiles"); s.profileName:SetFocus(); s.profileName:SetText("Mouse copy"); s.profileName:ClearFocus()
        assert(not NS.DB.data.profiles["Mouse copy"])
        s.createProfile.scripts.OnClick(); assert(NS.DB.CurrentName()=="Mouse copy")
    ''')


def test_failed_construction_does_not_retain_numeric_callbacks(runtime):
    runtime.execute('''
        local s=NS.Studio; local build=s.CreateDiagnostics; local count=#NS.W.numbers
        s.CreateDiagnostics=function(page) build(page); error("failed build") end
        s.Open(); assert(s.ready and #NS.W.numbers==count+7)
        assert(not s.ShowPage("diagnostics") and #NS.W.numbers==count+7)
        s.CreateDiagnostics=build; assert(s.ShowPage("diagnostics") and #NS.W.numbers==count+8)
    ''')


@pytest.mark.parametrize("kind", ["panel", "ornament", "health", "cast", "raid", "class"])
def test_component_visibility_conditions_available_in_gui(runtime, kind):
    runtime.globals().conditional_kind = kind
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio
        assert(s.session:Add(conditional_kind)); s.Refresh()
        assert(s.inspector.source:IsEnabled())
        s.inspector.source.scripts.OnClick(); NS.W.menu.items[2].scripts.OnClick()
        assert(s.session:Element().source=="target")
        local index=#s.view.parts; assert(not s.view.parts[index].frame:IsShown())
        s.scenario=8; s.Refresh()
        if conditional_kind=="panel" or conditional_kind=="ornament" or conditional_kind=="health" then assert(s.view.parts[index].frame:IsShown()) end
        assert(s.session:Undo()); s.Refresh(); assert(s.session:Element().source~="target")
    ''')


def test_gui_skin_persists_without_changing_layout_or_share_schema(runtime):
    runtime.execute('''
        NS.Studio.Open(); NS.W.Skin("Modern Studio")
        assert(NS.DB.data.guiSkin=="Modern Studio")
        local saved=NS.Copy(NS.DB.data); NS.W.Skin("Dark RPG"); NS.DB.Initialize(saved)
        NS.Studio.Open(); assert(NS.W.skin=="Modern Studio")
        assert(NS.Share.Import(NS.Share.Export(NS.DB.Current())).version==2)
        for _,invalid in ipairs({"Unknown skin",{},23}) do
            saved.guiSkin=invalid; NS.DB.Initialize(saved); assert(NS.DB.data.guiSkin=="Dark RPG")
        end
    ''')


def test_clicking_next_selection_commits_pending_field_to_previous_element(runtime):
    runtime.execute('''
        NS.Studio.Open(); local s=NS.Studio; s.Select("name")
        local field=s.inspector.fields.x; local old=s.session:Element("health").x
        field:SetFocus(); field:SetText("29")
        local handle=s.handles[2]; handle.scripts.OnClick(handle,"LeftButton")
        assert(s.session.selected=="health" and s.session:Element("name").x==29)
        assert(s.session:Element("health").x==old and not field.focus and not NS.W.focusedEdit)
        field:SetFocus(); field:SetText("33"); s.inspector.locked.scripts.OnClick()
        assert(s.session:Element().x==33 and s.session:Element().locked and not field.focus)
        s.inspector.locked.scripts.OnClick(); field:SetFocus(); field:SetText("45")
        Mock.combat=true; Mock.Fire(NS.events,"PLAYER_REGEN_DISABLED")
        assert(s.session:Element().x==33 and not field.focus and not NS.W.focusedEdit)
    ''')
