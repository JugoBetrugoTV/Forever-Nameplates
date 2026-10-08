import pytest


def test_strict_font_signature_and_complete_editor(runtime):
    runtime.execute('''
        local bad=CreateFrame("EditBox",nil,UIParent)
        assert(not pcall(bad.SetFont,bad,STANDARD_TEXT_FONT,11))
        SlashCmdList.FOREVERNAMEPLATES("")
        local s=NS.Studio
        assert(s.ready and s.root:IsShown() and s.inspector.visible and s.inspector.text)
        assert(s.inspector.fields.x.font[3]=="" and s.shareBox.font[3]=="")
        s.ShowPage("gallery"); s.galleryCards[2].scripts.OnClick(s.galleryCards[2])
        assert(s.page=="studio" and s.inspector.visible.value==s.session:Element().enabled)
        assert(ForeverNameplatesStudio==s.root and #UISpecialFrames==1)
    ''')


@pytest.mark.parametrize("page", ["CreateEditor", "CreateProfiles", "CreateDiagnostics"])
def test_failed_editor_is_discarded_and_can_retry(runtime, page):
    runtime.globals().failed_page=page
    runtime.execute('''
        local s=NS.Studio; local build=s[failed_page]; local failed
        local fonts,surfaces=#NS.W.fonts,#NS.W.surfaces
        s[failed_page]=function(page)
            failed=s.root; build(page)
            error("simulated construction failure")
        end
        s.Open()
        assert(not s.ready and not s.root and not failed:IsShown())
        assert(#NS.W.fonts==fonts and #NS.W.surfaces==surfaces and #UISpecialFrames==0)
        s.RefreshInspector(); s.Refresh(); s.ShowPage("studio")
        s[failed_page]=build; s.Open()
        assert(s.ready and s.inspector.visible and s.root:IsShown() and s.root~=failed)
        assert(#s.sandboxViews==4)
        assert(#UISpecialFrames==1)
        s.root:Hide(); s.Open(); assert(#UISpecialFrames==1)
    ''')


def test_minimap_clicks_tooltip_and_visibility(runtime):
    runtime.execute('''
        local m=NS.Minimap; local b=m.button
        assert(b and b.parent==UIParent and b:IsShown())
        assert(b.clickButtons[1]=="LeftButtonUp" and b.clickButtons[2]=="RightButtonUp")
        assert(not b.scripts.OnUpdate)
        b.scripts.OnClick(b,"LeftButton"); assert(NS.Studio.root:IsShown())
        b.scripts.OnClick(b,"LeftButton"); assert(not NS.Studio.root:IsShown())
        b.scripts.OnClick(b,"RightButton"); assert(NS.Studio.root:IsShown() and NS.Studio.page=="diagnostics")
        GameTooltip=CreateFrame("Frame",nil,UIParent)
        function GameTooltip:SetOwner(owner,anchor) self.owner=owner end
        function GameTooltip:AddLine(text) self.lines=(self.lines or 0)+1 end
        b.scripts.OnEnter(b); assert(GameTooltip.text==NS.name and GameTooltip.lines==3 and GameTooltip:IsShown())
        b.scripts.OnLeave(b); assert(not GameTooltip:IsShown())
        SlashCmdList.FOREVERNAMEPLATES("minimap"); assert(not b:IsShown() and NS.DB.data.minimap.hidden)
        SlashCmdList.FOREVERNAMEPLATES("minimap"); assert(b:IsShown() and not NS.DB.data.minimap.hidden)
        local count=#Mock.frames; m.Init(); assert(#Mock.frames==count)
    ''')


@pytest.mark.parametrize("x,y,angle", [(100, 0, 0), (0, 100, 90), (-100, 0, 180), (0, -100, 270), (-100, -100, 225)])
def test_minimap_drag_scale_and_persistence(runtime, x, y, angle):
    runtime.globals().drag_x=x
    runtime.globals().drag_y=y
    runtime.globals().drag_angle=angle
    runtime.execute('''
        Minimap.centerX=300; Minimap.centerY=400; Minimap:SetScale(.75)
        Mock.cursorX=(300+drag_x)*.75; Mock.cursorY=(400+drag_y)*.75
        local m=NS.Minimap; local b=m.button
        b.scripts.OnDragStart(b)
        assert(m.dragging and b.scripts.OnUpdate and math.abs(NS.DB.data.minimap.angle-drag_angle)<.001)
        b.scripts.OnDragStop(b); assert(not m.dragging and not b.scripts.OnUpdate)
        local saved=NS.Copy(NS.DB.data); NS.DB.Initialize(saved)
        assert(math.abs(NS.DB.data.minimap.angle-drag_angle)<.001)
        GetMinimapShape=function() return "SQUARE" end; m.Position()
        local radius=78*Minimap:GetEffectiveScale()/b:GetEffectiveScale()
        assert(math.abs(math.max(math.abs(b.point[4]),math.abs(b.point[5]))-radius)<.001)
    ''')


def test_minimap_combat_stops_drag_and_blocks_changes(runtime):
    runtime.execute('''
        local m=NS.Minimap; local b=m.button
        Mock.cursorX=100; b.scripts.OnDragStart(b); assert(b.scripts.OnUpdate)
        local angle=NS.DB.data.minimap.angle
        Mock.combat=true; Mock.Fire(NS.events,"PLAYER_REGEN_DISABLED")
        assert(not m.dragging and not b.scripts.OnUpdate)
        b.scripts.OnClick(b,"LeftButton"); b.scripts.OnDragStart(b)
        SlashCmdList.FOREVERNAMEPLATES("minimap")
        assert(not NS.Studio.root and not b.scripts.OnUpdate and NS.DB.data.minimap.angle==angle and not NS.DB.data.minimap.hidden)
        Mock.combat=false; Mock.Fire(NS.events,"PLAYER_REGEN_ENABLED")
        b.scripts.OnClick(b,"LeftButton"); assert(NS.Studio.ready)
    ''')


def test_minimap_migration_invalid_settings_and_late_frame(runtime):
    runtime.execute('''
        for _,angle in ipairs({"bad",math.huge,-math.huge,0/0}) do
            local saved=NS.Copy(NS.DB.data); saved.minimap={angle=angle,hidden="true"}
            local data=NS.DB.Initialize(saved)
            assert(data.minimap.angle==225 and not data.minimap.hidden)
        end
        local saved=NS.Copy(NS.DB.data); saved.minimap={angle=-90,hidden=true}
        assert(NS.DB.Initialize(saved).minimap.angle==270 and NS.DB.data.minimap.hidden)
        local map=Minimap; Minimap=nil; NS.Minimap.button=nil
        NS.Minimap.Init(); assert(not NS.Minimap.button)
        Minimap=map; Mock.Fire(NS.events,"PLAYER_ENTERING_WORLD")
        assert(NS.Minimap.button and not NS.Minimap.button:IsShown())
    ''')
