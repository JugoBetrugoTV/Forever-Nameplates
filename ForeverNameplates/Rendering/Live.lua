local _,NS=...
local C,R=NS.Compat,NS.Renderer
local Engine={units={},views={},pending={},retries={},reasons={},visuals={},restores={},hides={},stats={created=0,updates=0,skipped=0}}
NS.Engine=Engine

local function hide(view)
    if C.SafeFrame(view.root) and pcall(view.root.Hide,view.root) then Engine.hides[view]=nil
    else Engine.hides[view]=true end
    view.replaced=false
end
local function reason(unit,message)
    if Engine.reasons[unit]~=message then
        Engine.reasons[unit]=message; Engine.stats.skipped=Engine.stats.skipped+1
        Engine.lastReason=message; NS.Log(unit..": "..message)
    end
end
local function alpha(record,value)
    if not C.SafeFrame(record.frame) then return false end
    record.writing=true
    local ok=pcall(record.frame.SetAlpha,record.frame,value)
    record.writing=false
    return ok and C.Public(record.frame.GetAlpha,record.frame)==value
end
local function restore(view)
    local record=view.visual
    view.visual=nil; view.anchor=nil
    if not record or record.owner~=view then return end
    record.owner=nil
    if not alpha(record,record.originalAlpha) then Engine.restores[record]=true
    else Engine.restores[record]=nil end
end
local function fallback(view,message)
    hide(view); restore(view); reason(view.unit,message)
end
local function bound(view,record)
    return view.unit and Engine.units[view.unit]==view and view.visual==record and
        C.nameplates and C_NamePlate and C.Public(C_NamePlate.GetNamePlateForUnit,view.unit)==view.base and
        C.Field(view.base,"UnitFrame")==record.frame
end
local function present(view,record)
    if not C.SafeFrame(view.root) or not C.SafeFrame(record.frame) then return nil,"Custom presentation restricted" end
    local shown=C.Public(record.frame.IsShown,record.frame)
    if type(shown)~="boolean" then return nil,"Blizzard visibility unavailable" end
    local effect=view.effect or {visible=true,alpha=1}
    local ok=pcall(function()
        -- Public client fade and profile alpha both affect the sibling root.
        view.root:SetAlpha(effect.alpha*record.originalAlpha)
        view.root:SetShown(effect.visible and shown)
    end)
    if not ok then return nil,"Custom presentation refused" end
    return true
end
local function hookOwner(record)
    local owner=record.owner
    if not owner then return end
    if not bound(owner,record) then
        if Engine.units[owner.unit]==owner then Engine.Remove(owner.unit)
        else hide(owner); restore(owner); owner.unit=nil end
        return
    end
    return owner
end
function Engine.Remove(unit)
    if C.Secret(unit) or type(unit)~="string" then return end
    local view=Engine.units[unit]
    if view then hide(view); restore(view); view.unit=nil end
    Engine.units[unit]=nil; Engine.pending[unit]=nil; Engine.retries[unit]=nil; Engine.reasons[unit]=nil
end

local function getVisual(base)
    local safe,message=C.SafeFrame(base)
    if not safe then return nil,nil,message end
    local visual=C.Field(base,"UnitFrame")
    if not visual then return nil,nil,"Blizzard UnitFrame not ready" end
    safe,message=C.SafeFrame(visual)
    if not safe then return nil,nil,"Blizzard UnitFrame: "..message end
    local bar=C.Field(visual,"healthBar") or C.Field(C.Field(visual,"HealthBarsContainer"),"healthBar")
    if not bar then return nil,nil,"Blizzard healthBar not ready" end
    safe,message=C.SafeFrame(bar)
    if not safe then return nil,nil,"Blizzard healthBar: "..message end
    return visual,bar
end

local function getRecord(visual,view)
    local record=Engine.visuals[visual]
    if record and record.owner and record.owner~=view then
        -- Blizzard can pool UnitFrames independently of the public base frame.
        Engine.Remove(record.owner.unit)
    end
    if record and record.owner==view then return record end
    if record and Engine.restores[record] then
        -- Never capture our still-suppressed zero as Blizzard's original value
        -- after a refused restore. Finish that restore before taking ownership.
        if not alpha(record,record.originalAlpha) then return nil,"Blizzard restoration pending" end
        Engine.restores[record]=nil
    end
    local original=C.Public(visual.GetAlpha,visual)
    if type(original)~="number" or original~=original or original<0 or original>1 then return nil,"Blizzard alpha is unavailable" end
    if type(hooksecurefunc)~="function" then return nil,"Secure visual hooks unavailable" end
    if not record then record={frame=visual,hooks={}}; Engine.visuals[visual]=record end
    if not record.hooks.SetAlpha then
        local ok=pcall(hooksecurefunc,visual,"SetAlpha",function(_,requested)
            if record.writing or not record.owner then return end
            local owner=record.owner
            -- Keep Blizzard's latest public fade alpha for restoration. Never
            -- inspect or cache a secret alpha, and never replace its method.
            if C.Secret(requested) or type(requested)~="number" or requested~=requested or requested<0 or requested>1 then
                record.owner=nil; owner.visual=nil; owner.anchor=nil
                hide(owner); reason(owner.unit,"Blizzard alpha became restricted")
                return
            end
            -- A pooled frame may already belong to the next Blizzard unit.
            -- Its new public alpha must survive removal of the stale owner.
            record.originalAlpha=requested
            owner=hookOwner(record)
            if not owner then return end
            local visible,message=present(owner,record)
            if not visible then fallback(owner,message)
            elseif not alpha(record,0) then fallback(owner,"Blizzard alpha update refused") end
        end)
        if not ok then return nil,"Secure alpha hook refused" end
        record.hooks.SetAlpha=true
    end
    for _,method in ipairs({"Show","Hide","SetShown"}) do
        if not record.hooks[method] then
            local ok=pcall(hooksecurefunc,visual,method,function()
                local owner=hookOwner(record)
                if not owner then return end
                local visible,message=present(owner,record)
                if not visible then fallback(owner,message) end
            end)
            if not ok then return nil,"Secure visibility hook refused" end
            record.hooks[method]=true
        end
    end
    record.originalAlpha=original
    return record
end

local function retry(unit,attempt)
    if not C_Timer or type(C_Timer.After)~="function" or attempt>=3 then return end
    local ticket=Engine.retries[unit]
    if attempt==0 then
        if ticket then return end
        ticket={}; Engine.retries[unit]=ticket
    end
    C_Timer.After(.05,function()
        if Engine.retries[unit]==ticket then Engine.Add(unit,attempt+1) end
    end)
end

function Engine.Add(unit,attempt)
    if C.Secret(unit) or type(unit)~="string" then return end
    if not NS.DB.data or not NS.DB.data.live then return end
    if not C.expected or not C.nameplates then reason(unit,"Expected Interface 16001 and C_NamePlate"); return end
    local base=C.Public(C_NamePlate.GetNamePlateForUnit,unit)
    local previous=Engine.units[unit]
    if previous and previous.base~=base then Engine.Remove(unit) end
    if not base then Engine.Remove(unit); return end
    local safe,message=C.SafeFrame(base)
    if not safe then
        if Engine.units[unit] then Engine.Remove(unit) end
        Engine.pending[unit]=nil; Engine.retries[unit]=nil
        reason(unit,message)
        return
    end
    local view=Engine.views[base]
    -- Clear obsolete ownership before a combat deferral, not after it.
    if view and view.unit and view.unit~=unit then Engine.Remove(view.unit) end
    -- Existing pooled widgets may be reused in combat; creation/layout changes wait.
    if NS.InCombat() and (not view or view.applied~=NS.DB.Current()) then
        Engine.pending[unit]=true; reason(unit,"First attachment deferred until combat ends"); return
    end
    local visual,anchor,err=getVisual(base)
    if not visual then
        if Engine.units[unit] then Engine.Remove(unit) end
        reason(unit,err)
        if err=="Blizzard UnitFrame not ready" or err=="Blizzard healthBar not ready" then retry(unit,attempt or 0) end
        return
    end
    if not view then
        local ok,result=pcall(R.Create,base)
        if not ok then reason(unit,"Custom frame creation refused"); return end
        view=result; view.base=base; hide(view)
        Engine.views[base]=view; Engine.stats.created=Engine.stats.created+1
    end
    if not C.SafeFrame(view.root) then reason(unit,"Custom root restricted"); return end
    if view.visual and view.visual.frame~=visual then hide(view); restore(view) end
    view.unit=unit; Engine.units[unit]=view; Engine.pending[unit]=nil; Engine.retries[unit]=nil
    local record,recordError=getRecord(visual,view)
    if not record then fallback(view,recordError); return end
    local ok,applied=pcall(function()
        view.root:ClearAllPoints()
        -- The root is a sibling of UnitFrame, so hiding Blizzard does not hide it.
        -- Layout coordinates refer to the plate center, aligned to its healthbar.
        view.root:SetPoint("CENTER",anchor,"CENTER",0,0)
        view.root:SetFrameLevel(visual:GetFrameLevel()+1)
        if not NS.InCombat() then return R.Apply(view,NS.DB.Current()) end
        return true
    end)
    if not ok or not applied then fallback(view,"Custom layout application refused"); return end
    view.applied=NS.DB.Current(); view.visual=record; view.anchor=anchor
    Engine.Update(unit)
end

function Engine.Update(unit)
    if C.Secret(unit) or type(unit)~="string" then return end
    local view=Engine.units[unit]
    if not view then return end
    if not NS.DB.data.live then Engine.Remove(unit); return end
    local current=C.nameplates and C.Public(C_NamePlate.GetNamePlateForUnit,unit)
    if not current or current~=view.base then Engine.Remove(unit); if current then Engine.Add(unit) end; return end
    if not C.SafeFrame(view.root) then fallback(view,"Custom root restricted"); return end
    local visual,anchor=getVisual(view.base)
    if not visual or not view.visual or visual~=view.visual.frame or anchor~=view.anchor then
        Engine.Add(unit); return
    end
    local ok,ready=pcall(function() return R.Update(view,C.State(unit),unit) end)
    Engine.stats.updates=Engine.stats.updates+1
    if not ok or not ready then fallback(view,"Custom rendering unavailable; Blizzard restored"); return end
    -- Suppression starts only after a successful custom render. Hidden-by-rule is
    -- an intentional hidden plate, not a reason to resurrect Blizzard visuals.
    local record=view.visual
    local visible,message=present(view,record)
    if not visible then fallback(view,message); return end
    record.owner=view
    if not alpha(record,0) then fallback(view,"Blizzard visual suppression refused"); return end
    view.replaced=true; Engine.reasons[unit]=nil
end

function Engine.Refresh()
    if NS.InCombat() then Engine.dirty=true; return end
    Engine.dirty=false
    for view in pairs(Engine.hides) do hide(view) end
    for record in pairs(Engine.restores) do
        if not record.owner and alpha(record,record.originalAlpha) then Engine.restores[record]=nil end
    end
    -- Snapshot known bindings and pending tokens before Add/Remove mutate them.
    local known={}; for unit in pairs(Engine.units) do known[unit]=true end
    for unit in pairs(Engine.pending) do known[unit]=true end
    for unit in pairs(Engine.retries) do known[unit]=true end
    local seen={}
    for unit in pairs(known) do
        if NS.DB.data.live and C.expected and C.nameplates then Engine.Add(unit); seen[unit]=true else Engine.Remove(unit) end
    end
    if not NS.DB.data.live then Engine.pending={}; Engine.retries={}; Engine.reasons={}; return end
    if not C.expected or not C.nameplates then return end
    -- Public API discovery first, with a bounded token pass for clients lacking
    -- public unitToken fields. Never request includeForbidden or change hit tests.
    local plates=C_NamePlate and C.Public(C_NamePlate.GetNamePlates)
    if type(plates)=="table" then
        for _,base in ipairs(plates) do
            if C.SafeFrame(base) then
                local token=C.Field(base,"unitToken")
                local visual=C.Field(base,"UnitFrame")
                if not token and C.SafeFrame(visual) then token=C.Field(visual,"unit") end
                if type(token)=="string" and not seen[token] then Engine.Add(token); seen[token]=true end
            end
        end
    end
    for i=1,200 do
        local unit="nameplate"..i
        if not seen[unit] and C.Public(C_NamePlate.GetNamePlateForUnit,unit) then Engine.Add(unit) end
    end
end

function Engine.SetEnabled(enabled)
    local editable,message=NS.DB.Editable()
    if not editable then return nil,message end
    if enabled and (not C.expected or not C.nameplates) then return nil,"Expected Forever Interface 16001 and C_NamePlate" end
    NS.DB.data.live=enabled==true; Engine.Refresh()
    return true
end
function Engine.Status()
    local applied,pending,blocked,restoring,hiding=0,0,0,0,0
    local last
    for _,view in pairs(Engine.units) do if view.replaced then applied=applied+1 end end
    for _ in pairs(Engine.pending) do pending=pending+1 end
    for _,message in pairs(Engine.reasons) do blocked=blocked+1; last=message end
    for _ in pairs(Engine.restores) do restoring=restoring+1 end
    for _ in pairs(Engine.hides) do hiding=hiding+1 end
    if NS.DB.data and NS.DB.data.live and (not C.expected or not C.nameplates) then
        last="Expected Interface 16001 and C_NamePlate"; blocked=blocked+1
    end
    return "v"..NS.version.." / Interface "..tostring(C.interface).." / Live "..tostring(NS.DB.data and NS.DB.data.live)..
        " / Applied: "..applied.." / Pending: "..pending.." / Fallback: "..blocked.." / Restore pending: "..restoring.." / Hide pending: "..hiding..
        (blocked>0 and (" / Reason: "..last) or "")
end
NS.On("LAYOUT_CHANGED",Engine.Refresh)
