local _,NS=...
local Launcher={}
NS.Minimap=Launcher

local function settings() return NS.DB.data and NS.DB.data.minimap end
function Launcher.StopDrag()
    if Launcher.button then Launcher.button:SetScript("OnUpdate",nil) end
    Launcher.dragging=false
end
function Launcher.Position()
    local config=settings()
    if not config or not Launcher.button or not Minimap then return end
    local radians=math.rad(config.angle)
    local x,y=math.cos(radians),math.sin(radians)
    local radius=Minimap:GetWidth()/2+8
    if NS.Compat.Public(GetMinimapShape)=="SQUARE" then radius=radius/math.max(math.abs(x),math.abs(y)) end
    radius=radius*Minimap:GetEffectiveScale()/Launcher.button:GetEffectiveScale()
    Launcher.button:ClearAllPoints()
    Launcher.button:SetPoint("CENTER",Minimap,"CENTER",x*radius,y*radius)
    Launcher.button:SetShown(not config.hidden)
end
function Launcher.Drag()
    if NS.InCombat() then Launcher.StopDrag(); return end
    local cx,cy=Minimap:GetCenter()
    if not cx or not cy then return end
    local x,y=GetCursorPosition(); local scale=Minimap:GetEffectiveScale()
    x,y=x/scale-cx,y/scale-cy
    if x==0 and y==0 then return end
    local angle
    if x==0 then angle=y>0 and 90 or 270
    else angle=math.deg(math.atan(y/x)); if x<0 then angle=angle+180 end end
    settings().angle=angle%360
    Launcher.Position()
end
function Launcher.Toggle()
    if NS.InCombat() then NS.Print(NS.L.combat); return end
    local config=settings(); if not config then return end
    config.hidden=not config.hidden; Launcher.StopDrag(); Launcher.Init()
end
function Launcher.Init()
    if not settings() or not Minimap or NS.InCombat() then return end
    if not Launcher.button then
        -- Minimap is only an anchor; its parent, scripts and protected controls stay intact.
        local b=CreateFrame("Button","ForeverNameplatesMinimapButton",UIParent)
        b:SetSize(32,32); b:SetFrameStrata("MEDIUM"); b:SetFrameLevel(8)
        b:RegisterForClicks("LeftButtonUp","RightButtonUp"); b:RegisterForDrag("LeftButton")
        local icon=b:CreateTexture(nil,"ARTWORK"); icon:SetSize(20,20); icon:SetPoint("CENTER",0,0)
        icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
        local border=b:CreateTexture(nil,"OVERLAY"); border:SetSize(54,54); border:SetPoint("TOPLEFT",0,0)
        border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
        b:SetScript("OnClick",function(_,button)
            if NS.InCombat() then NS.Print(NS.L.combat); return end
            if NS.Studio.root and NS.Studio.ready and NS.Studio.root:IsShown() and button~="RightButton" then NS.Studio.root:Hide(); return end
            NS.Studio.Open()
            if button=="RightButton" and NS.Studio.ready then NS.Studio.ShowPage("diagnostics") end
        end)
        b:SetScript("OnDragStart",function()
            if NS.InCombat() then return end
            if GameTooltip then GameTooltip:Hide() end
            Launcher.dragging=true; b:SetScript("OnUpdate",Launcher.Drag); Launcher.Drag()
        end)
        b:SetScript("OnDragStop",Launcher.StopDrag)
        b:SetScript("OnHide",Launcher.StopDrag)
        b:SetScript("OnEnter",function()
            if not GameTooltip then return end
            GameTooltip:SetOwner(b,"ANCHOR_LEFT"); GameTooltip:SetText(NS.name)
            GameTooltip:AddLine(NS.L.minimapOpen,1,1,1)
            GameTooltip:AddLine(NS.L.minimapDiagnostics,1,1,1)
            GameTooltip:AddLine(NS.L.minimapDrag,.8,.8,.8)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
        Launcher.button=b
    end
    Launcher.Position()
end
