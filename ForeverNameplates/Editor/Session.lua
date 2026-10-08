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
    if not self:Element() then self.selected=valid.elements[1].id end
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
function Session:UpdateRules(patch,category)
    local layout=NS.Copy(self.layout)
    local target=layout.rules
    if category then
        target=layout.rules.overrides[category]
        if not target then return nil,"Unknown rule category" end
    end
    for key,value in pairs(patch) do target[key]=NS.Copy(value) end
    return self:Commit(layout)
end
function Session:Move(id,x,y)
    local snap=self.snap
    if snap>0 then x=math.floor(x/snap+.5)*snap; y=math.floor(y/snap+.5)*snap end
    return self:Update(id,{x=x,y=y})
end
function Session:Add(kind)
    if type(kind)~="string" or not NS.Model.kinds[kind] then return nil,"Unknown component" end
    if #self.layout.elements>=NS.Model.maxElements then return nil,"Maximum 64 elements" end
    local used={}; for _,e in ipairs(self.layout.elements) do used[e.id]=true end
    local index=1; while used[kind..index] do index=index+1 end
    local element,err=NS.Catalog.Create(kind,kind..index)
    if not element then return nil,err end
    local layout=NS.Copy(self.layout); layout.elements[#layout.elements+1]=element
    local ok,message=self:Commit(layout)
    if ok then self.selected=element.id end
    return ok,message
end
function Session:UseFrameArtwork()
    local frameElement,index=self:Element("artFrame")
    if not frameElement or frameElement.kind~="artwork" then return nil,"This layout has no preset artFrame" end
    if not NS.Media.files[frameElement.asset] then return nil,"Import the matching frame artwork first" end
    if frameElement.locked then return nil,"Frame artwork is locked" end
    local placeholderIds={}
    for _,preset in ipairs(NS.Presets) do
        for _,element in ipairs(preset.layout.elements) do
            if element.kind=="ornament" then placeholderIds[element.id]=true end
        end
    end
    local layout=NS.Copy(self.layout)
    for _,element in ipairs(layout.elements) do
        if element.kind=="ornament" and placeholderIds[element.id] and element.enabled then
            if element.locked then return nil,"Unlock preset decorations before replacing them" end
            element.enabled=false
        end
    end
    local artwork=layout.elements[index]
    artwork.enabled=true; artwork.color={1,1,1,1}
    local width,height=NS.Catalog.AssetSize(artwork.asset)
    if width then artwork.width=width; artwork.height=height end
    return self:Commit(layout)
end
function Session:Resize(id,width,height,keepTopLeft)
    local e=self:Element(id)
    if not e then return nil,"No element selected" end
    if self.snap>0 then
        width=math.max(1,math.floor(width/self.snap+.5)*self.snap)
        height=math.max(1,math.floor(height/self.snap+.5)*self.snap)
    end
    local patch={width=width,height=height}
    if keepTopLeft then patch.x=e.x+(width-e.width)/2; patch.y=e.y-(height-e.height)/2 end
    return self:Update(id,patch)
end
function Session:Align(id,mode,referenceId)
    local e=self:Element(id)
    if not e then return nil,"No element selected" end
    local ref
    if referenceId then ref=self:Element(referenceId) else ref={x=0,y=0,width=0,height=0} end
    if not ref then return nil,"Unknown alignment reference" end
    local patch={}
    if mode=="centerX" then patch.x=ref.x
    elseif mode=="centerY" then patch.y=ref.y
    elseif mode=="left" then patch.x=ref.x-ref.width/2+e.width/2
    elseif mode=="right" then patch.x=ref.x+ref.width/2-e.width/2
    elseif mode=="top" then patch.y=ref.y+ref.height/2-e.height/2
    elseif mode=="bottom" then patch.y=ref.y-ref.height/2+e.height/2
    else return nil,"Unknown alignment mode" end
    -- Alignment is exact; a snap step must not move an aligned edge away again.
    return self:Update(id,patch)
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
    e.id="copy"..id; e.x=math.min(512,e.x+8); e.y=math.max(-512,e.y-8); e.locked=false
    table.insert(layout.elements,e)
    local ok,err=self:Commit(layout)
    if ok then self.selected=e.id end
    return ok,err
end
function Session:Delete()
    local e,index=self:Element()
    if not e or e.locked then return nil,"No editable selection" end
    if #self.layout.elements==1 then return nil,"Keep at least one element in the layout" end
    local layout=NS.Copy(self.layout); table.remove(layout.elements,index)
    local ok,err=self:Commit(layout)
    if ok then self.selected=layout.elements[1].id end
    return ok,err
end
function Session:ResetElement()
    local current,index=self:Element()
    if not current then return nil,"No element selected" end
    if current.locked then return nil,"Element is locked" end
    for _,preset in ipairs(NS.Presets) do
        if preset.layout.name==self.layout.name then
            for _,e in ipairs(preset.layout.elements) do
                if e.id==current.id then local layout=NS.Copy(self.layout); layout.elements[index]=NS.Copy(e); return self:Commit(layout) end
            end
        end
    end
    local factory,err=NS.Catalog.Create(current.kind,current.id)
    if not factory then return nil,err end
    local layout=NS.Copy(self.layout); layout.elements[index]=factory
    return self:Commit(layout)
end
