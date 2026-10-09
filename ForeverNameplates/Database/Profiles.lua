local _, NS = ...
local DB = {}
NS.DB = DB
function DB.Editable()
    if NS.databaseBlocked or not DB.data then return nil,"Database is read-only" end
    if NS.InCombat() then return nil,NS.L.combat end
    return true
end
function DB.Initialize(saved)
    if type(saved) == "table" and type(saved.version) == "number" and saved.version > 2 then
        NS.databaseBlocked = true
        return nil, "Newer SavedVariables version; data preserved."
    end
    NS.databaseBlocked=false
    local data = {version=2, profiles={}, characters={}, active="Default", live=true,liveMode="replacement-v1",minimap={angle=225,hidden=false},guiSkin="Dark RPG"}
    local skins={["Dark RPG"]=true,["Light Fantasy"]=true,["Modern Studio"]=true}
    if type(saved)=="table" and type(saved.guiSkin)=="string" and skins[saved.guiSkin] then data.guiSkin=saved.guiSkin end
    if type(saved)=="table" and type(saved.minimap)=="table" then
        local angle=saved.minimap.angle
        if type(angle)=="number" and angle==angle and angle~=math.huge and angle~=-math.huge then data.minimap.angle=angle%360 end
        data.minimap.hidden=saved.minimap.hidden==true
    end
    -- Explicit v0 migration: one declarative layout, no executable values.
    if type(saved) == "table" and saved.version == 0 then
        local migrated = NS.Model.Validate(saved.layout)
        if migrated then data.profiles.Default = migrated end
    elseif type(saved) == "table" and (saved.version == 1 or saved.version == 2) then
        local n = 1
        data.profiles.Default=NS.Copy(NS.GameNameplates[1].layout)
        if type(saved.profiles) == "table" then
            local default=NS.Model.Validate(saved.profiles.Default)
            if default then data.profiles.Default=default end
            for name, layout in pairs(saved.profiles) do
                local valid = NS.Model.Name(name) and NS.Model.Validate(layout)
                if name~="Default" and valid and n < 32 then data.profiles[name]=valid; n=n+1 end
            end
        end
        if type(saved.characters) == "table" then
            n=0
            for character, name in pairs(saved.characters) do
                if NS.Model.Name(character) and data.profiles[name] and n<128 then
                    data.characters[character]=name; n=n+1
                end
            end
        end
        if data.profiles[saved.active] then data.active = saved.active end
        -- The old default disabled the preview-only overlay. Enable actual application
        -- once on upgrade; subsequent explicit opt-outs remain persistent.
        if saved.liveMode=="replacement-v1" then data.live = saved.live == true end
    end
    data.profiles.Default = data.profiles.Default or NS.Copy(NS.GameNameplates[1].layout)
    DB.data = data
    return data
end
function DB.CurrentName()
    return DB.character and DB.data.characters[DB.character] or DB.data.active
end
function DB.Current() return DB.data.profiles[DB.CurrentName()] end
function DB.Save(layout)
    local editable,message=DB.Editable(); if not editable then return nil,message end
    local valid, err = NS.Model.Validate(layout)
    if not valid then return nil, err end
    DB.data.profiles[DB.CurrentName()] = valid
    NS.Emit("LAYOUT_CHANGED", valid)
    return true
end
function DB.Create(name, layout)
    local editable,message=DB.Editable(); if not editable then return nil,message end
    if not NS.Model.Name(name) or DB.data.profiles[name] then return nil, "Invalid or existing profile name" end
    local count=0; for _ in pairs(DB.data.profiles) do count=count+1 end
    if count>=32 then return nil, "Maximum 32 profiles" end
    local valid, err = NS.Model.Validate(layout or DB.Current())
    if not valid then return nil, err end
    valid.name=name; DB.data.profiles[name]=valid
    return DB.Select(name)
end
function DB.Select(name)
    local editable,message=DB.Editable(); if not editable then return nil,message end
    if not DB.data.profiles[name] then return nil, "Unknown profile" end
    if DB.character and DB.data.characters[DB.character] then DB.data.characters[DB.character]=name
    else DB.data.active=name end
    NS.Emit("LAYOUT_CHANGED", DB.Current())
    return true
end
function DB.SetCharacter(enabled)
    local editable,message=DB.Editable(); if not editable then return nil,message end
    if not DB.character then return nil, "No character identity available" end
    if enabled then DB.data.characters[DB.character]=DB.CurrentName()
    else DB.data.characters[DB.character]=nil end
    NS.Emit("LAYOUT_CHANGED", DB.Current())
    return true
end
function DB.Rename(name)
    local editable,message=DB.Editable(); if not editable then return nil,message end
    local old = DB.CurrentName()
    if old=="Default" then return nil, "Duplicate Default before renaming" end
    if not NS.Model.Name(name) or DB.data.profiles[name] then return nil, "Invalid or existing name" end
    DB.data.profiles[name]=DB.data.profiles[old]; DB.data.profiles[old]=nil
    DB.data.profiles[name].name=name
    if DB.data.active==old then DB.data.active=name end
    for character, current in pairs(DB.data.characters) do
        if current==old then DB.data.characters[character]=name end
    end
    NS.Emit("LAYOUT_CHANGED", DB.Current()); return true
end
function DB.Delete(name)
    local editable,message=DB.Editable(); if not editable then return nil,message end
    if name=="Default" then return nil,"Default cannot be deleted" end
    if not DB.data.profiles[name] then return nil,"Unknown profile" end
    DB.data.profiles[name]=nil
    if DB.data.active==name then DB.data.active="Default" end
    for character,current in pairs(DB.data.characters) do
        if current==name then DB.data.characters[character]="Default" end
    end
    NS.Emit("LAYOUT_CHANGED",DB.Current())
    return true
end
