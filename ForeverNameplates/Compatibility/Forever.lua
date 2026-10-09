local _, NS = ...
local Compat = {failures=0}
NS.Compat = Compat
function Compat.Secret(value)
    if issecretvalue and issecretvalue(value) then return true end
    if issecrettable and type(value)=="table" and issecrettable(value) then return true end
    return false
end
function Compat.Public(fn, ...)
    if type(fn)~="function" then return nil end
    local ok,value=pcall(fn,...)
    if not ok or Compat.Secret(value) then return nil end
    return value
end
function Compat.Audit()
    if GetBuildInfo then
        local _,_,_,interface=GetBuildInfo()
        Compat.interface=interface
    end
    Compat.nameplates=type(C_NamePlate)=="table" and type(C_NamePlate.GetNamePlateForUnit)=="function"
    Compat.secrets=type(issecretvalue)=="function"
    Compat.expected=Compat.interface==16001
    Compat.events={}
    return Compat.nameplates
end
function Compat.SafeFrame(frame)
    if Compat.Secret(frame) or (type(frame)~="table" and type(frame)~="userdata") then return false,"missing frame" end
    local ok,forbidden=pcall(function() return frame:IsForbidden() end)
    if not ok or Compat.Secret(forbidden) then return false,"frame access restricted" end
    if forbidden~=false then return false,"forbidden frame" end
    local protected
    ok,protected=pcall(function() return frame:IsProtected() end)
    if not ok or Compat.Secret(protected) then return false,"frame access restricted" end
    if protected~=false then return false,"protected frame" end
    return true
end
function Compat.Field(object,key)
    if Compat.Secret(object) or (type(object)~="table" and type(object)~="userdata") then return nil end
    return Compat.Public(function() return object[key] end)
end
function Compat.GetPlate(unit)
    if not Compat.nameplates or Compat.Secret(unit) or type(unit)~="string" then return nil end
    local frame=Compat.Public(C_NamePlate.GetNamePlateForUnit,unit)
    if Compat.SafeFrame(frame) then return frame end
end
function Compat.Register(frame,event)
    local ok=pcall(frame.RegisterEvent,frame,event)
    Compat.events[event]=ok
    if not ok then NS.Log("Unsupported event: "..event) end
    return ok
end
function Compat.Health(bar,unit)
    if type(UnitHealth)~="function" or type(UnitHealthMax)~="function" then return false end
    -- Widget forwarding is the sanctioned path. Do not branch on, format,
    -- cache, compare or perform arithmetic on either returned value.
    local ok=pcall(function()
        bar:SetMinMaxValues(0,UnitHealthMax(unit))
        bar:SetValue(UnitHealth(unit))
    end)
    if not ok then Compat.failures=Compat.failures+1 end
    return ok
end
function Compat.LevelColor(level)
    if Compat.Secret(level) or type(level)~="number" or level~=level or level<=0 or level%1~=0 then return nil end
    local color=Compat.Public(GetCreatureDifficultyColor,level)
    local result={Compat.Field(color,"r"),Compat.Field(color,"g"),Compat.Field(color,"b")}
    for i=1,3 do
        local value=result[i]
        if type(value)~="number" or value~=value or value<0 or value>1 then return nil end
    end
    return result
end
function Compat.CastInfo(unit)
    -- Only public name/icon metadata is retained. Timing/interrupt fields are
    -- deliberately not inspected; durations still go straight to the widget.
    for i=1,2 do
        local fn
        if i==1 then fn=UnitCastingInfo else fn=UnitChannelInfo end
        if type(fn)=="function" then
            local ok,name,_,icon=pcall(fn,unit)
            if ok then
                if Compat.Secret(name) or type(name)~="string" then name="" end
                if Compat.Secret(icon) or type(icon)~="number" or icon~=icon or icon<=0 or icon%1~=0 then icon=nil end
                if name~="" or icon then return name,icon end
            end
        end
    end
    return ""
end
function Compat.State(unit,needs)
    local restricted=C_Secrets and Compat.Public(C_Secrets.ShouldUnitIdentityBeSecret,unit)==true
    local state={name="",level="",healthText="—",castName="",casting=false}
    if not restricted then
        local name=(not needs or needs.name) and Compat.Public(UnitName,unit)
        local level=(not needs or needs.level) and Compat.Public(UnitLevel,unit)
        local target=Compat.Public(UnitIsUnit,unit,"target")
        if type(name)=="string" then state.name=name end
        if type(level)=="number" then state.level=level end
        if type(target)=="boolean" then state.target=target end
    end
    if not restricted then
        local player=Compat.Public(UnitIsPlayer,unit)
        local controlled=Compat.Public(UnitPlayerControlled,unit)
        if type(player)=="boolean" then state.isPlayer=player end
        if type(controlled)=="boolean" then state.controlled=controlled end
        local class=Compat.Public(UnitClassBase,unit)
        if type(class)=="string" and NS.Rules.classColors[class] then state.class=class end
        local reaction=Compat.Public(UnitReaction,unit,"player")
        if type(reaction)=="number" and reaction>=1 and reaction<=8 and reaction%1==0 then state.reaction=reaction end
        local classification=Compat.Public(UnitClassification,unit)
        if classification=="normal" or classification=="elite" or classification=="rare" or classification=="rareelite" or classification=="worldboss" then state.classification=classification end
    end
    local raid=Compat.Public(GetRaidTargetIndex,unit)
    if type(raid)=="number" and raid>=1 and raid<=8 and raid%1==0 then state.raidMarker=raid end
    if type(state.level)~="number" then state.level="" elseif state.level==-1 then state.level="??" end
    if not needs or needs.health then
        local hp=Compat.Public(UnitHealth,unit)
        local maximum=Compat.Public(UnitHealthMax,unit)
        if type(hp)=="number" and type(maximum)=="number" and maximum>0 then
            state.healthText=string.format("%.0f%%",hp/maximum*100)
        end
    end
    if not needs or needs.cast then
        state.castName,state.castIcon=Compat.CastInfo(unit)
        state.casting=state.castName~="" or state.castIcon~=nil
    end
    return state
end
function Compat.Cast(bar,unit)
    -- Modern duration objects go directly into the timer widget; no timing maths.
    if not bar.SetTimerDuration then return false end
    local duration=Compat.Public(UnitCastingDuration,unit) or Compat.Public(UnitChannelDuration,unit)
    if not duration then return false end
    return pcall(bar.SetTimerDuration,bar,duration)
end
