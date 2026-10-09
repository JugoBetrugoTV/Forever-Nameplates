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
Renderer.Register("health",bar)
Renderer.Register("cast",function(parent)
    local part=bar(parent); part.spark=part.frame:CreateTexture(nil,"OVERLAY"); part.spark:Hide(); return part
end)
local function textPart(parent)
    local f=frame(parent); local text=f:CreateFontString(nil,"OVERLAY")
    local skull=f:CreateTexture(nil,"OVERLAY"); skull:Hide()
    text:SetAllPoints(f); return {frame=f,text=text,skull=skull}
end
Renderer.Register("text",textPart); Renderer.Register("class",textPart)
local function iconPart(parent)
    local f=frame(parent); local t=f:CreateTexture(nil,"ARTWORK"); t:SetAllPoints(f); t:Hide()
    return {frame=f,icon=t}
end
Renderer.Register("classIcon",iconPart); Renderer.Register("castIcon",iconPart)
Renderer.Register("castShield",iconPart)
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
    view.parts={}; view.layout=valid; view.needs={}; view.castVisible=nil
    view.needs.target=valid.rules.overrides.target.enabled or valid.rules.overrides.nonTarget.enabled
    local hasCast,castBackground=false,false
    for _,e in ipairs(valid.elements) do
        if e.enabled and e.kind=="text" then view.needs[e.source]=true end
        if e.enabled and e.kind~="cast" and e.source=="cast" then view.needs.cast=true end
        if e.enabled and (e.kind=="target" or e.source=="target") then view.needs.target=true end
        if e.enabled and e.kind=="raid" then view.needs.raid=true end
        if e.enabled and e.kind=="castShield" then view.needs.cast=true; view.needs.shield=true end
        if e.enabled and e.kind=="cast" then
            view.needs.castBar=true
            if e.castStyle and e.castStyle.enabled then view.needs.cast=true; view.needs.shield=true end
        end
        if e.enabled and e.kind=="auras" then view.needs.auras=true end
        if e.kind=="cast" then hasCast=true end
        if e.enabled and e.asset=="wow_df_cast_background" then castBackground=true end
        local pool=view.pool[e.kind] or {}
        local part=table.remove(pool) or Renderer.registry[e.kind](view.root)
        part.kind=e.kind; part.element=e
        local f=part.frame
        f:ClearAllPoints(); f:SetPoint("CENTER",view.root,"CENTER",e.x,e.y)
        f:SetSize(e.width,e.height); f:SetAlpha(e.alpha); f:SetFrameLevel(view.root:GetFrameLevel()+e.layer)
        if part.icon then
            part.icon:Hide(); pcall(part.icon.SetTexture,part.icon,nil); part.icon:SetTexCoord(0,1,0,1)
            part.icon:SetVertexColor(unpack(e.color)); part.icon:SetBlendMode("BLEND")
        end
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
            if part.skull then part.skull:Hide() end
            part.skullReady=false
            if native and native.skullPath and e.source=="level" then
                part.skull:SetAllPoints(f); part.skull:SetVertexColor(1,1,1,1)
                local ok,success=pcall(part.skull.SetTexture,part.skull,native.skullPath)
                part.skullReady=ok and not NS.Compat.Secret(success) and success==true
            end
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
        if part.auraSlots then NS.Auras.Layout(part,e) end
        if part.spark then
            part.spark:Hide(); part.sparkReady=false
            local style=e.castStyle
            if style and style.spark then
                local ok,success=pcall(part.spark.SetTexture,part.spark,"Interface\\CastingBar\\UI-CastingBar-Spark")
                part.sparkReady=ok and not NS.Compat.Secret(success) and success==true
                part.spark:SetVertexColor(unpack(style.sparkColor)); part.spark:SetAlpha(style.sparkAlpha)
                part.spark:SetSize(e.vertical and e.width+6 or style.sparkWidth,e.vertical and style.sparkWidth or e.height+6)
                part.spark:ClearAllPoints()
                local fill=NS.Compat.Public(part.bar.GetStatusBarTexture,part.bar)
                local edge=e.vertical and (e.reverse and "BOTTOM" or "TOP") or (e.reverse and "LEFT" or "RIGHT")
                if fill then part.sparkReady=part.sparkReady and pcall(part.spark.SetPoint,part.spark,"CENTER",fill,edge,0,0)
                else part.sparkReady=false end
            end
        end
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
    if castBackground and not hasCast then view.needs.cast=true end
    local byId={}; for _,part in ipairs(view.parts) do byId[part.element.id]=part.frame end
    for _,part in ipairs(view.parts) do
        local e=part.element
        if e.anchor then
            part.frame:ClearAllPoints(); part.frame:SetPoint(e.anchor.point,byId[e.anchor.ref],e.anchor.relativePoint,e.x,e.y)
        end
    end
    return true
end
function Renderer.PrimaryMatches(e,dependency)
    if not dependency then return true end
    if dependency=="health" then return e.kind=="health" or (e.kind=="text" and e.source=="health") end
    if dependency=="cast" then return e.kind=="cast" or e.source=="cast" or e.asset=="wow_df_cast_background" end
    if dependency=="auras" then return e.kind=="auras" end
    return e.kind=="text" and e.source==dependency
end
function Renderer.Matches(e,dependency)
    return Renderer.PrimaryMatches(e,dependency) or e.kind=="class" or e.kind=="classIcon" or
        (e.kind=="text" and (e.source=="name" or e.source=="level" or e.source=="class" or e.source=="classification"))
end
function Renderer.Update(view,state,unit,dependency)
    local effect=NS.Rules.Resolve(view.layout.rules,state)
    view.effect=effect
    view.root:SetScale((view.previewScale or 1)*effect.scale); view.root:SetAlpha(effect.alpha)
    view.root:SetShown(effect.visible)
    if not effect.visible then return true end
    local ready=true
    local hasCast,castShown=false,false
    for _,part in ipairs(view.parts) do
        local e=part.element
        if Renderer.Matches(e,dependency) then
            local show=e.enabled
            if part.image then show=show and part.imageReady end
            if e.enabled and part.kind=="health" and not part.barReady then ready=false end
            if e.source=="target" then show=show and state.target==true end
            if part.kind=="target" then show=show and state.target end
            if part.raid then
                local marker=state.raidMarker
                show=show and type(marker)=="number" and marker>=1 and marker<=8 and marker%1==0
                show=show and type(SetRaidTargetIconTexture)=="function"
                if show then show=pcall(SetRaidTargetIconTexture,part.raid,marker) end
            end
            if part.kind=="class" then
                show=show and state.isPlayer==true and NS.Rules.classLabels[state.class]~=nil
                part.text:SetTextColor(unpack(NS.Rules.classColors[state.class] or e.color))
            end
            if part.auraSlots then show=show and NS.Auras.Update(part,e,state,unit) end
            if part.icon then
                local usable=false
                part.icon:Hide()
                if show and part.kind=="classIcon" and state.isPlayer==true and
                    not NS.Compat.Secret(state.class) and type(state.class)=="string" and NS.Rules.classLabels[state.class] then
                    local atlas="classicon-"..string.lower(state.class)
                    local info=C_Texture and NS.Compat.Public(C_Texture.GetAtlasInfo,atlas)
                    if type(info)=="table" and part.icon.SetAtlas then
                        usable=pcall(part.icon.SetAtlas,part.icon,atlas,false,nil,true)
                    end
                elseif show and part.kind=="castShield" and not NS.Compat.Secret(state.castShield) and state.castShield==true then
                    local atlas="nameplates-InterruptShield"
                    local info=C_Texture and NS.Compat.Public(C_Texture.GetAtlasInfo,atlas)
                    if type(info)=="table" and part.icon.SetAtlas then
                        usable=pcall(part.icon.SetAtlas,part.icon,atlas,false,nil,true)
                    end
                elseif show and part.kind=="castIcon" then
                    local icon=state.castIcon
                    if not NS.Compat.Secret(icon) and type(icon)=="number" and icon>0 and icon%1==0 then
                        local ok,success=pcall(part.icon.SetTexture,part.icon,icon)
                        usable=ok and not NS.Compat.Secret(success) and success==true
                    end
                end
                show=show and usable; part.icon:SetShown(show==true)
            end
            if part.bar then
                show=show and part.barReady
                if part.kind=="health" then
                    part.bar:SetStatusBarColor(unpack(NS.Rules.HealthColor(view.layout.rules,effect,state,e.color)))
                    if unit then
                        if show and not NS.Compat.Health(part.bar,unit) then show=false; ready=false end
                    else part.bar:SetMinMaxValues(0,100); part.bar:SetValue(state.health or 75) end
                elseif unit then
                    if show then local ok,channel=NS.Compat.Cast(part.bar,unit); show=ok; part.channel=channel end
                else
                    part.bar:SetMinMaxValues(0,100); part.bar:SetValue(state.progress or 55)
                    show=show and state.casting
                    part.channel=state.channel==true
                end
                if part.kind=="cast" then
                    local style=e.castStyle
                    local color=e.color
                    if style and style.enabled then color=state.castShield==true and style.shield or part.channel and style.channel or style.normal end
                    part.bar:SetStatusBarColor(unpack(color))
                    part.spark:SetShown(show==true and part.sparkReady==true)
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
                if part.skull then part.skull:Hide() end
                if native and native.difficulty and e.source=="level" then
                    local public=not NS.Compat.Secret(value)
                    local normal=public and type(value)=="number" and value>0 and value%1==0
                    local high=public and (value=="??" or value==-1 or value==0)
                    if normal then
                        local color=NS.Compat.LevelColor(value) or e.color
                        part.text:SetTextColor(color[1],color[2],color[3],e.color[4])
                    elseif high then
                        if part.skullReady then part.skull:SetShown(show==true); value="" else value="??" end
                    else value=""; show=false end
                end
                part.text:SetText(value or "")
                for _,outline in ipairs(part.outlines or {}) do outline:SetText(value or "") end
            end
            part.shown=show==true
            part.frame:SetShown(part.shown)
            if part.kind=="cast" then hasCast=true; castShown=castShown or part.shown end
        end
    end
    local showCast=castShown or (not hasCast and state.casting==true)
    if not dependency or dependency=="cast" then view.castVisible=showCast
    else showCast=view.castVisible==true end
    for _,part in ipairs(view.parts) do
        local e=part.element
        if e.kind~="cast" and (e.source=="cast" or e.asset=="wow_df_cast_background") and
            (not dependency or dependency=="cast" or Renderer.Matches(e,dependency)) then
            part.frame:SetShown(part.shown and showCast)
        end
    end
    if not dependency or dependency=="health" then view.healthReady=ready end
    return ready and view.healthReady~=false
end
