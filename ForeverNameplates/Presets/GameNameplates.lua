local _,NS=...
local E=NS.Model.Element
local function rules()
    local result=NS.Rules.Defaults(); result.healthColor="reaction"
    result.friendlyColor={0,1,0,1}; result.neutralColor={1,1,0,1}; result.hostileColor={1,0,0,1}
    return result
end
-- Visual structure reconstructed from pinned FrameXML. These are not client-tested matches.
-- CVar scale=1 and hostile NPC; DF font variant targets <=1200px screen height.
local classic={version=2,name="WoW Classic — Nameplate 1.15.8",rules=rules(),elements={
    E("back","panel",0,0,103,10,{.2,.2,.2,.6375},{layer=1}),
    E("health","health",0,0,103,10,{1,0,0,1},{alpha=.75,asset="wow_nameplate_fill"}),
    E("name","text",8.5,16,160,12,{1,0,0,1},{source="name",fontSize=12,layer=7,asset="wow_classic_name"}),
    E("level","text",61.5,2,15,15,{1,1,0,1},{source="level",fontSize=10,layer=7,asset="wow_nameplate_level"}),
    E("artFrame","artwork",8.5,0,128,16,{1,1,1,1},{alpha=.75,layer=6,asset="wow_classic_nameplate_border"}),
    E("selected","artwork",0,0,103,10,{1,1,1,1},{source="target",alpha=.25,layer=5,asset="wow_nameplate_selection"}),
    E("raid","raid",-66.5,5,22,22,{1,1,1,1},{layer=8}),
}}
local dragonflight={version=2,name="WoW Dragonflight — Nameplate 10.2.7",rules=rules(),elements={
    E("back","panel",0,0,86,4,{.2,.2,.2,.6375},{layer=1}),
    E("health","health",0,0,86,4,{1,0,0,1},{alpha=.75,asset="wow_nameplate_fill"}),
    E("name","text",0,13,160,14,{1,1,1,1},{source="name",fontSize=14,layer=7,asset="wow_nameplate_name"}),
    E("border","panel",0,0,86,4,{0,0,0,1},{alpha=.75,layer=2,shape="outline"}),
    E("target","target",0,0,86,4,{1,1,1,.9},{alpha=.75,layer=4,shape="outline"}),
    E("selected","artwork",0,0,86,4,{1,1,1,1},{source="target",alpha=.25,layer=5,asset="wow_nameplate_selection"}),
    E("cast","cast",0,-8,86,8,{1,.7,0,1},{asset="wow_nameplate_fill"}),
    E("castText","text",0,-8,86,8,{1,1,1,1},{source="cast",fontSize=8,layer=7,asset="wow_nameplate_name"}),
    E("raid","raid",-69,0,22,22,{1,1,1,1},{layer=8}),
    E("castBack","artwork",0,-8,84,8,{1,1,1,1},{layer=2,asset="wow_df_cast_background"}),
}}
-- Measured JPEG coordinates, not inferred game UI units. Only the claimed-enemy appearance.
-- Font is a documented local fallback; FFXIV claim/spawn states are not WoW unit states.
local ffxiv={version=2,name="FFXIV — Claimed enemy reference draft",rules=NS.Rules.Defaults(),elements={
    E("back","panel",0,0,236,12,{72/255,25/255,28/255,1},{layer=1}),
    E("health","health",0,0,236,12,{1,1,1,1},{asset="ffxiv_hp_fill"}),
    E("artFrame","artwork",0,0,256,32,{1,1,1,1},{layer=6,asset="fantasy_frame"}),
    E("name","text",22,24,194,32,{1,.35,.36,1},{source="name",fontSize=32,layer=7,asset="ffxiv_name_label"}),
    E("level","text",-112,24,70,32,{1,.35,.36,1},{source="level",fontSize=30,layer=7,asset="ffxiv_level_label"}),
    E("enemyIcon","artwork",-168,24,32,32,{1,1,1,1},{layer=7,asset="ffxiv_enemy_icon"}),
}}
NS.GameNameplates={
    {id="wow_classic",game="World of Warcraft Classic",version="1.15.8",layout=classic,status="source_reconstruction"},
    {id="wow_dragonflight",game="World of Warcraft Dragonflight",version="10.2.7",layout=dragonflight,status="source_reconstruction"},
    {id="guildwars2",game="Guild Wars 2",status="reference_blocked"},
    {id="swtor",game="Star Wars: The Old Republic",status="reference_blocked"},
    {id="eso",game="The Elder Scrolls Online",status="reference_blocked"},
    {id="ffxiv",game="Final Fantasy XIV",status="reference_measured_assets_pending",layout=ffxiv,
        requires={"fantasy_frame","ffxiv_hp_fill","ffxiv_enemy_icon"},
        reference="https://na.finalfantasyxiv.com/uiguide/battle/battle-np/battle_np_bar.html"},
    {id="diablo4",game="Diablo IV",status="reference_blocked"},
}
