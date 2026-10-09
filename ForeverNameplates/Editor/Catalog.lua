local _, NS = ...
local Catalog = {}
NS.Catalog = Catalog
Catalog.entries = {
    {id="health", label="Health bar"}, {id="cast", label="Cast bar"},
    {id="text", label="Text"}, {id="panel", label="Background panel"},
    {id="target", label="Target brackets"}, {id="ornament", label="Decoration"},
    {id="artwork", label="Imported artwork"}, {id="raid",label="Raid marker"}, {id="class",label="Class badge"},
    {id="classIcon",label="Class icon"}, {id="castIcon",label="Cast icon"},
    {id="castShield",label="Interrupt shield"},
    {id="auras",label="Aura / debuff icons"},
}
function Catalog.Assets(kind)
    local assets={}
    local bars=kind=="health" or kind=="cast"
    for id in pairs(NS.Media.files) do
        if NS.Model.assets[id] and (NS.ImportKinds[id]=="fill")==bars then assets[#assets+1]=id end
    end
    table.sort(assets)
    return assets
end
function Catalog.GameReady(entry)
    if not entry or not entry.layout then return false end
    for _,asset in ipairs(entry.requires or {}) do if not NS.Media.files[asset] then return false end end
    return true
end
function Catalog.AssetSize(asset)
    local size=NS.ImportSizes[asset]
    if size then return size[1],size[2] end
    for _,preset in ipairs(NS.Presets) do
        for _,element in ipairs(preset.layout.elements) do
            if element.kind=="artwork" and element.asset==asset then return element.width,element.height end
        end
    end
    if asset=="studio_header" then return 512,64 end
end
function Catalog.Create(kind,id)
    if not NS.Model.kinds[kind] then return nil,"Unknown component" end
    local width,height,color,extra=160,12,{.75,.58,.3,1},{}
    if kind=="auras" then extra.aura=NS.Features.AuraDefaults(); width,height=NS.Features.AuraSize(extra.aura); extra.y=28; extra.layer=8; color={1,1,1,1}
    elseif kind=="raid" then width=24; height=24; color={1,1,1,1}; extra.layer=8
    elseif kind=="castShield" then
        width=10; height=12; color={1,1,1,1}; extra.layer=9; extra.source="cast"; extra.x=-54; extra.y=-9
    elseif kind=="classIcon" or kind=="castIcon" then
        width=20; height=20; color={1,1,1,1}; extra.layer=8
        extra.source=kind=="classIcon" and "class" or "cast"
        extra.x=-100; extra.y=kind=="castIcon" and -16 or 0
    elseif kind=="class" then width=32; height=18; extra.source="class"; extra.layer=8
    elseif kind=="cast" then height=6; extra.source="cast"
    elseif kind=="text" then height=20; color={.92,.9,.81,1}; extra.text="Custom text"; extra.layer=7
    elseif kind=="panel" then height=22; color={.035,.043,.06,1}; extra.layer=1
    elseif kind=="target" then height=24; extra.shape="brackets"; extra.layer=2
    elseif kind=="ornament" then width=16; height=16; extra.shape="diamond"; extra.layer=5
    elseif kind=="artwork" then
        local asset=Catalog.Assets()[1]
        if not asset then return nil,"Import artwork through ArtDrop before adding an artwork component" end
        width,height=Catalog.AssetSize(asset); color={1,1,1,1}; extra.asset=asset; extra.layer=6
    end
    return NS.Model.Element(id,kind,0,0,width,height,color,extra)
end
