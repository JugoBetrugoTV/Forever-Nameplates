local _, NS = ...
local DB = {}
NS.DB = DB
function DB.Initialize(saved)
    if type(saved) == "table" and type(saved.version) == "number" and saved.version > 1 then
        NS.databaseBlocked = true
        return nil, "Newer SavedVariables version; data preserved."
    end
    local data = {version=1, profiles={}, characters={}, active="Default", live=false}
    -- Explicit v0 migration: one declarative layout, no executable values.
    if type(saved) == "table" and saved.version == 0 then
        local migrated = NS.Model.Validate(saved.layout)
        if migrated then data.profiles.Default = migrated end
    elseif type(saved) == "table" and saved.version == 1 then
        local n = 0
        if type(saved.profiles) == "table" then
            for name, layout in pairs(saved.profiles) do
                local valid = NS.Model.Name(name) and NS.Model.Validate(layout)
                if valid and n < 32 then data.profiles[name]=valid; n=n+1 end
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
        data.live = saved.live == true
    end
    data.profiles.Default = data.profiles.Default or NS.Copy(NS.Presets[1].layout)
    DB.data = data
    return data
end
function DB.CurrentName()
    return DB.character and DB.data.characters[DB.character] or DB.data.active
end
function DB.Current() return DB.data.profiles[DB.CurrentName()] end
function DB.Save(layout)
    if NS.databaseBlocked then return nil, "Database is read-only" end
    local valid, err = NS.Model.Validate(layout)
    if not valid then return nil, err end
    DB.data.profiles[DB.CurrentName()] = valid
    NS.Emit("LAYOUT_CHANGED", valid)
    return true
end
function DB.Create(name, layout)
    if not NS.Model.Name(name) or DB.data.profiles[name] then return nil, "Invalid or existing profile name" end
    local count=0; for _ in pairs(DB.data.profiles) do count=count+1 end
    if count>=32 then return nil, "Maximum 32 profiles" end
    local valid, err = NS.Model.Validate(layout or DB.Current())
    if not valid then return nil, err end
    valid.name=name; DB.data.profiles[name]=valid
    return DB.Select(name)
end
function DB.Select(name)
    if not DB.data.profiles[name] then return nil, "Unknown profile" end
    if DB.character and DB.data.characters[DB.character] then DB.data.characters[DB.character]=name
    else DB.data.active=name end
    NS.Emit("LAYOUT_CHANGED", DB.Current())
    return true
end
function DB.SetCharacter(enabled)
    if not DB.character then return nil, "No character identity available" end
    if enabled then DB.data.characters[DB.character]=DB.CurrentName()
    else DB.data.characters[DB.character]=nil end
    NS.Emit("LAYOUT_CHANGED", DB.Current())
    return true
end
function DB.Rename(name)
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
