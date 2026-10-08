local _, NS = ...
local W={skin="Dark RPG",surfaces={}}
NS.W=W
W.skins={
    ["Dark RPG"]={bg={.045,.051,.067,1},panel={.075,.083,.105,1},accent={.78,.63,.37,1},text={.9,.89,.85,1}},
    ["Light Fantasy"]={bg={.78,.74,.64,1},panel={.86,.82,.72,1},accent={.37,.24,.12,1},text={.15,.13,.10,1}},
    ["Modern Studio"]={bg={.04,.065,.08,1},panel={.065,.10,.12,1},accent={.3,.73,.76,1},text={.87,.94,.94,1}},
}
function W.Paint(parent,token)
    local t=parent:CreateTexture(nil,"BACKGROUND"); t:SetAllPoints(parent)
    t:SetColorTexture(unpack(W.skins[W.skin][token or "panel"]))
    W.surfaces[#W.surfaces+1]={texture=t,token=token or "panel"}; return t
end
function W.Skin(name)
    if not W.skins[name] then return end
    W.skin=name
    for _,item in ipairs(W.surfaces) do item.texture:SetColorTexture(unpack(W.skins[name][item.token])) end
end
function W.Label(parent,text,size,x,y,color)
    local f=parent:CreateFontString(nil,"OVERLAY")
    f:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",size or 12)
    f:SetPoint("TOPLEFT",parent,"TOPLEFT",x or 0,y or 0)
    f:SetTextColor(unpack(color or {.9,.89,.85,1})); f:SetText(text); f:SetJustifyH("LEFT")
    return f
end
function W.Line(parent,x,y,width)
    local f=CreateFrame("Frame",nil,parent); f:SetSize(width,1); f:SetPoint("TOPLEFT",x,y)
    W.Paint(f,"accent"); return f
end
function W.Button(parent,text,x,y,width,callback)
    local b=CreateFrame("Button",nil,parent); b:SetSize(width or 120,26); b:SetPoint("TOPLEFT",x,y)
    W.Paint(b,"panel")
    local label=W.Label(b,text,11,8,-7); b.label=label
    local hover=b:CreateTexture(nil,"HIGHLIGHT"); hover:SetAllPoints(b); hover:SetColorTexture(.8,.65,.38,.12)
    b:SetScript("OnClick",function() if callback then callback(b) end end)
    return b
end
function W.Edit(parent,x,y,width,text,callback)
    local f=CreateFrame("EditBox",nil,parent); f:SetSize(width,25); f:SetPoint("TOPLEFT",x,y)
    W.Paint(f,"bg"); f:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",11)
    f:SetTextInsets(7,7,3,3); f:SetAutoFocus(false); f:SetMaxLetters(80); f:SetText(text or "")
    f:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    f:SetScript("OnEnterPressed",function(self) self:ClearFocus(); if callback then callback(self:GetText()) end end)
    return f
end
function W.Toggle(parent,text,x,y,width,value,callback)
    local b
    b=W.Button(parent,"",x,y,width,function()
        if NS.InCombat() then NS.Print(NS.L.combat); return end
        callback(not b.value)
    end)
    function b:SetValue(v) self.value=v; self.label:SetText((v and "[x]  " or "[ ]  ")..text) end
    b:SetValue(value); return b
end
function W.Color(color,callback)
    if NS.InCombat() then return end
    if not ColorPickerFrame or not ColorPickerFrame.SetupColorPickerAndShow then NS.Print("Color picker API unavailable"); return end
    local original=NS.Copy(color)
    ColorPickerFrame:SetupColorPickerAndShow({r=color[1],g=color[2],b=color[3],opacity=color[4],hasOpacity=true,
        swatchFunc=function()
            local r,g,b=ColorPickerFrame:GetColorRGB()
            local a=ColorPickerFrame:GetColorAlpha()
            callback({r,g,b,a})
        end,
        opacityFunc=function()
            local r,g,b=ColorPickerFrame:GetColorRGB()
            callback({r,g,b,ColorPickerFrame:GetColorAlpha()})
        end,
        cancelFunc=function() callback(original) end})
end
