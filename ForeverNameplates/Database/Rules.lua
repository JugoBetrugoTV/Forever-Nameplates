local _, NS = ...
local Rules = {}
NS.Rules = Rules
Rules.categories = {
    {id="friendlyPlayers",label="Friendly players"}, {id="enemyPlayers",label="Enemy players"},
    {id="friendlyNPCs",label="Friendly NPCs"}, {id="hostileNPCs",label="Hostile NPCs"},
    {id="neutralNPCs",label="Neutral NPCs"}, {id="pets",label="Pets / controlled minions"},
    {id="elite",label="Elite units"}, {id="rare",label="Rare units"}, {id="boss",label="Boss units"},
    {id="target",label="Current target"}, {id="nonTarget",label="Other units"}, {id="unknown",label="Unknown / restricted identity"},
}
Rules.categoryKeys={}
for _,category in ipairs(Rules.categories) do Rules.categoryKeys[category.id]=true end
Rules.colorModes={preset=true,class=true,reaction=true}
Rules.classColors={
    WARRIOR={.78,.61,.43,1}, PALADIN={.96,.55,.73,1}, HUNTER={.67,.83,.45,1},
    ROGUE={1,.96,.41,1}, PRIEST={1,1,1,1}, SHAMAN={0,.44,.87,1}, MAGE={.25,.78,.92,1},
    WARLOCK={.53,.53,.93,1}, DRUID={1,.49,.04,1}, DEATHKNIGHT={.77,.12,.23,1},
    MONK={0,1,.6,1}, DEMONHUNTER={.64,.19,.79,1}, EVOKER={.2,.58,.5,1},
}
Rules.classLabels={WARRIOR="WAR",PALADIN="PAL",HUNTER="HUN",ROGUE="ROG",PRIEST="PRI",SHAMAN="SHA",MAGE="MAG",
    WARLOCK="WLK",DRUID="DRU",DEATHKNIGHT="DK",MONK="MNK",DEMONHUNTER="DH",EVOKER="EVO"}
local function finite(v,low,high) return type(v)=="number" and v==v and v>=low and v<=high end
local function keys(value,allowed)
    if type(value)~="table" or getmetatable(value) then return false end
    for k in pairs(value) do if not allowed[k] then return false end end
    return true
end
function Rules.ColorValid(color)
    if not keys(color,{[1]=true,[2]=true,[3]=true,[4]=true}) then return false end
    for i=1,4 do if not finite(color[i],0,1) then return false end end
    return true
end
function Rules.Defaults()
    local config={healthColor="preset",friendlyColor={.24,.76,.39,1},hostileColor={.88,.22,.18,1},
        neutralColor={.95,.75,.24,1},overrides={}}
    for _,category in ipairs(Rules.categories) do
        config.overrides[category.id]={enabled=false,visible=true,alpha=1,scale=1,colorMode="inherit",color={1,1,1,1}}
    end
    return config
end
function Rules.Validate(config)
    if not keys(config,{healthColor=true,friendlyColor=true,hostileColor=true,neutralColor=true,overrides=true}) then return nil,"Invalid unit rule fields" end
    if not Rules.colorModes[config.healthColor] then return nil,"Invalid health color mode" end
    for _,key in ipairs({"friendlyColor","hostileColor","neutralColor"}) do
        if not Rules.ColorValid(config[key]) then return nil,"Invalid reaction color" end
    end
    if not keys(config.overrides,Rules.categoryKeys) then return nil,"Invalid rule categories" end
    for _,category in ipairs(Rules.categories) do
        local rule=config.overrides[category.id]
        if not keys(rule,{enabled=true,visible=true,alpha=true,scale=true,colorMode=true,color=true}) then return nil,"Invalid category rule" end
        if type(rule.enabled)~="boolean" or type(rule.visible)~="boolean" or not finite(rule.alpha,0,1) or not finite(rule.scale,.5,2) then return nil,"Invalid category appearance" end
        if rule.colorMode~="inherit" and rule.colorMode~="fixed" and not Rules.colorModes[rule.colorMode] then return nil,"Invalid category color mode" end
        if not Rules.ColorValid(rule.color) then return nil,"Invalid category color" end
    end
    return NS.Copy(config)
end
function Rules.Category(state)
    if state.isPlayer==false and state.controlled==true then return "pets" end
    if state.isPlayer==false and state.controlled~=false then return "unknown" end
    local reaction=state.reaction
    if type(reaction)~="number" or type(state.isPlayer)~="boolean" then return "unknown" end
    if state.isPlayer then return reaction>=5 and "friendlyPlayers" or "enemyPlayers" end
    if reaction>=5 then return "friendlyNPCs" elseif reaction==4 then return "neutralNPCs" end
    return "hostileNPCs"
end
function Rules.Resolve(config,state)
    local appearance={visible=true,alpha=1,scale=1,colorMode=config.healthColor,category=Rules.Category(state)}
    local function apply(id)
        local rule=config.overrides[id]
        if rule and rule.enabled then
            appearance.visible=rule.visible; appearance.alpha=rule.alpha; appearance.scale=rule.scale
            if rule.colorMode~="inherit" then appearance.colorMode=rule.colorMode; appearance.color=rule.color end
        end
    end
    -- Explicit precedence: primary category -> classification -> target state.
    apply(appearance.category)
    if state.classification=="elite" or state.classification=="rareelite" then apply("elite") end
    if state.classification=="rare" or state.classification=="rareelite" then apply("rare") end
    if state.classification=="worldboss" then apply("boss") end
    if state.target==true then apply("target") elseif state.target==false then apply("nonTarget") end
    return appearance
end
function Rules.HealthColor(config,appearance,state,fallback)
    local mode=appearance.colorMode
    if mode=="fixed" then return appearance.color end
    if mode=="class" and state.isPlayer==true then return Rules.classColors[state.class] or fallback end
    if mode=="reaction" and type(state.reaction)=="number" then
        if state.reaction>=5 then return config.friendlyColor elseif state.reaction==4 then return config.neutralColor end
        return config.hostileColor
    end
    return fallback
end
