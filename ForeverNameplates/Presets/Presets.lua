local _, NS = ...
local E = NS.Model.Element
local ink, paper = {.035,.043,.06,1}, {.92,.9,.81,1}
local specs = {
    {"Classic Azeroth", "Bronze / stone / winged frame", { .7,.42,.16,1}, 180,14,"wings"},
    {"Dragonflight Modern", "Wide edge rail / compact cast", {.18,.68,.8,1}, 192,9,"rails"},
    {"Guild Wars Inspired", "Asymmetric branches / organic silhouette", {.4,.72,.38,1}, 174,12,"branches"},
    {"Galactic Interface", "Reticle / technical readout", {.15,.78,.92,1}, 176,8,"reticle"},
    {"Dark Medieval", "Heavy iron / pointed crest", {.62,.18,.21,1}, 158,18,"crest"},
    {"High Fantasy", "Gold / crystal endcaps", {.87,.65,.28,1}, 182,12,"crystals"},
    {"Minimal Competitive", "Thin rule / clear numbers", {.78,.82,.87,1}, 168,5,"minimal"},
    {"PvP Arena", "Bold bracket / tall health column", {.92,.26,.19,1}, 22,64,"vertical"},
    {"Neon Cyber", "Offset rails / segmented display", {.61,.25,.92,1}, 194,8,"segments"},
    {"Arcane Mage", "Floating runes / central crest", {.42,.46,.98,1}, 172,10,"runes"},
    {"Brutal Horde", "Jagged war fins / heavy core", {.8,.18,.12,1}, 156,20,"fins"},
    {"Celestial", "Fine orbit / hanging constellation", {.45,.7,.9,1}, 182,6,"orbit"},
}
NS.Presets = {}
local assets={"classic","dragonflight","guildwars","galactic","medieval","fantasy","minimal","arena","neon","arcane","horde","celestial"}
for index, spec in ipairs(specs) do
    local name, description, color, width, height, silhouette = unpack(spec)
    local vertical = silhouette == "vertical"
    local layout = {version=1, name=name, elements={
        E("back", "panel",0,0,width+4,height+4,ink,{layer=1}),
        E("health", "health",0,0,width,height,color,{vertical=vertical}),
        E("name", "text",0,height/2+14,210,18,paper,{source="name",layer=7,fontSize=12}),
        E("value", "text",vertical and 54 or 0,0,vertical and 78 or width,16,paper,{source="health",layer=8}),
        E("cast", "cast",0,-height/2-13,vertical and 120 or width-16,4,{.85,.65,.32,1}),
        E("castText", "text",0,-height/2-25,160,14,paper,{source="cast",fontSize=9,layer=7}),
        E("target", "target",0,0,width+14,height+12,{1,.86,.53,1},{layer=2,shape="brackets"}),
    }}
    local function art(id,x,y,w,h,shape)
        table.insert(layout.elements,E(id,"ornament",x,y,w,h,color,{shape=shape,layer=5}))
    end
    if silhouette == "wings" then
        art("leftWing",-width/2-9,0,14,24,"diamond"); art("rightWing",width/2+9,0,14,24,"diamond")
        art("topRail",0,height/2+2,width,2,"rect")
    elseif silhouette == "rails" then
        art("upperRail",-8,height/2+4,width-16,1,"rect"); art("lowerRail",8,-height/2-4,width-16,1,"rect")
    elseif silhouette == "branches" then
        art("branchLeft",-width/2-7,4,18,5,"rune"); art("branchRight",width/2+3,-3,8,20,"diamond")
        art("leaf",-width/2+8,12,8,8,"diamond")
    elseif silhouette == "reticle" then
        art("reticleLeft",-width/2-6,0,9,24,"brackets"); art("reticleRight",width/2+6,0,9,24,"brackets")
        art("telemetry",50,-20,50,2,"segments")
    elseif silhouette == "crest" then
        art("crest",0,height/2+5,18,12,"diamond"); art("ironLeft",-width/2,0,5,30,"rect"); art("ironRight",width/2,0,5,30,"rect")
    elseif silhouette == "crystals" then
        art("crystalLeft",-width/2-5,0,12,22,"diamond"); art("crystalRight",width/2+5,0,12,22,"diamond")
    elseif silhouette == "minimal" then art("underline",0,-6,width,1,"rect")
    elseif silhouette == "vertical" then art("arenaBadge",0,43,18,12,"diamond")
    elseif silhouette == "segments" then
        art("segments",0,0,width,height,"segments"); art("offsetRail",-12,9,width-8,1,"rect")
    elseif silhouette == "runes" then
        for i=1,5 do art("rune"..i,(i-3)*24,-10,6,6,"rune") end
    elseif silhouette == "fins" then
        art("finLeft",-width/2-5,5,12,30,"diamond"); art("finRight",width/2+5,-5,12,30,"diamond")
    elseif silhouette == "orbit" then
        art("orbitLeft",-width/2-6,0,6,6,"diamond"); art("orbitRight",width/2+6,0,6,6,"diamond")
        for i=1,3 do art("star"..i,(i-2)*28,-14-math.abs(i-2)*4,3,3,"diamond") end
    end
    layout.elements[#layout.elements+1]=E("artFrame","artwork",0,0,256,vertical and 128 or 64,{1,1,1,1},
        {layer=6,asset=assets[index].."_frame"})
    NS.Presets[index] = {id="preset"..index, description=description, layout=layout}
end
