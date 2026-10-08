"""Pinned source geometry is testable; original client texture pixels are not available here."""
import pytest


def test_only_nameplate_game_entries_and_source_geometry(runtime):
    runtime.execute('''
        assert(#NS.GameNameplates==7)
        for i,entry in ipairs(NS.GameNameplates) do
            if i<=2 then assert(entry.layout and NS.Model.Validate(entry.layout))
            elseif i==6 then assert(entry.layout and NS.Model.Validate(entry.layout) and not NS.Catalog.GameReady(entry))
            else assert(not entry.layout and entry.status=="reference_blocked") end
        end
        local c=NS.GameNameplates[1].layout
        assert(c.elements[2].width==103 and c.elements[2].height==10)
        assert(c.elements[2].asset=="wow_nameplate_fill")
        local f=c.elements[5]
        assert(f.width==128 and f.height==16 and f.x==8.5)
        assert(f.asset=="wow_classic_nameplate_border")
        assert(c.elements[3].fontSize==12 and c.elements[4].source=="level")
        local d=NS.GameNameplates[2].layout
        assert(d.elements[2].width==86 and d.elements[2].height==4)
        assert(d.elements[7].width==86 and d.elements[7].height==8 and d.elements[7].y==-8)
        for _,layout in ipairs({c,d}) do
            for _,e in ipairs(layout.elements) do assert(e.kind~="ornament", "Invented ornament in original nameplate") end
        end
    ''')


@pytest.mark.parametrize('index', [1, 2, 6])
def test_game_nameplate_share_preserves_native_resources(runtime, index):
    runtime.globals().gameIndex = index
    runtime.execute('''
        local original=NS.GameNameplates[gameIndex].layout
        local imported=assert(NS.Share.Import(NS.Share.Export(original)))
        assert(imported.name==original.name and #imported.elements==#original.elements)
        for i,e in ipairs(imported.elements) do
            assert(e.asset==original.elements[i].asset and e.shape==original.elements[i].shape)
        end
    ''')


def test_native_texture_font_target_and_reaction(runtime):
    runtime.execute('''
        local view=NS.Renderer.Create(UIParent)
        assert(NS.Renderer.Apply(view,NS.GameNameplates[1].layout))
        NS.Renderer.Update(view,{name="Sentinel",level=60,isPlayer=false,controlled=false,reaction=3,target=false,health=76})
        local health,name,border,selected=view.parts[2],view.parts[3],view.parts[5],view.parts[6]
        assert(health.bar.statusTexture=="Interface\\\\TargetingFrame\\\\UI-TargetingFrame-BarFill")
        assert(border.image.texture=="Interface\\\\Tooltips\\\\Nameplate-Border")
        assert(border.image.texCoord[3]==.5 and border.image.texCoord[4]==1)
        assert(border.frame:IsShown() and not selected.frame:IsShown())
        assert(name.text.font[2]==12 and name.text.font[3]=="" and name.text.shadowOffset[1]==1)
        assert(name.text.textColor[1]==1 and name.text.textColor[2]==0)
        NS.Renderer.Update(view,{isPlayer=false,controlled=false,reaction=5,target=true})
        assert(name.text.textColor[1]==0 and name.text.textColor[2]==1)
        assert(selected.frame:IsShown() and selected.image.blendMode=="ADD")
        NS.Renderer.Update(view,{target=nil}); assert(not selected.frame:IsShown())
    ''')


def test_native_texture_false_error_or_secret_return_hides_instead_of_fake_fill(runtime):
    runtime.execute('''
        local layout=NS.GameNameplates[1].layout
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,layout)
        for _,result in ipairs({"false","error","secret"}) do
            for _,part in ipairs(view.parts) do
                if part.image then part.image.SetTexture=function()
                    if result=="false" then return false elseif result=="error" then error("Texture unavailable") end
                    return Mock.Secret()
                end end
            end
            NS.Renderer.Apply(view,layout); NS.Renderer.Update(view,{})
            assert(not view.parts[5].frame:IsShown())
        end
    ''')


def test_native_to_imported_pool_resets_crop_blend_font_and_fill(runtime):
    runtime.execute('''
        local view=NS.Renderer.Create(UIParent)
        NS.Renderer.Apply(view,NS.GameNameplates[1].layout)
        NS.Media.files.classic_frame="classic_frame.tga"
        NS.Renderer.Apply(view,NS.Presets[1].layout); NS.Renderer.Update(view,{})
        for _,p in ipairs(view.parts) do
            if p.kind=="artwork" then
                assert(p.image.texCoord[3]==0 and p.image.blendMode=="BLEND")
            elseif p.kind=="text" then
                assert(p.text.font[3]=="OUTLINE" and p.text.shadowOffset[1]==0)
            elseif p.kind=="health" then assert(p.bar.statusTexture=="Interface\\\\Buttons\\\\WHITE8X8") end
        end
        local count=#Mock.frames
        for i=1,20 do
            NS.Renderer.Apply(view,NS.GameNameplates[1].layout)
            NS.Renderer.Apply(view,NS.Presets[1].layout)
        end
        assert(#Mock.frames==count)
    ''')


def test_game_nameplate_picker_applies_undo_and_disables_missing_references(runtime):
    runtime.execute('''
        NS.Studio.Open(); NS.Studio.ShowPage("studio")
        local picker=NS.Studio.gameNameplatePicker
        picker.scripts.OnClick(); assert(not NS.W.menu.items[3]:IsEnabled())
        NS.W.menu.items[3].scripts.OnClick(); assert(#NS.Studio.session.undo==0)
        NS.W.menu.items[1].scripts.OnClick()
        assert(NS.DB.Current().name==NS.GameNameplates[1].layout.name)
        assert(NS.Studio.session:Undo()); NS.Studio.Refresh()
        assert(NS.DB.Current().name=="Classic Azeroth")
        picker.scripts.OnClick(); NS.W.menu.items[2].scripts.OnClick()
        assert(NS.DB.Current().elements[2].height==4)
    ''')


def test_native_cast_atlas_requires_public_availability_and_preserves_atlas_crop(runtime):
    runtime.execute('''
        local view=NS.Renderer.Create(UIParent); local layout=NS.GameNameplates[2].layout
        NS.Renderer.Apply(view,layout); NS.Renderer.Update(view,{})
        local part=view.parts[#view.parts]; assert(not part.frame:IsShown())
        Mock.atlases={["ui-castingbar-background"]={width=64,height=64}}
        NS.Renderer.Apply(view,layout); NS.Renderer.Update(view,{})
        part=view.parts[#view.parts]
        assert(part.frame:IsShown() and part.image.atlas=="ui-castingbar-background" and part.image.atlasReset)
        C_Texture.GetAtlasInfo=function() return Mock.Secret() end
        NS.Renderer.Apply(view,layout); NS.Renderer.Update(view,{})
        assert(not view.parts[#view.parts].frame:IsShown())
    ''')


def test_native_artwork_is_selectable_and_resizable_in_the_studio(runtime):
    runtime.execute('''
        NS.Studio.Open(); NS.Studio.ShowPage("studio")
        assert(NS.Studio.session:Commit(NS.GameNameplates[1].layout)); NS.Studio.Refresh()
        NS.Studio.Select("artFrame")
        assert(NS.Studio.resizeHandle:IsShown())
        local found=false
        for _,handle in ipairs(NS.Studio.handles) do
            if handle.element and handle.element.id=="artFrame" then found=handle:IsShown() end
        end
        assert(found)
        assert(NS.Studio.session:Resize("artFrame",140,20)); NS.Studio.Refresh()
        assert(NS.Studio.session:Element("artFrame").width==140)
    ''')


def test_fresh_install_uses_classic_source_instead_of_legacy_ornaments(fresh_runtime):
    fresh_runtime.execute('''
        assert(NS.DB.Current().name==NS.GameNameplates[1].layout.name)
        assert(NS.DB.Current().elements[2].width==103)
        NS.Studio.Open(); assert(NS.Studio.page=="studio")
        assert(NS.Studio.gameNameplatePicker.value==1)
        NS.DB.data.live=true; Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1
        assert(view.parts[2].bar.statusTexture=="Interface\\\\TargetingFrame\\\\UI-TargetingFrame-BarFill")
        assert(view.parts[2].bar.value==70)
        for _,e in ipairs(NS.DB.Current().elements) do assert(e.kind~="ornament") end
    ''')


def test_existing_profile_is_not_replaced_by_source_default(runtime):
    runtime.execute('''
        assert(NS.DB.Current().name=="Classic Azeroth")
        assert(NS.DB.Current().elements[2].width==180)
        NS.Studio.Open(); assert(NS.Studio.gameNameplatePicker.value=="Game nameplates")
    ''')
