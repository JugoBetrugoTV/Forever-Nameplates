local _, NS = ...
local Renderer = {registry={}}
NS.Renderer=Renderer
local white="Interface\\Buttons\\WHITE8X8"
function Renderer.Register(kind, factory) Renderer.registry[kind]=factory end
local function texture(parent)
    local t=parent:CreateTexture(nil,"ARTWORK"); t:SetTexture(white); return t
end
local function frame(parent) return CreateFrame("Frame",nil,parent) end
local function bar(parent)
    local f=CreateFrame("StatusBar",nil,parent)
    f:SetStatusBarTexture(white); f:SetMinMaxValues(0,100); f:SetValue(100)
    return {frame=f,bar=f}
end
Renderer.Register("health",bar); Renderer.Register("cast",bar)
local function textPart(parent)
    local f=frame(parent); local text=f:CreateFontString(nil,"OVERLAY")
    text:SetAllPoints(f); return {frame=f,text=text}
end
Renderer.Register("text",textPart); Renderer.Register("class",textPart)
Renderer.Register("raid",function(parent)
    local f=frame(parent); local t=texture(f); t:SetAllPoints(f)
    t:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    return {frame=f,raid=t}
end)
local function decoration(parent)
    local f=frame(parent); local pieces={}
    for i=1,8 do pieces[i]=texture(f) end
    return {frame=f,pieces=pieces}
end
Renderer.Register("panel",decoration); Renderer.Register("ornament",decoration); Renderer.Register("target",decoration)
Renderer.Register("artwork",function(parent)
    local f=frame(parent); local t=texture(f); t:SetAllPoints(f)
    return {frame=f,image=t}
end)
local function draw(part,e)
    local pieces=part.pieces
    if not pieces then return end
    for _,t in ipairs(pieces) do t:Hide(); t:ClearAllPoints(); if t.SetRotation then t:SetRotation(0) end end
    local function rect(i,x,y,w,h,rotation)
        local t=pieces[i]; t:SetSize(w,h); t:SetPoint("CENTER",part.frame,"CENTER",x,y)
        t:SetVertexColor(unpack(e.color)); if rotation and t.SetRotation then t:SetRotation(rotation) end; t:Show()
    end
    local w,h=e.width,e.height
    if e.shape=="outline" then
        rect(1,-w/2-.5,0,1,h+2); rect(2,w/2+.5,0,1,h+2)
        rect(3,0,h/2+.5,w,1); rect(4,0,-h/2-.5,w,1)
    elseif e.shape=="brackets" then
        for i=1,4 do
            local x=(i%2==1 and -1 or 1)*w/2
            local y=(i<=2 and 1 or -1)*h/2
            rect(i,x,y,6,1); rect(i+4,x,y+(i<=2 and -2 or 2),1,5)
        end
    elseif e.shape=="segments" then
        for i=1,8 do rect(i,(i-4.5)*w/8,0,1,h) end
    elseif e.shape=="rune" then
        rect(1,0,0,w,1); rect(2,0,0,1,h); rect(3,0,0,w*.6,1,math.pi/4)
    elseif e.shape=="diamond" then rect(1,0,0,w*.7,h*.7,math.pi/4)
    else rect(1,0,0,w,h) end
end
function Renderer.Resize(part,width,height)
    part.frame:SetSize(width,height)
    if part.pieces then draw(part,{width=width,height=height,shape=part.element.shape,color=part.element.color}) end
end
function Renderer.Create(parent)
    local root=frame(parent); root:SetSize(1,1); root:EnableMouse(false)
    return {root=root,parts={},pool={}}
end
function Renderer.Apply(view,layout)
    local valid,err=NS.Model.Validate(layout)
    if not valid then return nil,err end
    for _,part in ipairs(view.parts) do
        part.frame:Hide(); view.pool[part.kind]=view.pool[part.kind] or {}
        table.insert(view.pool[part.kind],part)
    end
    view.parts={}; view.layout=valid
    for _,e in ipairs(valid.elements) do
        local pool=view.pool[e.kind] or {}
        local part=table.remove(pool) or Renderer.registry[e.kind](view.root)
        part.kind=e.kind; part.element=e
        local f=part.frame
        f:ClearAllPoints(); f:SetPoint("CENTER",view.root,"CENTER",e.x,e.y)
        f:SetSize(e.width,e.height); f:SetAlpha(e.alpha); f:SetFrameLevel(view.root:GetFrameLevel()+e.layer)
        if part.bar then
            local native=NS.NativeMedia[e.asset]
            local file=NS.ImportKinds[e.asset]=="fill" and NS.Media.files[e.asset]
            local path=native and native.path or (file and ("Interface\\AddOns\\"..NS.folder.."\\Media\\"..file))
            local ok,success=pcall(f.SetStatusBarTexture,f,path or white)
            part.barReady=ok and not NS.Compat.Secret(success) and success==true and (e.asset=="" or path~=nil)
            f:SetStatusBarColor(unpack(e.color)); f:SetOrientation(e.vertical and "VERTICAL" or "HORIZONTAL")
            if f.SetReverseFill then f:SetReverseFill(e.reverse) end
        end
        if part.text then
            local native=NS.NativeMedia[e.asset]
            part.text:SetFont(native and native.font or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",e.fontSize,native and native.flags or "OUTLINE")
            part.text:SetShadowColor(0,0,0,1)
            part.text:SetShadowOffset(native and native.shadow and native.shadow[1] or 0,native and native.shadow and native.shadow[2] or 0)
            part.text:SetTextColor(unpack(e.color)); part.text:SetJustifyH("CENTER")
            for _,outline in ipairs(part.outlines or {}) do outline:Hide() end
            if native and native.outline then
                part.outlines=part.outlines or {}
                for i,offset in ipairs({{-1,0},{1,0},{0,-1},{0,1},{-1,-1},{-1,1},{1,-1},{1,1}}) do
                    local outline=part.outlines[i]
                    if not outline then outline=f:CreateFontString(nil,"BACKGROUND"); part.outlines[i]=outline end
                    outline:ClearAllPoints(); outline:SetSize(e.width,e.height)
                    outline:SetPoint("CENTER",f,"CENTER",offset[1],offset[2])
                    outline:SetFont(native.font,e.fontSize,""); outline:SetTextColor(unpack(native.outline))
                    outline:SetJustifyH("CENTER"); outline:Show()
                end
            end
        end
        draw(part,e)
        if part.raid then part.raid:SetVertexColor(unpack(e.color)) end
        if part.image then
            part.image:SetVertexColor(unpack(e.color))
            local native=NS.NativeMedia[e.asset]
            local file=NS.Media.files[e.asset]
            local path=native and native.path or (file and ("Interface\\AddOns\\"..NS.folder.."\\Media\\"..file))
            part.imageReady=false
            if native and native.atlas then
                local info=C_Texture and NS.Compat.Public(C_Texture.GetAtlasInfo,native.atlas)
                if type(info)=="table" and part.image.SetAtlas then
                    part.imageReady=pcall(part.image.SetAtlas,part.image,native.atlas,false,nil,true)
                    if part.imageReady then part.image:SetBlendMode("BLEND") end
                end
            elseif path then
                local ok,success=pcall(part.image.SetTexture,part.image,path)
                part.imageReady=ok and not NS.Compat.Secret(success) and success==true
                if part.imageReady then
                    part.image:SetTexCoord(unpack(native and native.coords or {0,1,0,1}))
                    part.image:SetBlendMode(native and native.blend or "BLEND")
                end
            end
        end
        f:SetShown(e.enabled and (not part.bar or part.barReady) and (not part.image or part.imageReady))
        view.parts[#view.parts+1]=part
    end
    return true
end
function Renderer.Update(view,state,unit)
    local effect=NS.Rules.Resolve(view.layout.rules,state)
    view.effect=effect
    view.root:SetScale((view.previewScale or 1)*effect.scale); view.root:SetAlpha(effect.alpha)
    view.root:SetShown(effect.visible)
    if not effect.visible then return end
    for _,part in ipairs(view.parts) do
        local e=part.element
        local show=e.enabled
        if part.image then show=show and part.imageReady end
        if e.source=="target" then show=show and state.target==true end
        if part.kind=="target" then show=show and state.target end
        if part.raid then
            local marker=state.raidMarker
            show=show and type(marker)=="number" and marker>=1 and marker<=8 and marker%1==0
            -- Delegate atlas layout to the client's exported UI helper.
            show=show and type(SetRaidTargetIconTexture)=="function"
            if show then show=pcall(SetRaidTargetIconTexture,part.raid,marker) end
        end
        if part.kind=="class" then
            show=show and state.isPlayer==true and NS.Rules.classLabels[state.class]~=nil
            part.text:SetTextColor(unpack(NS.Rules.classColors[state.class] or e.color))
        end
        if part.bar then
            show=show and part.barReady
            if part.kind=="health" then
                part.bar:SetStatusBarColor(unpack(NS.Rules.HealthColor(view.layout.rules,effect,state,e.color)))
                if unit then show=show and NS.Compat.Health(part.bar,unit)
                else part.bar:SetMinMaxValues(0,100); part.bar:SetValue(state.health or 75) end
            elseif unit then show=show and NS.Compat.Cast(part.bar,unit)
            else
                part.bar:SetMinMaxValues(0,100); part.bar:SetValue(state.progress or 55)
                show=show and state.casting
            end
        end
        if part.text then
            local native=NS.NativeMedia[e.asset]
            if native and native.reactionText then
                part.text:SetTextColor(unpack(NS.Rules.HealthColor(view.layout.rules,{colorMode="reaction"},state,e.color)))
            end
            local value=e.text
            if e.source=="name" then value=state.name
            elseif e.source=="health" then value=state.healthText
            elseif e.source=="level" then value=state.level
            elseif e.source=="cast" then value=state.castName
            elseif e.source=="classification" then value=state.classification
            elseif e.source=="class" then value=state.isPlayer==true and NS.Rules.classLabels[state.class] or "" end
            if part.kind=="class" then value=NS.Rules.classLabels[state.class] end
            if native and native.prefix then
                if not NS.Compat.Secret(value) and (type(value)=="string" or type(value)=="number") and tostring(value)~="" then value=native.prefix..value
                else value="" end
            end
            part.text:SetText(value or "")
            for _,outline in ipairs(part.outlines or {}) do outline:SetText(value or "") end
        end
        part.frame:SetShown(show==true)
    end
end

local Engine={units={},views={},pending={},stats={created=0,updates=0,skipped=0}}
NS.Engine=Engine
function Engine.Remove(unit)
    if NS.Compat.Secret(unit) then return end
    local view=Engine.units[unit]
    if view and NS.Compat.SafeFrame(view.root) then view.root:Hide() end
    Engine.units[unit]=nil; Engine.pending[unit]=nil
end
function Engine.Add(unit)
    if NS.Compat.Secret(unit) or type(unit)~="string" then return end
    if not NS.DB.data or not NS.DB.data.live then return end
    if not NS.Compat.expected or not NS.Compat.nameplates then return end
    if NS.InCombat() then Engine.pending[unit]=true; return end
    local base=NS.Compat.GetPlate(unit)
    if not base then Engine.stats.skipped=Engine.stats.skipped+1; return end
    local view=Engine.views[base]
    if not view then
        view=Renderer.Create(base)
        view.root:SetPoint("BOTTOM",base,"TOP",0,45)
        Engine.views[base]=view; Engine.stats.created=Engine.stats.created+1
    end
    if not NS.Compat.SafeFrame(view.root) then return end
    -- Blizzard may recycle the same frame for a different unit.
    if view.unit and view.unit~=unit then Engine.units[view.unit]=nil end
    view.unit=unit; Engine.units[unit]=view; Engine.pending[unit]=nil
    Renderer.Apply(view,NS.DB.Current()); view.root:Show(); Engine.Update(unit)
end
function Engine.Update(unit)
    if NS.Compat.Secret(unit) then return end
    local view=Engine.units[unit]
    if not view or not NS.Compat.SafeFrame(view.root) then return end
    Renderer.Update(view,NS.Compat.State(unit),unit); Engine.stats.updates=Engine.stats.updates+1
end
function Engine.Refresh()
    if NS.InCombat() then Engine.dirty=true; return end
    Engine.dirty=false
    for unit,view in pairs(Engine.units) do
        if NS.DB.data.live and NS.Compat.SafeFrame(view.root) then Renderer.Apply(view,NS.DB.Current()); Engine.Update(unit)
        else Engine.Remove(unit) end
    end
    if NS.DB.data.live then
        -- A bounded discovery pass, never a per-frame or OnUpdate scan.
        for i=1,200 do local unit="nameplate"..i; if NS.Compat.GetPlate(unit) then Engine.Add(unit) end end
    end
end
NS.On("LAYOUT_CHANGED",Engine.Refresh)
