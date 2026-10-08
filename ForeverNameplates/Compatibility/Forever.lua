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
    if Compat.Secret(frame) or not frame then return false end
    if frame.IsForbidden and frame:IsForbidden() then return false end
    if frame.IsProtected and frame:IsProtected() then return false end
    return true
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
function Compat.State(unit)
    local name=Compat.Public(UnitName,unit)
    local level=Compat.Public(UnitLevel,unit)
    local target=Compat.Public(UnitIsUnit,unit,"target")
    local state={name=name or "",level=level or "",healthText="—",target=target==true,castName="",casting=false}
    local hp=Compat.Public(UnitHealth,unit)
    local maximum=Compat.Public(UnitHealthMax,unit)
    if type(hp)=="number" and type(maximum)=="number" and maximum>0 then
        state.healthText=string.format("%.0f%%",hp/maximum*100)
    end
    state.castName=Compat.Public(UnitCastingInfo,unit) or Compat.Public(UnitChannelInfo,unit) or ""
    state.casting=state.castName~=""
    return state
end
function Compat.Cast(bar,unit)
    -- Modern duration objects go directly into the timer widget; no timing maths.
    if not bar.SetTimerDuration then return false end
    local duration=Compat.Public(UnitCastingDuration,unit) or Compat.Public(UnitChannelDuration,unit)
    if not duration then return false end
    return pcall(bar.SetTimerDuration,bar,duration)
end
