local _, NS = ...
local Model = {version = 2, maxElements = 64}
NS.Model = Model
Model.kinds = {health=true, cast=true, text=true, panel=true, target=true, ornament=true, artwork=true,raid=true,class=true}
Model.assets = {classic_frame=true,dragonflight_frame=true,guildwars_frame=true,galactic_frame=true,
    medieval_frame=true,fantasy_frame=true,minimal_frame=true,arena_frame=true,neon_frame=true,
    arcane_frame=true,horde_frame=true,celestial_frame=true,studio_header=true}
Model.sources = {name=true, health=true, level=true, cast=true, static=true,classification=true,class=true}
Model.shapes = {rect=true, diamond=true, rune=true, brackets=true, segments=true}
Model.fields = {id=true, kind=true, source=true, text=true, x=true, y=true, width=true,
    height=true, color=true, alpha=true, layer=true, enabled=true, locked=true,
    fontSize=true, vertical=true, reverse=true, shape=true,asset=true}

local function finite(value, low, high)
    return type(value) == "number" and value == value and value >= low and value <= high
end
function Model.Name(value)
    return type(value) == "string" and #value > 0 and #value <= 80 and not value:find("[%c|]")
end
local function keysOnly(value, allowed)
    if type(value) ~= "table" or getmetatable(value) then return false end
    for key in pairs(value) do if not allowed[key] then return false end end
    return true
end
function Model.Validate(layout)
    if not keysOnly(layout, {version=true, name=true, elements=true,rules=true}) then return nil, "Invalid layout fields" end
    if layout.version~=1 and layout.version~=2 then return nil,"Unsupported layout version" end
    local rules,ruleError=NS.Rules.Validate(layout.rules or (layout.version==1 and NS.Rules.Defaults()))
    if not rules then return nil,ruleError end
    if not Model.Name(layout.name) then return nil, "Invalid layout name" end
    if type(layout.elements) ~= "table" or getmetatable(layout.elements) then return nil, "Missing elements" end
    local count = 0
    for key in pairs(layout.elements) do
        if not finite(key, 1, Model.maxElements) or key % 1 ~= 0 then return nil, "Invalid element index" end
        count = count + 1
    end
    if count == 0 or count > Model.maxElements or count ~= #layout.elements then return nil, "Invalid element count" end
    local ids, result = {}, {version=2, name=layout.name, elements={},rules=rules}
    for _, e in ipairs(layout.elements) do
        if not keysOnly(e, Model.fields) then return nil, "Invalid element fields" end
        if type(e.id) ~= "string" or #e.id > 32 or not e.id:match("^[%w_%-]+$") or ids[e.id] then return nil, "Invalid or duplicate element ID" end
        ids[e.id] = true
        if not Model.kinds[e.kind] then return nil, "Unknown component" end
        for _, key in ipairs({"x", "y", "width", "height", "alpha", "layer", "fontSize"}) do
            local low, high = -512, 512
            if key == "width" or key == "height" then low, high = 1, 512 end
            if key == "alpha" then low, high = 0, 1 end
            if key == "layer" then low, high = 1, 20 end
            if key == "fontSize" then low, high = 6, 32 end
            if not finite(e[key], low, high) then return nil, "Invalid " .. key end
        end
        if e.layer % 1 ~= 0 then return nil, "Layer must be an integer" end
        for _, key in ipairs({"enabled", "locked", "vertical", "reverse"}) do
            if type(e[key]) ~= "boolean" then return nil, "Invalid " .. key end
        end
        if not Model.sources[e.source] or not Model.shapes[e.shape] then return nil, "Invalid source or shape" end
        if type(e.asset)~="string" or (e.asset~="" and not Model.assets[e.asset]) then return nil,"Unknown artwork asset" end
        if type(e.text) ~= "string" or #e.text > 80 or e.text:find("[%c|]") then return nil, "Invalid text" end
        if type(e.color) ~= "table" or getmetatable(e.color) then return nil, "Invalid color" end
        local n = 0
        for key in pairs(e.color) do
            if not finite(key, 1, 4) or key % 1 ~= 0 then return nil, "Invalid color key" end
            n = n + 1
        end
        if n ~= 4 then return nil, "Invalid color length" end
        for i=1,4 do if not finite(e.color[i], 0, 1) then return nil, "Invalid color channel" end end
        result.elements[#result.elements+1] = NS.Copy(e)
    end
    return result
end

function Model.Element(id, kind, x, y, width, height, color, extra)
    local e = {id=id, kind=kind, x=x, y=y, width=width, height=height, color=color,
        alpha=1, layer=3, enabled=true, locked=false, fontSize=11, vertical=false,
        reverse=false, shape="rect", source="static", text="",asset=""}
    for key, value in pairs(extra or {}) do e[key] = value end
    return e
end
