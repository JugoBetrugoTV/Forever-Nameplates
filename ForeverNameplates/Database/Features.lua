local _,NS=...
local F={}
NS.Features=F
F.points={CENTER={0,0},LEFT={-.5,0},RIGHT={.5,0},TOP={0,.5},BOTTOM={0,-.5},
    TOPLEFT={-.5,.5},TOPRIGHT={.5,.5},BOTTOMLEFT={-.5,-.5},BOTTOMRIGHT={.5,-.5}}
F.pointNames={"CENTER","LEFT","RIGHT","TOP","BOTTOM","TOPLEFT","TOPRIGHT","BOTTOMLEFT","BOTTOMRIGHT"}
local function keys(t,allowed)
    if type(t)~="table" or getmetatable(t) then return false end
    for key in pairs(t) do if not allowed[key] then return false end end
    return true
end
local function number(v,lo,hi,integer)
    return type(v)=="number" and v==v and v>=lo and v<=hi and (not integer or v%1==0)
end
function F.AuraDefaults()
    return {filter="HARMFUL",sort="Unsorted",direction="Normal",limit=8,columns=8,size=20,gap=2,
        own=false,cooldown=true,listMode="all",spells=""}
end
function F.CastDefaults()
    return {enabled=false,normal={1,.7,.2,1},channel={.3,.65,1,1},shield={.7,.7,.7,1},
        spark=false,sparkColor={1,1,1,1},sparkWidth=8,sparkAlpha=1}
end
function F.ValidateElement(e)
    if e.anchor~=nil then
        local a=e.anchor
        if not keys(a,{ref=true,point=true,relativePoint=true}) or type(a.ref)~="string" or
            not F.points[a.point] or not F.points[a.relativePoint] then return nil,"Invalid relative anchor" end
    end
    if e.aura~=nil then
        local a=e.aura
        if e.kind~="auras" or not keys(a,{filter=true,sort=true,direction=true,limit=true,columns=true,size=true,gap=true,
            own=true,cooldown=true,listMode=true,spells=true}) or
            (a.filter~="HARMFUL" and a.filter~="HELPFUL") or
            (a.sort~="Unsorted" and a.sort~="ExpirationOnly" and a.sort~="NameOnly") or
            (a.direction~="Normal" and a.direction~="Reverse") or not number(a.limit,1,12,true) or
            not number(a.columns,1,12,true) or not number(a.size,8,32,true) or not number(a.gap,0,8,true) or
            type(a.own)~="boolean" or type(a.cooldown)~="boolean" or
            (a.listMode~="all" and a.listMode~="include" and a.listMode~="exclude") or
            type(a.spells)~="string" or #a.spells>240 or a.spells:find("[^%d, ]") then return nil,"Invalid aura settings" end
        local count=0
        for id in a.spells:gmatch("[^, ]+") do
            if not number(tonumber(id),1,2147483647,true) then return nil,"Invalid aura spell ID" end
            count=count+1
        end
        if count>32 then return nil,"Maximum 32 aura spell IDs" end
    elseif e.kind=="auras" then return nil,"Missing aura settings" end
    if e.castStyle~=nil then
        local c=e.castStyle
        if e.kind~="cast" or not keys(c,{enabled=true,normal=true,channel=true,shield=true,spark=true,
            sparkColor=true,sparkWidth=true,sparkAlpha=true}) or type(c.enabled)~="boolean" or type(c.spark)~="boolean" or
            not number(c.sparkWidth,1,32,true) or not number(c.sparkAlpha,0,1) then return nil,"Invalid cast style" end
        for _,key in ipairs({"normal","channel","shield","sparkColor"}) do
            if not NS.Rules.ColorValid(c[key]) then return nil,"Invalid cast color" end
        end
    end
    return true
end
function F.Positions(layout)
    local byId,positions,visiting={},{},{}
    for _,e in ipairs(layout.elements) do byId[e.id]=e end
    local function resolve(e)
        if positions[e.id] then return positions[e.id] end
        if visiting[e.id] then return nil,"Anchor cycle" end
        visiting[e.id]=true
        local x,y=e.x,e.y
        if e.anchor then
            local ref=byId[e.anchor.ref]
            if not ref then return nil,"Anchor reference missing" end
            local p,err=resolve(ref); if not p then return nil,err end
            local own,relative=F.points[e.anchor.point],F.points[e.anchor.relativePoint]
            x=p.x+relative[1]*ref.width-own[1]*e.width+e.x
            y=p.y+relative[2]*ref.height-own[2]*e.height+e.y
        end
        visiting[e.id]=nil; positions[e.id]={x=x,y=y}; return positions[e.id]
    end
    for _,e in ipairs(layout.elements) do local p,err=resolve(e); if not p then return nil,err end end
    return positions
end
function F.AuraSize(a)
    local columns=math.min(a.limit,a.columns); local rows=math.ceil(a.limit/columns)
    return columns*a.size+(columns-1)*a.gap,rows*a.size+(rows-1)*a.gap
end
