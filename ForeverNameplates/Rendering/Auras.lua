local _,NS=...
local C=NS.Compat
local A={}
NS.Auras=A
local function integer(v,low,high)
    return type(v)=="number" and v==v and v>=low and v<=high and v%1==0
end
function A.Read(unit,config)
    local fn=C_UnitAuras and C_UnitAuras.GetUnitAuras
    if type(fn)~="function" then C.auraReason="Aura API unavailable"; return {} end
    local rule=C.Field(C.Field(Enum,"UnitAuraSortRule"),config.sort)
    local direction=C.Field(C.Field(Enum,"UnitAuraSortDirection"),config.direction)
    if not integer(rule,0,2147483647) or not integer(direction,0,2147483647) then
        if config.sort~="Unsorted" or config.direction~="Normal" then
            C.auraReason="Requested aura sort enums unavailable"; return {}
        end
        rule,direction=nil,nil -- documented defaults; prefer public enums when present
    end
    local filter=config.filter..(config.own and "|PLAYER" or "")
    -- Filtering/sorting is delegated to the client. No expiration-time or owner arithmetic.
    local list=C.Public(fn,unit,filter,40,rule,direction)
    if type(list)~="table" then C.auraReason="Aura query restricted or unavailable"; return {} end
    local result,spells={},{}
    for id in config.spells:gmatch("%d+") do spells[tonumber(id)]=true end
    for i=1,40 do
        local data=C.Field(list,i)
        local icon=C.Field(data,"icon"); local id=C.Field(data,"auraInstanceID"); local spell=C.Field(data,"spellId")
        local allowed=config.listMode=="all" or (integer(spell,1,2147483647) and
            ((config.listMode=="include" and spells[spell]==true) or (config.listMode=="exclude" and not spells[spell])))
        if integer(icon,1,2147483647) and allowed then
            local count=C.Field(data,"applications")
            result[#result+1]={icon=icon,id=integer(id,1,2147483647) and id or nil,
                count=integer(count,2,999) and count or nil}
            if #result>=config.limit then break end
        end
    end
    C.auraReason=nil
    return result
end
NS.Renderer.Register("auras",function(parent)
    local root=CreateFrame("Frame",nil,parent); local slots={}
    -- Allocate bounded slots out of combat during layout construction.
    for i=1,12 do
        local f=CreateFrame("Frame",nil,root)
        local icon=f:CreateTexture(nil,"ARTWORK"); icon:SetAllPoints(f)
        local cooldown=CreateFrame("Cooldown",nil,f); cooldown:SetAllPoints(f); cooldown:EnableMouse(false)
        cooldown:SetDrawEdge(false); cooldown:SetDrawSwipe(true)
        local count=f:CreateFontString(nil,"OVERLAY"); count:SetPoint("BOTTOMRIGHT",0,0)
        count:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",10,"OUTLINE")
        f:Hide(); slots[i]={frame=f,icon=icon,cooldown=cooldown,count=count}
    end
    return {frame=root,auraSlots=slots}
end)
function A.Layout(part,e)
    for i,slot in ipairs(part.auraSlots) do
        slot.frame:Hide(); slot.cooldown:Hide(); slot.count:SetText("")
        slot.frame:SetSize(e.aura.size,e.aura.size); slot.frame:ClearAllPoints()
        local columns=math.min(e.aura.columns,e.aura.limit)
        slot.frame:SetPoint("TOPLEFT",part.frame,"TOPLEFT",((i-1)%columns)*(e.aura.size+e.aura.gap),
            -math.floor((i-1)/columns)*(e.aura.size+e.aura.gap))
        pcall(slot.icon.SetTexture,slot.icon,nil); slot.icon:SetTexCoord(0,1,0,1); slot.icon:SetVertexColor(unpack(e.color))
        if slot.cooldown.Clear then pcall(slot.cooldown.Clear,slot.cooldown) end
    end
end
function A.Update(part,e,state,unit)
    local values=unit and A.Read(unit,e.aura) or A.Preview(state.auras or {},e.aura)
    local any=false
    for i,slot in ipairs(part.auraSlots) do
        slot.frame:Hide(); slot.cooldown:Hide(); slot.count:SetText("")
        if slot.cooldown.Clear then pcall(slot.cooldown.Clear,slot.cooldown) end
        local value=i<=e.aura.limit and values[i]
        if value then
            local ok,result=pcall(slot.icon.SetTexture,slot.icon,value.icon)
            if ok and not C.Secret(result) and result==true then
                slot.frame:Show(); any=true
                if value.count then slot.count:SetText(tostring(value.count)) end
                if unit and e.aura.cooldown and value.id and C_UnitAuras and type(C_UnitAuras.GetAuraDuration)=="function" and
                    slot.cooldown.SetCooldownFromDurationObject then
                    -- Forward the duration directly; never read/cache its time fields.
                    local set=pcall(function() slot.cooldown:SetCooldownFromDurationObject(C_UnitAuras.GetAuraDuration(unit,value.id),true) end)
                    slot.cooldown:SetShown(set)
                end
            end
        end
    end
    return any
end
function A.Preview(samples,config)
    local values,spells={},{}
    for id in config.spells:gmatch("%d+") do spells[tonumber(id)]=true end
    -- Only explicit sandbox samples enter this path; never use live aura timing here.
    for _,sample in ipairs(samples) do
        if sample.filter==config.filter and (not config.own or sample.own==true) and
            (config.listMode=="all" or (config.listMode=="include" and spells[sample.spell]) or
            (config.listMode=="exclude" and not spells[sample.spell])) then
            values[#values+1]={icon=sample.icon,count=sample.count,name=sample.name,expiration=sample.expiration,index=#values+1}
        end
    end
    if config.sort~="Unsorted" then
        table.sort(values,function(a,b)
            local x,y=config.sort=="NameOnly" and a.name or a.expiration,config.sort=="NameOnly" and b.name or b.expiration
            if x==y then return a.index<b.index end
            if config.direction=="Reverse" then return x>y end
            return x<y
        end)
    elseif config.direction=="Reverse" then
        local reversed={}; for i=#values,1,-1 do reversed[#reversed+1]=values[i] end; values=reversed
    end
    return values
end
