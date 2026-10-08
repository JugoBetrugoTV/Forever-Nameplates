-- Explicit widget simulator: validates logic, not actual WoW restrictions or pixels.
Mock={frames={},plates={},units={},combat=false,cursorX=0,cursorY=0}
local F={}; F.__index=F
function F:SetSize(w,h) assert(type(w)=="number" and type(h)=="number"); self.width=w; self.height=h end
function F:SetWidth(w) self.width=w end
function F:SetHeight(h) self.height=h end
function F:GetWidth() return self.width or 1 end
function F:GetHeight() return self.height or 1 end
function F:SetPoint(...) self.point={...} end
function F:ClearAllPoints() self.point=nil end
function F:SetAllPoints(parent) self.allPoints=parent end
function F:SetAlpha(a) self.alpha=a end
function F:SetScale(s) self.scale=s end
function F:GetEffectiveScale() return (self.scale or 1)*(self.parent and self.parent:GetEffectiveScale() or 1) end
function F:SetFrameLevel(v) self.frameLevel=v end
function F:GetFrameLevel() return self.frameLevel or 1 end
function F:SetFrameStrata(s) self.strata=s end
function F:SetShown(v) if v then self:Show() else self:Hide() end end
function F:IsShown() return self.shown end
function F:Show() self.shown=true end
function F:Hide()
    local old=self.shown; self.shown=false
    if old and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function F:SetScript(event,callback) self.scripts[event]=callback end
function F:RegisterEvent(event) self.events[event]=true end
function F:UnregisterEvent(event) self.events[event]=nil end
function F:RegisterForDrag(...) self.dragButtons={...} end
function F:EnableMouse(v) self.mouse=v end
function F:SetEnabled(v) self.enabled=v end
function F:IsEnabled() return self.enabled end
function F:SetClipsChildren(v) self.clipsChildren=v end
function F:SetMovable(v) self.movable=v end
function F:StartMoving() self.moving=true end
function F:StopMovingOrSizing() self.moving=false end
function F:IsForbidden() return self.forbidden or false end
function F:IsProtected() return self.protected or (self.parent and self.parent:IsProtected()) or false end
function F:SetFont(path,size,flags) self.font={path,size,flags} end
function F:SetText(value) self.text=tostring(value or "") end
function F:GetText() return self.text or "" end
function F:SetTextColor(...) self.textColor={...} end
function F:SetJustifyH(value) self.justify=value end
function F:SetTextInsets(...) self.insets={...} end
function F:SetAutoFocus(v) self.autoFocus=v end
function F:SetMultiLine(v) self.multiLine=v end
function F:SetMaxLetters(v) self.maxLetters=v end
function F:SetFocus() self.focus=true end
function F:ClearFocus() self.focus=false end
function F:HighlightText() self.highlighted=true end
function F:SetScrollChild(child) self.scrollChild=child end
function F:SetTexture(path) self.texture=path end
function F:SetColorTexture(...) self.color={...} end
function F:SetVertexColor(...) self.vertexColor={...} end
function F:SetRotation(v) self.rotation=v end
function F:SetStatusBarTexture(path) self.statusTexture=path end
function F:SetStatusBarColor(...) self.statusColor={...} end
function F:SetMinMaxValues(low,high) self.min=low; self.max=high end
function F:SetValue(v) self.value=v end
function F:SetOrientation(v) assert(v=="VERTICAL" or v=="HORIZONTAL"); self.orientation=v end
function F:SetReverseFill(v) self.reverse=v end
function F:SetTimerDuration(d) self.duration=d end
local function make(kind,name,parent)
    local f=setmetatable({kind=kind,name=name,parent=parent,scripts={},events={},shown=true,enabled=true},F)
    Mock.frames[#Mock.frames+1]=f
    if name then _G[name]=f end
    return f
end
function F:CreateTexture(name,layer) return make("Texture",name,self) end
function F:CreateFontString(name,layer) return make("FontString",name,self) end
function CreateFrame(kind,name,parent,template) return make(kind,name,parent) end
UIParent=CreateFrame("Frame"); UIParent:SetSize(1920,1080)
STANDARD_TEXT_FONT="Fonts\\FRIZQT__.TTF"
UISpecialFrames={}; SlashCmdList={}
DEFAULT_CHAT_FRAME={messages={}}
function DEFAULT_CHAT_FRAME:AddMessage(m) table.insert(self.messages,m) end
function GetLocale() return "enUS" end
function GetBuildInfo() return "1.60.1","70170","",16001 end
function GetRealmName() return "TestRealm" end
function InCombatLockdown() return Mock.combat end
function GetCursorPosition() return Mock.cursorX,Mock.cursorY end
function issecretvalue(v) return type(v)=="table" and rawget(v,"secret")==true end
function issecrettable(v) return issecretvalue(v) end
function UnitName(unit) return Mock.units[unit] and Mock.units[unit].name or nil end
function UnitLevel(unit) return Mock.units[unit] and Mock.units[unit].level or nil end
function UnitHealth(unit) return Mock.units[unit] and Mock.units[unit].health or 0 end
function UnitHealthMax(unit) return Mock.units[unit] and Mock.units[unit].maximum or 100 end
function UnitIsUnit(unit,other) return unit==Mock.target end
function UnitCastingInfo(unit) return Mock.units[unit] and Mock.units[unit].castName end
function UnitChannelInfo(unit) return nil end
function UnitCastingDuration(unit) return Mock.units[unit] and Mock.units[unit].duration end
function UnitChannelDuration(unit) return nil end
C_NamePlate={}
function C_NamePlate.GetNamePlateForUnit(unit) return Mock.plates[unit] end
C_AddOns={IsAddOnLoaded=function() return false end}
Mock.units.player={name="Tester",level=60,health=100,maximum=100}
function Mock.Fire(frame,event,...)
    assert(frame.events[event],"Event is not registered: "..event)
    frame.scripts.OnEvent(frame,event,...)
end
function Mock.AddUnit(unit)
    Mock.units[unit]={name="Sentinel",level=60,health=70,maximum=100}
    Mock.plates[unit]=CreateFrame("Frame",nil,UIParent)
    return Mock.plates[unit]
end
function Mock.Secret()
    local function fail() error("Secret value was evaluated") end
    return setmetatable({secret=true},{__tostring=fail,__add=fail,__sub=fail,__mul=fail,__div=fail,__lt=fail,__le=fail})
end
