"""Pinned Classic level behavior; real Forever pixels/permissions remain unverified."""
import pytest


def test_classic_level_uses_public_client_difficulty_color_and_updates(runtime):
    runtime.execute('''
        local calls=0
        GetCreatureDifficultyColor=function(level)
            assert(level==60 or level==61); calls=calls+1
            return level==60 and {r=1,g=.1,b=.2} or {r=.3,g=.8,b=.1}
        end
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,NS.GameNameplates[1].layout)
        local level=view.parts[4]
        NS.Renderer.Update(view,{level=60})
        assert(level.text:GetText()=="60" and level.text.textColor[2]==.1 and not level.skull:IsShown())
        NS.Renderer.Update(view,{level=61})
        assert(level.text:GetText()=="61" and level.text.textColor[2]==.8 and calls==2)
        assert(level.frame:IsShown())
    ''')


@pytest.mark.parametrize("value", ['"??"', "-1", "0"])
def test_classic_unknown_high_level_uses_native_skull(runtime, value):
    runtime.execute(f'''
        GetCreatureDifficultyColor=function() error("Unknown level must not request a difficulty color") end
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,NS.GameNameplates[1].layout)
        local level=view.parts[4]
        NS.Renderer.Update(view,{{level={value}}})
        assert(level.text:GetText()=="" and level.skull:IsShown())
        assert(level.skull.texture=="Interface\\\\TargetingFrame\\\\UI-TargetingFrame-Skull")
        assert(level.skull.allPoints==level.frame and level.frame.width==15 and level.frame.height==15)
        NS.Renderer.Update(view,{{level=60}})
        assert(not level.skull:IsShown() and level.text:GetText()=="60")
    ''')


def test_classic_secret_or_missing_level_is_omitted_without_guessing_skull(runtime):
    runtime.execute('''
        local calls=0; GetCreatureDifficultyColor=function() calls=calls+1; return {r=1,g=1,b=0} end
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,NS.GameNameplates[1].layout)
        local level=view.parts[4]
        for _,value in ipairs({Mock.Secret(),"",false,-2,0/0,math.huge}) do
            NS.Renderer.Update(view,{level=value})
            assert(level.text:GetText()=="" and not level.skull:IsShown() and not level.frame:IsShown())
        end
        assert(calls==0)
        Mock.AddUnit("nameplate1"); Mock.units.nameplate1.level=Mock.Secret()
        NS.Renderer.Update(view,NS.Compat.State("nameplate1"),"nameplate1")
        assert(not level.skull:IsShown() and not level.frame:IsShown())
    ''')


def test_difficulty_helper_validates_public_table_channels_and_keeps_fallback(runtime):
    runtime.execute('''
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,NS.GameNameplates[1].layout)
        local level=view.parts[4]; local fallback=level.element.color
        for _,color in ipairs({Mock.Secret(),{r=Mock.Secret(),g=.5,b=.5},{r=2,g=0,b=0},
            {r=0/0,g=0,b=0},{r=false,g=1,b=0},{g=1,b=0}}) do
            GetCreatureDifficultyColor=function() return color end
            NS.Renderer.Update(view,{level=60})
            assert(level.text.textColor[1]==fallback[1] and level.text.textColor[2]==fallback[2])
        end
        GetCreatureDifficultyColor=nil; NS.Renderer.Update(view,{level=60})
        assert(level.text:GetText()=="60" and level.text.textColor[2]==fallback[2])
        GetCreatureDifficultyColor=function() error("Helper refused") end
        NS.Renderer.Update(view,{level=60}); assert(level.text.textColor[2]==fallback[2])
        assert(not NS.Compat.LevelColor(Mock.Secret()))
    ''')


@pytest.mark.parametrize("result", ["false", "error", "secret"])
def test_missing_or_refused_skull_texture_uses_unknown_level_text(runtime, result):
    runtime.globals().textureResult = result
    runtime.execute('''
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,NS.GameNameplates[1].layout)
        -- Apply takes text parts from a LIFO pool; the level part can change.
        for _,part in ipairs(view.parts) do
            if part.skull then part.skull.SetTexture=function()
                if textureResult=="false" then return false end
                if textureResult=="error" then error("Native texture missing") end
                return Mock.Secret()
            end end
        end
        NS.Renderer.Apply(view,NS.GameNameplates[1].layout); NS.Renderer.Update(view,{level="??"})
        local current=view.parts[4]
        assert(current.text:GetText()=="??" and not current.skull:IsShown())
    ''')


def test_native_skull_is_hidden_and_reused_across_other_text_styles(runtime):
    runtime.execute('''
        local view=NS.Renderer.Create(UIParent); NS.Renderer.Apply(view,NS.GameNameplates[1].layout)
        NS.Renderer.Update(view,{level="??"}); assert(view.parts[4].skull:IsShown())
        NS.Renderer.Apply(view,NS.Presets[1].layout); NS.Renderer.Update(view,{level=60})
        local count=#Mock.frames
        for _,part in ipairs(view.parts) do if part.skull then assert(not part.skull:IsShown()) end end
        for i=1,10 do
            NS.Renderer.Apply(view,NS.GameNameplates[1].layout); NS.Renderer.Update(view,{level="??"})
            assert(view.parts[4].skull:IsShown())
            NS.Renderer.Apply(view,NS.Presets[1].layout); NS.Renderer.Update(view,{level=60})
            for _,part in ipairs(view.parts) do if part.skull then assert(not part.skull:IsShown()) end end
        end
        assert(#Mock.frames==count)
    ''')


def test_live_player_level_up_refreshes_classic_color_and_unit_level_skull(runtime):
    runtime.execute('''
        local brightness=.2
        GetCreatureDifficultyColor=function() return {r=1,g=brightness,b=0} end
        assert(NS.DB.Save(NS.GameNameplates[1].layout))
        local base=Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; local level=view.parts[4]
        assert(level.text.textColor[2]==.2)
        brightness=.6; Mock.Fire(NS.events,"PLAYER_LEVEL_UP",61)
        assert(level.text.textColor[2]==.6 and base.UnitFrame:GetAlpha()==0)
        Mock.units.nameplate1.level=-1; Mock.Fire(NS.events,"UNIT_LEVEL","nameplate1")
        assert(level.skull:IsShown() and level.text:GetText()=="")
        Mock.units.nameplate1.level=Mock.Secret(); Mock.Fire(NS.events,"UNIT_LEVEL","nameplate1")
        assert(not level.skull:IsShown() and not level.frame:IsShown())
    ''')
