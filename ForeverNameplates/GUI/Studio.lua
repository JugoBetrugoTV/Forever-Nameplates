local _, NS = ...
local W,R=NS.W,NS.Renderer
local Studio={zoom=1,scenario=1,handles={},grid={},sandboxViews={}}
NS.Studio=Studio
Studio.scenarios={
    {name="Ashen Sentinel",health=76,healthText="76%",level=60,target=false,casting=false,castName=""},
    {name="Elite • Iron Warden",health=83,healthText="83%",level=62,target=true,casting=false,castName=""},
    {name="Boss • The Unbound",health=54,healthText="54%",level="??",target=true,casting=true,castName="Cataclysm",progress=42},
    {name="Friendly • Seraphine",health=100,healthText="100%",level=60,target=false,casting=false,castName=""},
    {name="Enemy Player • Vex",health=65,healthText="65%",level=60,target=false,casting=false,castName=""},
    {name="Low Health • Sentinel",health=12,healthText="12%",level=60,target=false,casting=false,castName=""},
    {name="Casting • Runeweaver",health=76,healthText="76%",level=60,target=false,casting=true,castName="Arcane Bolt",progress=64},
    {name="Target • Ashen Sentinel",health=76,healthText="76%",level=60,target=true,casting=false,castName=""},
}
-- Preview identities are explicit simulated public data, never sampled from combat.
for i,state in ipairs(Studio.scenarios) do
    state.isPlayer=i==4 or i==5; state.controlled=state.isPlayer
    state.reaction=i==4 and 5 or 3; state.classification=i==2 and "elite" or i==3 and "worldboss" or "normal"
    state.class=state.isPlayer and (i==4 and "PRIEST" or "ROGUE") or nil
    state.raidMarker=i==2 and 8 or nil
end
local extraScenarios={
    {name="Friendly NPC • Keeper",isPlayer=false,controlled=false,reaction=5,classification="normal"},
    {name="Neutral NPC • Merchant",isPlayer=false,controlled=false,reaction=4,classification="normal"},
    {name="Pet • Spirit Wolf",isPlayer=false,controlled=true,reaction=3,classification="normal"},
    {name="Rare Elite • Watcher",isPlayer=false,controlled=false,reaction=3,classification="rareelite",raidMarker=4},
    {name="Restricted • Unknown"},
}
for _,state in ipairs(extraScenarios) do
    state.health=72; state.healthText="72%"; state.level=60; state.casting=false; state.castName=""
    if state.name~="Restricted • Unknown" then state.target=false end
    Studio.scenarios[#Studio.scenarios+1]=state
end
local function attempt(ok,err) if not ok and err then NS.Print(err) end; return ok end
function Studio.LoadSession()
    Studio.session=NS.Session.New(NS.DB.Current(),NS.DB.Save)
end
function Studio.Status(text)
    if Studio.status then Studio.status:SetText(text or (NS.DB.CurrentName().."  /  "..Studio.session.layout.name.."  /  "..math.floor(Studio.zoom*100).."%")) end
end
function Studio.Select(id)
    Studio.session.selected=id; Studio.RefreshInspector(); Studio.RefreshHandles()
end
function Studio.ArtworkReady(element)
    for _,part in ipairs(Studio.view and Studio.view.parts or {}) do
        if part.element.id==element.id and part.image then return part.imageReady==true end
    end
    return false
end
function Studio.RefreshInspector()
    if not Studio.ready then return end
    local e=Studio.session:Element()
    if not e or not Studio.inspector then return end
    Studio.inspector.title:SetText(e.id.."  /  "..e.kind)
    for key,edit in pairs(Studio.inspector.fields) do edit:SetText(tostring(e[key])) end
    Studio.inspector.visible:SetValue(e.enabled); Studio.inspector.locked:SetValue(e.locked)
    Studio.inspector.vertical:SetValue(e.vertical); Studio.inspector.reverse:SetValue(e.reverse)
    Studio.inspector.source:SetValue(e.source)
    Studio.inspector.shape:SetValue(e.shape)
    Studio.inspector.source:SetEnabled(e.kind=="text")
    Studio.inspector.shape:SetEnabled(e.kind=="ornament" or e.kind=="panel" or e.kind=="target")
    Studio.inspector.vertical:SetEnabled(e.kind=="health" or e.kind=="cast")
    Studio.inspector.reverse:SetEnabled(e.kind=="health" or e.kind=="cast")
    Studio.inspector.fields.fontSize:SetEnabled(e.kind=="text" or e.kind=="class")
    Studio.inspector.text:SetText(e.text); Studio.inspector.text:SetEnabled(e.kind=="text")
    Studio.inspector.asset:SetShown(e.kind=="artwork")
    Studio.inspector.shape:SetShown(e.kind~="artwork")
    Studio.inspector.asset:SetValue(e.asset)
    Studio.inspector.asset:SetEnabled(#NS.Catalog.Assets()>0)
    Studio.elementPicker:SetValue(e.id)
    local art=Studio.session:Element("artFrame")
    Studio.useFrameArt:SetEnabled(art~=nil and art.kind=="artwork" and NS.Media.files[art.asset]~=nil)
    Studio.resizeHandle:SetShown(e.enabled and not e.locked and (e.kind~="artwork" or Studio.ArtworkReady(e)))
    Studio.resizeHandle:ClearAllPoints()
    Studio.resizeHandle:SetPoint("CENTER",Studio.view.root,"CENTER",e.x+e.width/2,e.y-e.height/2)
end
function Studio.Change(patch)
    local ok,err=Studio.session:Update(Studio.session.selected,patch)
    if attempt(ok,err) then Studio.Refresh() else Studio.RefreshInspector() end
    return ok==true
end
function Studio.EndDrag(commit)
    local d=Studio.drag
    if not d then return end
    Studio.canvas:SetScript("OnUpdate",nil); Studio.drag=nil
    if commit and not NS.InCombat() then
        local x,y=GetCursorPosition(); local scale=Studio.view.root:GetEffectiveScale()
        local dx,dy=(x-d.cursorX)/scale,(y-d.cursorY)/scale
        if d.mode=="resize" then attempt(Studio.session:Resize(d.id,d.width+dx,d.height-dy,true))
        else attempt(Studio.session:Move(d.id,d.x+dx,d.y+dy)) end
    end
    Studio.Refresh()
end
function Studio.StartDrag(handle,mode)
    local item=mode=="resize" and Studio.session:Element() or handle.element
    if NS.InCombat() or not item or item.locked then return end
    Studio.Select(item.id)
    local x,y=GetCursorPosition()
    Studio.drag={id=item.id,x=item.x,y=item.y,width=item.width,height=item.height,cursorX=x,cursorY=y,mode=mode}
    Studio.canvas:SetScript("OnUpdate",function()
        if NS.InCombat() then Studio.EndDrag(false); return end
        local cx,cy=GetCursorPosition(); local s=Studio.view.root:GetEffectiveScale()
        local dx,dy=(cx-x)/s,(cy-y)/s
        local px,py,w,h=item.x+dx,item.y+dy,item.width,item.height
        if mode=="resize" then
            w=math.min(512,math.max(1,item.width+dx)); h=math.min(512,math.max(1,item.height-dy))
            px=item.x+(w-item.width)/2; py=item.y-(h-item.height)/2
        end
        local selection=mode=="resize" and Studio.handles[select(2,Studio.session:Element())] or handle
        selection:ClearAllPoints(); selection:SetPoint("CENTER",Studio.view.root,"CENTER",px,py)
        selection:SetSize(math.max(10,w),math.max(10,h))
        Studio.resizeHandle:ClearAllPoints(); Studio.resizeHandle:SetPoint("CENTER",Studio.view.root,"CENTER",px+w/2,py-h/2)
        for _,part in ipairs(Studio.view.parts) do
            if part.element.id==item.id then
                part.frame:ClearAllPoints(); part.frame:SetPoint("CENTER",Studio.view.root,"CENTER",px,py)
                R.Resize(part,w,h)
            end
        end
    end)
end
function Studio.RefreshHandles()
    if not Studio.ready or not Studio.canvas then return end
    for _,h in ipairs(Studio.handles) do h:Hide(); h.element=nil end
    for i,e in ipairs(Studio.session.layout.elements) do
        local h=Studio.handles[i]
        if not h then
            h=CreateFrame("Button",nil,Studio.view.root); h:RegisterForDrag("LeftButton")
            local mark=h:CreateTexture(nil,"OVERLAY"); mark:SetAllPoints(h); mark:SetColorTexture(.9,.7,.3,.2); h.mark=mark
            h:SetScript("OnClick",function(self) Studio.Select(self.element.id) end)
            h:SetScript("OnDragStart",function(self) Studio.StartDrag(self,"move") end)
            h:SetScript("OnDragStop",function() Studio.EndDrag(true) end)
            Studio.handles[i]=h
        end
        h.element=e; h:SetSize(math.max(10,e.width),math.max(10,e.height))
        h:ClearAllPoints(); h:SetPoint("CENTER",Studio.view.root,"CENTER",e.x,e.y)
        h:SetFrameLevel(Studio.view.root:GetFrameLevel()+25+e.layer)
        h.mark:SetShown(e.id==Studio.session.selected); h:SetShown(e.enabled and (e.kind~="artwork" or Studio.ArtworkReady(e)))
    end
end
function Studio.RefreshGrid()
    for _,line in ipairs(Studio.grid) do line:Hide() end
    if Studio.session.snap==0 then return end
    local spacing=Studio.session.snap*Studio.zoom*(Studio.view.effect and Studio.view.effect.scale or 1)
    local count=0
    local function line(x,y,w,h)
        count=count+1
        local t=Studio.grid[count]
        if not t then t=Studio.canvas:CreateTexture(nil,"BACKGROUND"); Studio.grid[count]=t end
        t:ClearAllPoints(); t:SetPoint("CENTER",Studio.canvas,"CENTER",x,y); t:SetSize(w,h)
        local color=W.skins[W.skin].accent; t:SetColorTexture(color[1],color[2],color[3],.09); t:Show()
    end
    for i=-math.floor(282/spacing),math.floor(282/spacing) do line(i*spacing,0,1,340) end
    for i=-math.floor(170/spacing),math.floor(170/spacing) do line(0,i*spacing,564,1) end
end
function Studio.RefreshSandbox()
    for _,tile in ipairs(Studio.sandboxViews) do
        R.Apply(tile.view,Studio.session.layout); R.Update(tile.view,Studio.scenarios[tile.scenario])
    end
end
function Studio.Refresh()
    if not Studio.ready or not Studio.session then return end
    Studio.view.previewScale=Studio.zoom
    R.Apply(Studio.view,Studio.session.layout)
    R.Update(Studio.view,Studio.scenarios[Studio.scenario])
    Studio.RefreshHandles(); Studio.RefreshInspector(); Studio.RefreshGrid(); Studio.Status()
    Studio.gridButton.label:SetText(Studio.session.snap==0 and "Grid: off" or "Grid: 4 px")
    local sourceChoice="Game nameplates"
    for i,entry in ipairs(NS.GameNameplates) do
        if entry.layout and entry.layout.name==Studio.session.layout.name then sourceChoice=i; break end
    end
    Studio.gameNameplatePicker:SetValue(sourceChoice)
    if Studio.page=="sandbox" then Studio.RefreshSandbox() end
    if Studio.page=="rules" then Studio.RefreshRules() end
end
function Studio.ShowPage(name)
    if not Studio.ready then return end
    if NS.InCombat() then NS.Print(NS.L.combat); return end
    Studio.EndDrag(false); W.ClosePopups()
    for key,page in pairs(Studio.pages) do page:SetShown(key==name) end
    Studio.page=name
    if name=="studio" then Studio.Refresh() end
    if name=="profiles" then Studio.RefreshProfiles() end
    if name=="diagnostics" then Studio.RefreshDiagnostics() end
    if name=="sandbox" then Studio.RefreshSandbox() end
    if name=="rules" then Studio.RefreshRules() end
end
local function makePage(root)
    local p=CreateFrame("Frame",nil,root); p:SetSize(872,566); p:SetPoint("TOPLEFT",182,-76); return p
end
function Studio.CreateGallery(page)
    W.Label(page,NS.L.gallery,22,0,0)
    W.Label(page,"Placeholder layouts. Exact game references and final artwork are pending.",11,0,-32)
    Studio.galleryCards={}
    for index,preset in ipairs(NS.Presets) do
        local x=((index-1)%3)*288; local y=-58-math.floor((index-1)/3)*124
        local card=W.Button(page,"",x,y,278,function()
            if NS.InCombat() then NS.Print(NS.L.combat); return end
            if attempt(Studio.session:Commit(preset.layout)) then Studio.ShowPage("studio") end
        end)
        Studio.galleryCards[index]=card
        card:SetHeight(114); W.Line(card,0,0,278)
        W.Label(card,preset.layout.name,12,12,-10)
        local art=preset.layout.elements[#preset.layout.elements]
        W.Label(card,NS.Media.files[art.asset] and "Artwork imported; reference match unverified" or "PLACEHOLDER / no frame artwork",9,12,-94)
        local view=R.Create(card); view.root:SetPoint("CENTER",card,"CENTER",0,-4); view.previewScale=.65
        R.Apply(view,preset.layout); R.Update(view,{name="",health=72,healthText="",target=false,casting=false,castName=""})
    end
end
function Studio.CreateEditor(page)
    W.Label(page,NS.L.studio,22,0,0)
    Studio.addButton=W.Button(page,"+ Add component",0,-42,154,function(self)
        local choices={}
        for _,entry in ipairs(NS.Catalog.entries) do
            choices[#choices+1]={value=entry.id,label=entry.label,disabled=entry.id=="artwork" and #NS.Catalog.Assets()==0}
        end
        W.Menu(self,choices,function(kind) if attempt(Studio.session:Add(kind)) then Studio.Refresh() end end)
    end)
    Studio.elementPicker=W.Dropdown(page,164,-42,260,function()
        local choices={}
        for _,e in ipairs(Studio.session.layout.elements) do
            choices[#choices+1]={value=e.id,label=e.id.." ["..e.kind.."]"..(e.enabled and "" or " (hidden)")..(e.locked and " (locked)" or "")}
        end
        return choices
    end,function(id) Studio.Select(id) end)
    W.Button(page,"Align element",434,-42,156,function(self)
        local ref
        for _,e in ipairs(Studio.session.layout.elements) do if e.kind=="health" and e.id~=Studio.session.selected then ref=e.id; break end end
        W.Menu(self,{{value="centerX",label="Center X on plate"},{value="centerY",label="Center Y on plate"},
            {value="left",label="Left edge to health",disabled=not ref}, {value="right",label="Right edge to health",disabled=not ref},
            {value="top",label="Top edge to health",disabled=not ref}, {value="bottom",label="Bottom edge to health",disabled=not ref}},function(mode)
            local reference
            if mode~="centerX" and mode~="centerY" then reference=ref end
            if attempt(Studio.session:Align(Studio.session.selected,mode,reference)) then Studio.Refresh() end
        end)
    end)
    local canvas=CreateFrame("Frame",nil,page); canvas:SetSize(590,374); canvas:SetPoint("TOPLEFT",0,-80); canvas:SetClipsChildren(true); W.Paint(canvas,"bg")
    Studio.canvas=canvas
    W.Label(canvas,NS.L.preview,10,14,-12,{.65,.64,.6,1})
    Studio.view=R.Create(canvas); Studio.view.root:SetPoint("CENTER",canvas,"CENTER",0,0)
    Studio.resizeHandle=CreateFrame("Button",nil,Studio.view.root); Studio.resizeHandle:SetSize(10,10)
    Studio.resizeHandle:SetFrameLevel(Studio.view.root:GetFrameLevel()+60); Studio.resizeHandle:RegisterForDrag("LeftButton"); W.Paint(Studio.resizeHandle,"accent")
    Studio.resizeHandle:SetScript("OnDragStart",function(self) Studio.StartDrag(self,"resize") end)
    Studio.resizeHandle:SetScript("OnDragStop",function() Studio.EndDrag(true) end)
    W.Button(page,NS.L.undo,0,-466,88,function() attempt(Studio.session:Undo()); Studio.Refresh() end)
    W.Button(page,NS.L.redo,96,-466,88,function() attempt(Studio.session:Redo()); Studio.Refresh() end)
    W.Button(page,"−",194,-466,30,function() Studio.zoom=math.max(.5,Studio.zoom-.25); Studio.Refresh() end)
    W.Button(page,"+",232,-466,30,function() Studio.zoom=math.min(2,Studio.zoom+.25); Studio.Refresh() end)
    Studio.gridButton=W.Button(page,"Grid: 4 px",270,-466,138,function(self)
        Studio.session.snap=Studio.session.snap==0 and 4 or 0; self.label:SetText(Studio.session.snap==0 and "Grid: off" or "Grid: 4 px"); Studio.Refresh()
    end)
    Studio.previewPicker=W.Dropdown(page,416,-466,174,function()
        local choices={}; for i,state in ipairs(Studio.scenarios) do choices[#choices+1]={value=i,label=state.name} end; return choices
    end,function(value) Studio.scenario=value; Studio.Refresh() end)
    Studio.previewPicker:SetValue(Studio.scenario)
    W.Label(page,"Drag to move. Drag the gold corner to resize. Changes save automatically.",10,0,-508)
    Studio.useFrameArt=W.Button(page,"Use imported frame; remove preset ornaments",0,-536,360,function()
        if attempt(Studio.session:UseFrameArtwork()) then Studio.Refresh() end
    end)
    Studio.gameNameplatePicker=W.Dropdown(page,376,-536,214,function()
        local choices={}
        for i,entry in ipairs(NS.GameNameplates) do
            choices[#choices+1]={value=i,label=entry.game..(entry.layout and " / source draft" or " / reference unavailable"),disabled=entry.layout==nil}
        end
        return choices
    end,function(value)
        local entry=NS.GameNameplates[value]
        if not entry or not entry.layout then return false end
        local ok,err=Studio.session:Commit(entry.layout)
        if attempt(ok,err) then Studio.Refresh(); return true end
        return false
    end)
    Studio.gameNameplatePicker:SetValue("Game nameplates")
    local inspector=CreateFrame("Frame",nil,page); inspector:SetSize(258,478); inspector:SetPoint("TOPLEFT",610,-80); W.Paint(inspector,"panel")
    Studio.inspector={fields={}}
    Studio.inspector.title=W.Label(inspector,"",13,12,-12)
    W.Button(inspector,"Select previous",12,-40,110,function()
        local _,i=Studio.session:Element(); local list=Studio.session.layout.elements
        Studio.Select(list[(i or 1)-2<0 and #list or i-1].id)
    end)
    W.Button(inspector,"Select next",130,-40,116,function()
        local _,i=Studio.session:Element(); local list=Studio.session.layout.elements
        Studio.Select(list[(i or 1)%#list+1].id)
    end)
    local keys={"x","y","width","height","layer","fontSize","alpha"}
    for i,key in ipairs(keys) do
        local column=(i-1)%2; local row=math.floor((i-1)/2)
        W.Label(inspector,key,10,12+column*118,-78-row*46)
        Studio.inspector.fields[key]=W.Edit(inspector,12+column*118,-92-row*46,106,"",function(value)
            local n=tonumber(value); if n then Studio.Change({[key]=n}) else NS.Print("Enter a number"); Studio.RefreshInspector() end
        end)
    end
    W.Button(inspector,"Color / opacity",130,-230,116,function()
        local session=Studio.session; local e=session:Element(); local id=e.id
        W.Color(e.color,function(color)
            if Studio.session~=session then return end
            if attempt(session:Update(id,{color=color})) then Studio.Refresh() end
        end)
    end)
    Studio.inspector.visible=W.Toggle(inspector,"Visible",12,-274,110,true,function(v) Studio.Change({enabled=v}) end)
    Studio.inspector.locked=W.Toggle(inspector,"Locked",130,-274,116,false,function(v) Studio.Change({locked=v}) end)
    Studio.inspector.vertical=W.Toggle(inspector,"Vertical",12,-306,110,false,function(v) Studio.Change({vertical=v}) end)
    Studio.inspector.reverse=W.Toggle(inspector,"Reverse",130,-306,116,false,function(v) Studio.Change({reverse=v}) end)
    Studio.inspector.source=W.Dropdown(inspector,12,-338,234,{{value="name",label="Unit name"},{value="health",label="Health text"},
        {value="level",label="Level"},{value="classification",label="Classification"},{value="class",label="Class abbreviation"},{value="cast",label="Cast text"},{value="static",label="Custom text"}},function(value) return Studio.Change({source=value}) end)
    Studio.inspector.shape=W.Dropdown(inspector,12,-370,234,{{value="rect",label="Rectangle"},{value="diamond",label="Diamond"},
        {value="outline",label="Outline"},{value="rune",label="Rune"},{value="brackets",label="Brackets"},{value="segments",label="Segments"}},function(value) return Studio.Change({shape=value}) end)
    Studio.inspector.asset=W.Dropdown(inspector,12,-370,234,function()
        local choices={}; for _,id in ipairs(NS.Catalog.Assets()) do choices[#choices+1]={value=id,label=id} end; return choices
    end,function(value) return Studio.Change({asset=value}) end)
    W.Button(inspector,"Copy",12,-406,70,function() Studio.session:Copy() end)
    W.Button(inspector,"Paste",90,-406,70,function() attempt(Studio.session:Paste()); Studio.Refresh() end)
    W.Button(inspector,"Delete",168,-406,78,function() attempt(Studio.session:Delete()); Studio.Refresh() end)
    W.Button(inspector,"Reset element",12,-442,110,function() attempt(Studio.session:ResetElement()); Studio.Refresh() end)
    Studio.inspector.text=W.Edit(inspector,130,-442,116,"",function(value) Studio.Change({text=value}) end)
end
function Studio.CreateSandbox(page)
    W.Label(page,NS.L.sandbox,22,0,0)
    W.Label(page,"Compare four simulated units using your active layout. Gameplay is unaffected.",11,0,-34)
    for i=1,4 do
        local tile=CreateFrame("Frame",nil,page); tile:SetSize(424,216)
        tile:SetPoint("TOPLEFT",((i-1)%2)*442,-62-math.floor((i-1)/2)*234); W.Paint(tile,"bg"); tile:SetClipsChildren(true)
        local caption=W.Label(tile,"SAMPLE 0"..i,10,12,-12,"accent")
        local preview={scenario=i==1 and 1 or i==2 and 3 or i==3 and 6 or 8,view=R.Create(tile)}
        preview.view.root:SetPoint("CENTER",tile,"CENTER",0,8); preview.view.previewScale=.85
        preview.picker=W.Dropdown(tile,12,-176,400,function()
            local choices={}; for j,state in ipairs(Studio.scenarios) do choices[#choices+1]={value=j,label=state.name} end; return choices
        end,function(value) preview.scenario=value; Studio.RefreshSandbox() end)
        preview.picker:SetValue(preview.scenario)
        Studio.sandboxViews[#Studio.sandboxViews+1]=preview
    end
end
function Studio.ChangeRules(patch,category)
    local ok,err=Studio.session:UpdateRules(patch,category)
    attempt(ok,err); Studio.RefreshRules(); Studio.Refresh()
    return ok==true
end
function Studio.RefreshRules()
    local ui=Studio.ruleUI
    if not ui then return end
    local config=Studio.session.layout.rules; local rule=config.overrides[ui.category]
    ui.globalMode:SetValue(config.healthColor); ui.categoryPicker:SetValue(ui.category)
    ui.enabled:SetValue(rule.enabled); ui.visible:SetValue(rule.visible)
    ui.alpha:SetText(tostring(rule.alpha)); ui.scale:SetText(tostring(rule.scale)); ui.colorMode:SetValue(rule.colorMode)
    R.Apply(ui.view,Studio.session.layout); R.Update(ui.view,Studio.scenarios[ui.scenario])
    ui.result:SetText("Resolved category: "..ui.view.effect.category.."  /  "..(ui.view.effect.visible and "shown" or "hidden"))
end
function Studio.CreateRules(page)
    W.Label(page,NS.L.rules,22,0,0)
    W.Label(page,"Rules save with your profile. Unknown identities use safe fallbacks.",11,0,-34)
    local ui={category="enemyPlayers",scenario=5}; Studio.ruleUI=ui
    local modes={{value="preset",label="Preset color"},{value="class",label="Player class color"},{value="reaction",label="Reaction color"}}
    W.Label(page,"Default health color",12,0,-70)
    ui.globalMode=W.Dropdown(page,0,-94,260,modes,function(v) return Studio.ChangeRules({healthColor=v}) end)
    for i,key in ipairs({"friendlyColor","neutralColor","hostileColor"}) do
        W.Button(page,key,0,-136-(i-1)*38,260,function()
            local session=Studio.session
            W.Color(session.layout.rules[key],function(color)
                if Studio.session==session then Studio.ChangeRules({[key]=color}) end
            end)
        end)
    end
    W.Label(page,"Category override",12,302,-70)
    local choices={}; for _,category in ipairs(NS.Rules.categories) do choices[#choices+1]={value=category.id,label=category.label} end
    ui.categoryPicker=W.Dropdown(page,302,-94,270,choices,function(v) ui.category=v; Studio.RefreshRules() end)
    ui.enabled=W.Toggle(page,"Enable this rule",302,-136,270,false,function(v) return Studio.ChangeRules({enabled=v},ui.category) end)
    ui.visible=W.Toggle(page,"Show matching overlay",302,-174,270,true,function(v) return Studio.ChangeRules({visible=v},ui.category) end)
    W.Label(page,"Opacity 0–1",11,302,-216); W.Label(page,"Scale 0.5–2",11,442,-216)
    ui.alpha=W.Edit(page,302,-236,126,"1",function(v) Studio.ChangeRules({alpha=tonumber(v) or -1},ui.category) end)
    ui.scale=W.Edit(page,442,-236,130,"1",function(v) Studio.ChangeRules({scale=tonumber(v) or -1},ui.category) end)
    local categoryModes={{value="inherit",label="Inherit earlier color"},{value="fixed",label="Fixed color"}}
    for _,mode in ipairs(modes) do categoryModes[#categoryModes+1]=mode end
    ui.colorMode=W.Dropdown(page,302,-278,270,categoryModes,function(v) return Studio.ChangeRules({colorMode=v},ui.category) end)
    W.Button(page,"Fixed color / opacity",302,-316,270,function()
        local session,category=Studio.session,ui.category
        W.Color(session.layout.rules.overrides[category].color,function(color)
            if Studio.session==session then Studio.ChangeRules({color=color},category) end
        end)
    end)
    local preview=CreateFrame("Frame",nil,page); preview:SetSize(264,230); preview:SetPoint("TOPLEFT",598,-70)
    W.Paint(preview,"bg"); preview:SetClipsChildren(true)
    ui.view=R.Create(preview); ui.view.root:SetPoint("CENTER",preview,"CENTER",0,0); ui.view.previewScale=.65
    ui.scenarioPicker=W.Dropdown(page,598,-316,264,function()
        local result={}; for i,state in ipairs(Studio.scenarios) do result[#result+1]={value=i,label=state.name} end; return result
    end,function(v) ui.scenario=v; Studio.RefreshRules() end)
    ui.scenarioPicker:SetValue(ui.scenario)
    ui.result=W.Label(page,"",11,0,-378)
    W.Label(page,"Priority: unit category → elite / rare / boss → target / other.\n"..
        "Each enabled rule replaces visibility, opacity and scale; Inherit keeps the earlier color.\n"..
        "Rules affect the Forever overlay; the default client plate is separate.\n"..
        "Add Raid marker or Class badge in Layout Studio. Text can display level / classification.",11,0,-412)
    W.Button(page,NS.L.undo,0,-514,100,function() attempt(Studio.session:Undo()); Studio.Refresh() end)
    W.Button(page,NS.L.redo,110,-514,100,function() attempt(Studio.session:Redo()); Studio.Refresh() end)
end
function Studio.RefreshProfiles()
    local names={}; for name in pairs(NS.DB.data.profiles) do names[#names+1]=name end; table.sort(names)
    Studio.profileNames=names
    Studio.profileList:SetText("Active: "..NS.DB.CurrentName().."\n\nProfiles: "..#names.." / 32")
    Studio.profilePicker:SetValue(NS.DB.CurrentName())
    Studio.character:SetValue(NS.DB.character and NS.DB.data.characters[NS.DB.character]~=nil or false)
end
function Studio.CreateProfiles(page)
    W.Label(page,NS.L.profiles,22,0,0)
    Studio.profileList=W.Label(page,"",12,0,-52); Studio.profileList:SetWidth(220)
    Studio.profilePicker=W.Dropdown(page,0,-122,220,function()
        local choices={}; local names={}
        for name in pairs(NS.DB.data.profiles) do names[#names+1]=name end; table.sort(names)
        for _,name in ipairs(names) do choices[#choices+1]={value=name,label=name} end
        return choices
    end,function(name)
        if attempt(NS.DB.Select(name)) then Studio.LoadSession(); Studio.RefreshProfiles(); Studio.Refresh(); return true end
        return false
    end)
    Studio.deleteProfile=W.Button(page,"Delete active profile",0,-160,220,function()
        local name=NS.DB.CurrentName()
        if name=="Default" then NS.Print("Default cannot be deleted"); return end
        W.Confirm(Studio.root,"Delete profile '"..name.."'?\nCharacters using it will return to Default.",function()
            if attempt(NS.DB.Delete(name)) then Studio.LoadSession(); Studio.RefreshProfiles(); Studio.Refresh() end
        end)
    end)
    W.Label(page,"Factory reset current profile",11,0,-216)
    Studio.resetPicker=W.Dropdown(page,0,-242,220,function()
        local choices={}; for i,p in ipairs(NS.Presets) do choices[#choices+1]={value=i,label=p.layout.name} end; return choices
    end,function(index)
        Studio.resetPreset=index
    end)
    Studio.resetPreset=1; Studio.resetPicker:SetValue(1)
    Studio.resetProfile=W.Button(page,"Reset to selected preset",0,-280,220,function()
        local name,preset=NS.DB.CurrentName(),NS.Presets[Studio.resetPreset]
        W.Confirm(Studio.root,"Reset '"..name.."' to\n"..preset.layout.name.."? Export a backup first.",function()
            if NS.DB.CurrentName()~=name then return end
            if attempt(NS.DB.Save(preset.layout)) then Studio.LoadSession(); Studio.RefreshProfiles(); Studio.Refresh() end
        end)
    end)
    W.Label(page,"Profile name — Enter to create a copy",11,250,-52)
    Studio.profileName=W.Edit(page,250,-78,330,"",function(value)
        if NS.InCombat() then NS.Print(NS.L.combat); return end
        if attempt(NS.DB.Create(value)) then Studio.LoadSession(); Studio.RefreshProfiles(); Studio.Refresh() end
    end)
    W.Button(page,"Select named profile",250,-116,192,function()
        if NS.InCombat() then return end
        if attempt(NS.DB.Select(Studio.profileName:GetText())) then Studio.LoadSession(); Studio.RefreshProfiles(); Studio.Refresh() end
    end)
    W.Button(page,"Rename",452,-116,128,function()
        if NS.InCombat() then return end
        if attempt(NS.DB.Rename(Studio.profileName:GetText())) then Studio.LoadSession(); Studio.RefreshProfiles(); Studio.Refresh() end
    end)
    Studio.character=W.Toggle(page,"Use a character profile",250,-154,330,false,function(value) attempt(NS.DB.SetCharacter(value)); Studio.LoadSession(); Studio.RefreshProfiles(); Studio.Refresh() end)
    W.Label(page,"Share code — copy to a text file for beta-safe backups",11,250,-202)
    local scroll=CreateFrame("ScrollFrame",nil,page,"UIPanelScrollFrameTemplate"); scroll:SetSize(564,188); scroll:SetPoint("TOPLEFT",250,-228)
    local edit=CreateFrame("EditBox",nil,scroll); edit:SetSize(550,188); edit:SetMultiLine(true); edit:SetAutoFocus(false)
    edit:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",11,""); edit:SetMaxLetters(48000); W.Paint(edit,"bg")
    edit:SetScript("OnEscapePressed",function(self) self:ClearFocus() end); scroll:SetScrollChild(edit); Studio.shareBox=edit
    W.Button(page,"Export active profile",250,-436,192,function()
        local code,err=NS.Share.Export(NS.DB.Current()); if not code then NS.Print(err); return end
        edit:SetText(code); edit:SetFocus(); edit:HighlightText()
    end)
    W.Button(page,"Import as new profile",452,-436,192,function()
        if NS.InCombat() then NS.Print(NS.L.combat); return end
        local layout,err=NS.Share.Import(edit:GetText()); if not layout then NS.Print(err); return end
        if attempt(NS.DB.Create(Studio.profileName:GetText(),layout)) then Studio.LoadSession(); Studio.RefreshProfiles(); Studio.Refresh() end
    end)
    W.Label(page,"Beta reports: SavedVariables may not reload after restarting the client.\nKeep an exported share code outside the game until verified on your build.",11,250,-488)
end
function Studio.RefreshDiagnostics()
    local c,s=NS.Compat,NS.Engine.stats
    local active=0; for _ in pairs(NS.Engine.units) do active=active+1 end
    Studio.diagnosticText:SetText("Interface: "..tostring(c.interface).." (expected 16001)\n"..
        "C_NamePlate: "..tostring(c.nameplates).."  /  Secret predicates: "..tostring(c.secrets).."\n"..
        "Created overlays: "..s.created.."  /  Active: "..active.."\n"..
        "Event updates: "..s.updates.."  /  Rejected bases: "..s.skipped.."\n"..
        "Widget forwarding failures: "..c.failures.."\n\n"..
        "Live rendering uses an additional overlay above the default plate.\n"..
        "Protected and forbidden bases are skipped. Newly visible plates in combat\n"..
        "are deferred until combat ends. No default frames or hit areas are changed.\n\n"..
        "Not yet validated in a Forever client. Missing/secret text is omitted.\n"..
        "Health thresholds, curved health fill and exact threat math are unavailable.\n\n"..
        table.concat(NS.logs,"\n"))
    Studio.live:SetValue(NS.DB.data.live)
end
function Studio.CreateDiagnostics(page)
    W.Label(page,NS.L.diagnostics,22,0,0)
    Studio.live=W.Toggle(page,NS.L.live,0,-50,400,false,function(value)
        if value and (not NS.Compat.nameplates or not NS.Compat.expected) then NS.Print("Expected Forever interface 16001 and C_NamePlate"); return end
        NS.DB.data.live=value; NS.Engine.Refresh(); Studio.RefreshDiagnostics()
    end)
    Studio.diagnosticText=W.Label(page,"",12,0,-98); Studio.diagnosticText:SetWidth(840)
    W.Button(page,"Refresh diagnostics",0,-508,192,Studio.RefreshDiagnostics)
end
local function createStudio()
    Studio.handles={}; Studio.grid={}; Studio.sandboxViews={}
    Studio.LoadSession()
    -- Publish the Escape-key global only after all pages have been constructed.
    local root=CreateFrame("Frame",nil,UIParent); root:Hide(); Studio.root=root
    root:SetSize(1080,680); root:SetPoint("CENTER")
    root:SetFrameStrata("DIALOG"); root:EnableMouse(true); root:SetMovable(true); root:RegisterForDrag("LeftButton"); W.Paint(root,"bg")
    root:SetScale(math.min(1,(UIParent:GetWidth()-40)/1080,(UIParent:GetHeight()-40)/680))
    root:SetScript("OnDragStart",function(self) if not NS.InCombat() then self:StartMoving() end end)
    root:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
    root:SetScript("OnHide",function() if Studio.ready then Studio.EndDrag(false) end; W.ClosePopups() end)
    if NS.Media.files.studio_header then
        local art=root:CreateTexture(nil,"ARTWORK"); art:SetSize(512,64); art:SetPoint("TOPLEFT",0,0)
        art:SetTexture("Interface\\AddOns\\"..NS.folder.."\\Media\\"..NS.Media.files.studio_header)
    end
    W.Label(root,"FOREVER",24,22,-20,{.84,.7,.43,1}); W.Label(root,"NAMEPLATES  /  STUDIO",10,190,-30)
    W.Label(root,NS.L.pending,10,22,-648,{.7,.6,.4,1})
    W.Line(root,20,-60,1040)
    W.Button(root,"×",1028,-18,30,function() root:Hide() end)
    W.Button(root,"GUI skin",868,-18,146,function()
        local options={"Dark RPG","Light Fantasy","Modern Studio"}
        for i,v in ipairs(options) do if W.skin==v then W.Skin(options[i%3+1]); Studio.Refresh(); break end end
    end)
    Studio.status=W.Label(root,"",10,490,-648)
    Studio.pages={}
    for _,name in ipairs({"gallery","studio","sandbox","rules","profiles","diagnostics"}) do Studio.pages[name]=makePage(root) end
    Studio.CreateGallery(Studio.pages.gallery); Studio.CreateEditor(Studio.pages.studio)
    Studio.CreateSandbox(Studio.pages.sandbox); Studio.CreateRules(Studio.pages.rules); Studio.CreateProfiles(Studio.pages.profiles); Studio.CreateDiagnostics(Studio.pages.diagnostics)
    for i,name in ipairs({"gallery","studio","sandbox","rules","profiles","diagnostics"}) do
        W.Button(root,NS.L[name],20,-90-(i-1)*38,146,function() Studio.ShowPage(name) end)
    end
    W.Label(root,"FNP  "..NS.version.."\n\nOriginal layouts\nLive preview\nLocal profiles\n\nArtwork pending",10,28,-324,{.6,.6,.62,1})
end
function Studio.Open()
    if NS.InCombat() then NS.Print(NS.L.combat); return end
    if NS.databaseBlocked then NS.Print("Database version is newer; preserve it before downgrading."); return end
    if not Studio.ready then
        local previous={}; for key,value in pairs(Studio) do previous[key]=value end
        local fonts,surfaces=#W.fonts,#W.surfaces
        local ok,err=pcall(createStudio)
        if not ok then
            if Studio.root then Studio.root:Hide() end
            for key in pairs(Studio) do Studio[key]=nil end
            for key,value in pairs(previous) do Studio[key]=value end
            -- Failed widgets are hidden with their root and must not be retained by skins.
            for i=#W.fonts,fonts+1,-1 do W.fonts[i]=nil end
            for i=#W.surfaces,surfaces+1,-1 do W.surfaces[i]=nil end
            NS.Log("Studio construction failed; incomplete interface discarded.")
            if not NS.Compat.Secret(err) and type(err)=="string" then NS.Log(err); NS.Print(err) end
            NS.Print("Studio could not be built. Try /fnp again; check the installed addon version.")
            return
        end
        Studio.ready=true
        _G.ForeverNameplatesStudio=Studio.root
        UISpecialFrames=UISpecialFrames or {}; table.insert(UISpecialFrames,"ForeverNameplatesStudio")
    end
    Studio.root:Show(); Studio.ShowPage(Studio.page or "studio")
end
