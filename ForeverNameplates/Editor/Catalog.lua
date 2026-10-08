local _, NS = ...
local Catalog = {}
NS.Catalog = Catalog
Catalog.entries = {
    {id="health", label="Health bar"}, {id="cast", label="Cast bar"},
    {id="text", label="Text"}, {id="panel", label="Background panel"},
    {id="target", label="Target brackets"}, {id="ornament", label="Decoration"},
    {id="artwork", label="Imported artwork"}, {id="raid",label="Raid marker"}, {id="class",label="Class badge"},
}
function Catalog.Assets()
    local assets={}
    for id in pairs(NS.Media.files) do if NS.Model.assets[id] then assets[#assets+1]=id end end
    table.sort(assets)
    return assets
end
function Catalog.Create(kind,id)
    if not NS.Model.kinds[kind] then return nil,"Unknown component" end
    local width,height,color,extra=160,12,{.75,.58,.3,1},{}
    if kind=="raid" then width=24; height=24; color={1,1,1,1}; extra.layer=8
    elseif kind=="class" then width=32; height=18; extra.source="class"; extra.layer=8
    elseif kind=="cast" then height=6; extra.source="cast"
    elseif kind=="text" then height=20; color={.92,.9,.81,1}; extra.text="Custom text"; extra.layer=7
    elseif kind=="panel" then height=22; color={.035,.043,.06,1}; extra.layer=1
    elseif kind=="target" then height=24; extra.shape="brackets"; extra.layer=2
    elseif kind=="ornament" then width=16; height=16; extra.shape="diamond"; extra.layer=5
    elseif kind=="artwork" then
        local asset=Catalog.Assets()[1]
        if not asset then return nil,"Import artwork through ArtDrop before adding an artwork component" end
        width,height=256,64; color={1,1,1,1}; extra.asset=asset; extra.layer=6
    end
    return NS.Model.Element(id,kind,0,0,width,height,color,extra)
end
