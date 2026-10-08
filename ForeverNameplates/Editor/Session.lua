local _, NS = ...
local Session = {}
Session.__index=Session
NS.Session=Session
function Session.New(layout,onChange)
    local valid,err=NS.Model.Validate(layout)
    if not valid then return nil,err end
    return setmetatable({layout=valid,undo={},redo={},selected=valid.elements[1].id,snap=4,onChange=onChange},Session)
end
function Session:Element(id)
    for index,e in ipairs(self.layout.elements) do if e.id==(id or self.selected) then return e,index end end
end
function Session:Commit(layout)
    if NS.InCombat() then return nil,NS.L.combat end
    local valid,err=NS.Model.Validate(layout)
    if not valid then return nil,err end
    if self.onChange then
        local ok,message=self.onChange(valid)
        if not ok then return nil,message end
    end
    table.insert(self.undo,NS.Copy(self.layout)); if #self.undo>50 then table.remove(self.undo,1) end
    self.redo={}; self.layout=valid
    return true
end
function Session:Update(id,patch)
    local e,index=self:Element(id)
    if not e then return nil,"No element selected" end
    if e.locked and patch.locked~=false then return nil,"Element is locked" end
    local nextLayout=NS.Copy(self.layout)
    for key,value in pairs(patch) do nextLayout.elements[index][key]=NS.Copy(value) end
    return self:Commit(nextLayout)
end
function Session:Move(id,x,y)
    local snap=self.snap
    if snap>0 then x=math.floor(x/snap+.5)*snap; y=math.floor(y/snap+.5)*snap end
    return self:Update(id,{x=x,y=y})
end
function Session:Travel(from,to)
    if NS.InCombat() then return nil,NS.L.combat end
    if #from==0 then return false end
    local layout=from[#from]
    if self.onChange then local ok,err=self.onChange(layout); if not ok then return nil,err end end
    table.remove(from); to[#to+1]=NS.Copy(self.layout); self.layout=layout
    if not self:Element() then self.selected=layout.elements[1].id end
    return true
end
function Session:Undo() return self:Travel(self.undo,self.redo) end
function Session:Redo() return self:Travel(self.redo,self.undo) end
function Session:Copy() self.clipboard=NS.Copy(self:Element()); return self.clipboard~=nil end
function Session:Paste()
    if not self.clipboard then return nil,"Clipboard is empty" end
    local layout=NS.Copy(self.layout)
    local e=NS.Copy(self.clipboard)
    local used={}; for _,item in ipairs(layout.elements) do used[item.id]=true end
    local id=1; while used["copy"..id] do id=id+1 end
    e.id="copy"..id; e.x=math.min(512,e.x+8); e.y=math.min(512,e.y-8); e.locked=false
    table.insert(layout.elements,e)
    local ok,err=self:Commit(layout)
    if ok then self.selected=e.id end
    return ok,err
end
function Session:Delete()
    local e,index=self:Element()
    if not e or e.locked then return nil,"No editable selection" end
    local layout=NS.Copy(self.layout); table.remove(layout.elements,index)
    local ok,err=self:Commit(layout)
    if ok then self.selected=layout.elements[1].id end
    return ok,err
end
function Session:ResetElement()
    local current,index=self:Element()
    if not current then return nil,"No element selected" end
    for _,preset in ipairs(NS.Presets) do
        if preset.layout.name==self.layout.name then
            for _,e in ipairs(preset.layout.elements) do
                if e.id==current.id then local layout=NS.Copy(self.layout); layout.elements[index]=NS.Copy(e); return self:Commit(layout) end
            end
        end
    end
    return nil,"Element has no factory default; apply a preset to reset"
end
