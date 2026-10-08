local addonName,NS=...
local events=CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
local unitEvents={"UNIT_HEALTH","UNIT_MAXHEALTH","UNIT_NAME_UPDATE","UNIT_LEVEL","UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP","UNIT_SPELLCAST_FAILED","UNIT_SPELLCAST_INTERRUPTED","UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START","UNIT_SPELLCAST_CHANNEL_STOP","UNIT_SPELLCAST_CHANNEL_UPDATE"}
local function initialize()
    NS.Compat.Audit()
    local data,err=NS.DB.Initialize(ForeverNameplatesDB)
    if not data then NS.Print(err); return end
    ForeverNameplatesDB=data
    local name=NS.Compat.Public(UnitName,"player")
    local realm=NS.Compat.Public(GetRealmName)
    if type(name)=="string" and type(realm)=="string" then NS.DB.character=name.."-"..realm end
    for _,event in ipairs({"NAME_PLATE_UNIT_ADDED","NAME_PLATE_UNIT_REMOVED","PLAYER_ENTERING_WORLD","PLAYER_TARGET_CHANGED","PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED"}) do NS.Compat.Register(events,event) end
    for _,event in ipairs(unitEvents) do NS.Compat.Register(events,event) end
    for _,other in ipairs({"Plater","Kui_Nameplates","TidyPlates_ThreatPlates","NeatPlates"}) do
        local loaded=C_AddOns and C_AddOns.IsAddOnLoaded and NS.Compat.Public(C_AddOns.IsAddOnLoaded,other)
        if loaded then NS.Log("Another nameplate addon is loaded: "..other.."; live overlay may overlap.") end
    end
    NS.Print("/fnp opens the studio. Live overlay is opt-in; Forever in-game validation is pending.")
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
        if NS.Studio.root then NS.Studio.EndDrag(false); NS.Studio.root:Hide() end
        if ColorPickerFrame and ColorPickerFrame:IsShown() then ColorPickerFrame:Hide() end
    elseif event=="PLAYER_REGEN_ENABLED" or event=="PLAYER_ENTERING_WORLD" then NS.Engine.Refresh()
    elseif event=="PLAYER_TARGET_CHANGED" then for token in pairs(NS.Engine.units) do NS.Engine.Update(token) end
    else NS.Engine.Update(unit) end
end)
SLASH_FOREVERNAMEPLATES1="/fnp"
SLASH_FOREVERNAMEPLATES2="/forevernameplates"
SlashCmdList.FOREVERNAMEPLATES=function(command)
    if command=="diagnostics" then NS.Studio.Open(); if NS.Studio.root and not NS.InCombat() then NS.Studio.ShowPage("diagnostics") end
    else NS.Studio.Open() end
end
NS.events=events
