local addonName,NS=...
local events=CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
local unitEvents={"UNIT_FACTION","UNIT_CLASSIFICATION_CHANGED","UNIT_HEALTH","UNIT_MAXHEALTH","UNIT_AURA","UNIT_NAME_UPDATE","UNIT_LEVEL","UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_FAILED","UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_STOP","UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_INTERRUPTIBLE","UNIT_SPELLCAST_NOT_INTERRUPTIBLE"}
local function initialize()
    NS.Compat.Audit()
    local data,err=NS.DB.Initialize(ForeverNameplatesDB)
    if not data then NS.Print(err); return end
    ForeverNameplatesDB=data
    NS.Minimap.Init()
    local name=NS.Compat.Public(UnitName,"player")
    local realm=NS.Compat.Public(GetRealmName)
    if type(name)=="string" and type(realm)=="string" then NS.DB.character=name.."-"..realm end
    for _,event in ipairs({"NAME_PLATE_UNIT_ADDED","NAME_PLATE_UNIT_REMOVED","PLAYER_ENTERING_WORLD","PLAYER_LEVEL_UP","PLAYER_TARGET_CHANGED","RAID_TARGET_UPDATE","PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED"}) do NS.Compat.Register(events,event) end
    for _,event in ipairs(unitEvents) do NS.Compat.Register(events,event) end
    for _,other in ipairs({"Plater","Kui_Nameplates","TidyPlates_ThreatPlates","NeatPlates"}) do
        local loaded=C_AddOns and C_AddOns.IsAddOnLoaded and NS.Compat.Public(C_AddOns.IsAddOnLoaded,other)
        if loaded then NS.Log("Another nameplate addon is loaded: "..other.."; visual replacement may conflict.") end
    end
    NS.Print("/fnp opens the studio; /fnp apply applies your layout; /fnp off restores Blizzard; /fnp status reports live rendering.")
end
events:SetScript("OnEvent",function(_,event,unit)
    if event=="ADDON_LOADED" then
        if unit==addonName then initialize(); events:UnregisterEvent("ADDON_LOADED") end
        return
    end
    if not NS.DB.data then return end
    if event=="NAME_PLATE_UNIT_ADDED" then NS.Engine.Add(unit)
    elseif event=="NAME_PLATE_UNIT_REMOVED" then NS.Engine.Remove(unit)
    elseif event=="PLAYER_REGEN_DISABLED" then
        NS.Minimap.StopDrag()
        if NS.Studio.root then NS.Studio.EndDrag(false); NS.Studio.root:Hide() end
        if ColorPickerFrame and ColorPickerFrame:IsShown() then ColorPickerFrame:Hide() end
    elseif event=="PLAYER_REGEN_ENABLED" or event=="PLAYER_ENTERING_WORLD" then NS.Minimap.Init(); NS.Engine.Refresh()
    elseif event=="PLAYER_TARGET_CHANGED" then NS.Engine.UpdateAll("target")
    elseif event=="RAID_TARGET_UPDATE" then NS.Engine.UpdateAll("raid")
    elseif event=="PLAYER_LEVEL_UP" then NS.Engine.UpdateAll("level")
    else
        local dependency
        if event=="UNIT_HEALTH" or event=="UNIT_MAXHEALTH" then dependency="health"
        elseif event=="UNIT_AURA" then dependency="auras"
        elseif event=="UNIT_NAME_UPDATE" then dependency="name"
        elseif event=="UNIT_LEVEL" then dependency="level"
        elseif event:find("UNIT_SPELLCAST_",1,true)==1 then dependency="cast" end
        NS.Engine.Update(unit,dependency)
    end
end)
SLASH_FOREVERNAMEPLATES1="/fnp"
SLASH_FOREVERNAMEPLATES2="/forevernameplates"
SlashCmdList.FOREVERNAMEPLATES=function(command)
    command=string.lower((command or ""):match("^%s*(.-)%s*$"))
    if command=="apply" or command=="on" or command=="off" then
        local ok,err=NS.Engine.SetEnabled(command~="off")
        NS.Print(ok and NS.Engine.Status() or err)
    elseif command=="status" then NS.Print(NS.Engine.Status())
    elseif command=="minimap" then NS.Minimap.Toggle()
    elseif command=="diagnostics" then NS.Studio.Open(); if NS.Studio.ready and not NS.InCombat() then NS.Studio.ShowPage("diagnostics") end
    else NS.Studio.Open() end
end
NS.events=events
