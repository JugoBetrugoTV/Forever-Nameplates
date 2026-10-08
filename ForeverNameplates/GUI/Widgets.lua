local _, NS = ...
local W={skin="Dark RPG",surfaces={},fonts={}}
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
    for _,item in ipairs(W.fonts) do item.font:SetTextColor(unpack(W.skins[name][item.token])) end
end
function W.Label(parent,text,size,x,y,color)
    local f=parent:CreateFontString(nil,"OVERLAY")
    f:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",size or 12,"")
    f:SetPoint("TOPLEFT",parent,"TOPLEFT",x or 0,y or 0)
    if not color or type(color)=="string" then
        local token=color or "text"
        W.fonts[#W.fonts+1]={font=f,token=token}; f:SetTextColor(unpack(W.skins[W.skin][token]))
    else f:SetTextColor(unpack(color)) end
    f:SetText(text); f:SetJustifyH("LEFT")
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
    b:SetScript("OnClick",function() if b:IsEnabled() and callback then callback(b) end end)
    return b
end
function W.Edit(parent,x,y,width,text,callback)
    local f=CreateFrame("EditBox",nil,parent); f:SetSize(width,25); f:SetPoint("TOPLEFT",x,y)
    W.Paint(f,"bg"); f:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",11,"")
    f:SetTextColor(unpack(W.skins[W.skin].text)); W.fonts[#W.fonts+1]={font=f,token="text"}
    f:SetTextInsets(7,7,3,3); f:SetAutoFocus(false); f:SetMaxLetters(80); f:SetText(text or "")
    f:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    f:SetScript("OnEnterPressed",function(self) self:ClearFocus(); if callback then callback(self:GetText()) end end)
    return f
end
function W.ClosePopups()
    if W.menuOverlay then W.menuOverlay:Hide() end
    if W.confirmOverlay then W.confirmOverlay:Hide(); W.confirmAction=nil end
end
local function overlay()
    local f=CreateFrame("Frame",nil,UIParent); f:SetAllPoints(UIParent)
    f:SetFrameStrata("FULLSCREEN_DIALOG"); f:EnableMouse(true)
    f:SetScript("OnMouseDown",W.ClosePopups)
    return f
end
function W.Menu(anchor,choices,onSelect)
    if NS.InCombat() then return end
    W.ClosePopups()
    if not W.menuOverlay then
        W.menuOverlay=overlay()
        W.menu=CreateFrame("Frame",nil,W.menuOverlay); W.menu:EnableMouse(true); W.Paint(W.menu,"bg")
        W.menu.items={}
    end
    local menu=W.menu
    menu:ClearAllPoints(); menu:SetPoint("TOPLEFT",anchor,"BOTTOMLEFT",0,-3)
    menu:SetScale(anchor:GetEffectiveScale()/UIParent:GetEffectiveScale())
    local width=math.max(210,anchor:GetWidth())
    local function showPage(page)
        menu.page=page
        for _,item in ipairs(menu.items) do item:Hide() end
        local first=(page-1)*8+1; local count=math.min(8,#choices-first+1)
        for i=1,count do
            local choice=choices[first+i-1]
            local item=menu.items[i]
            if not item then item=W.Button(menu,"",6,-6-(i-1)*30,width-12); menu.items[i]=item end
            item:SetWidth(width-12); item.label:SetText(choice.label or tostring(choice.value))
            item:SetEnabled(not choice.disabled); item:SetAlpha(choice.disabled and .4 or 1); item:Show()
            item:SetScript("OnClick",function()
                if not item:IsEnabled() or NS.InCombat() then return end
                W.ClosePopups(); onSelect(choice.value)
            end)
        end
        if not menu.previous then
            menu.previous=W.Button(menu,"‹",6,0,84)
            menu.next=W.Button(menu,"›",96,0,84)
        end
        local paged=#choices>8
        menu.previous:SetShown(paged); menu.next:SetShown(paged)
        menu.previous:ClearAllPoints(); menu.previous:SetPoint("TOPLEFT",6,-6-count*30)
        menu.next:ClearAllPoints(); menu.next:SetPoint("TOPLEFT",96,-6-count*30)
        menu.previous:SetEnabled(page>1); menu.next:SetEnabled(first+count<=#choices)
        menu.previous:SetScript("OnClick",function() if page>1 then showPage(page-1) end end)
        menu.next:SetScript("OnClick",function() if first+count<=#choices then showPage(page+1) end end)
        local height=12+count*30+(paged and 30 or 0)
        menu:SetSize(width,height)
        if anchor.GetBottom then
            local bottom=anchor:GetBottom()
            menu:ClearAllPoints()
            if bottom and bottom<height+12 then menu:SetPoint("BOTTOMLEFT",anchor,"TOPLEFT",0,3)
            else menu:SetPoint("TOPLEFT",anchor,"BOTTOMLEFT",0,-3) end
        end
    end
    if #choices==0 then return end
    showPage(1); W.menuOverlay:Show(); menu:Show()
end
function W.Dropdown(parent,x,y,width,choices,callback)
    local b
    local function options() return type(choices)=="function" and choices() or choices end
    b=W.Button(parent,"",x,y,width,function() W.Menu(b,options(),function(value)
        if callback(value)~=false then b:SetValue(value) end
    end) end)
    function b:SetValue(value)
        self.value=value
        for _,choice in ipairs(options()) do
            if choice.value==value then self.label:SetText((choice.label or tostring(value)).."  ▾"); return end
        end
        self.label:SetText(tostring(value or "Select").."  ▾")
    end
    return b
end
function W.Confirm(parent,message,onAccept)
    if NS.InCombat() then return end
    W.ClosePopups()
    if not W.confirmOverlay then
        W.confirmOverlay=overlay()
        local shade=W.confirmOverlay:CreateTexture(nil,"BACKGROUND"); shade:SetAllPoints(W.confirmOverlay); shade:SetColorTexture(0,0,0,.55)
        local dialog=CreateFrame("Frame",nil,W.confirmOverlay); dialog:SetSize(430,144); dialog:EnableMouse(true)
        W.Paint(dialog,"bg"); W.Line(dialog,0,0,430)
        W.confirm=dialog; W.confirmMessage=W.Label(dialog,"",13,18,-20); W.confirmMessage:SetWidth(394)
        W.confirmAccept=W.Button(dialog,NS.L.confirm,18,-98,190,function()
            local action=W.confirmAction; W.ClosePopups()
            if not NS.InCombat() and action then action() end
        end)
        W.Button(dialog,NS.L.cancel,222,-98,190,W.ClosePopups)
    end
    W.confirm:ClearAllPoints(); W.confirm:SetPoint("CENTER",parent,"CENTER",0,0)
    W.confirm:SetScale(parent:GetEffectiveScale()/UIParent:GetEffectiveScale())
    W.confirmMessage:SetText(message); W.confirmAction=onAccept
    W.confirmOverlay:Show(); W.confirm:Show()
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
