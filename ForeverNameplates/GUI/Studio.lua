local _, NS = ...
local W,R=NS.W,NS.Renderer
local Studio={zoom=1,scenario=1,handles={}}
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
function Studio.RefreshInspector()
    local e=Studio.session:Element()
    if not e or not Studio.inspector then return end
    Studio.inspector.title:SetText(e.id.."  /  "..e.kind)
    for key,edit in pairs(Studio.inspector.fields) do edit:SetText(tostring(e[key])) end
    Studio.inspector.visible:SetValue(e.enabled); Studio.inspector.locked:SetValue(e.locked)
    Studio.inspector.vertical:SetValue(e.vertical); Studio.inspector.reverse:SetValue(e.reverse)
    Studio.inspector.source.label:SetText("Source: "..e.source)
    Studio.inspector.shape.label:SetText("Shape: "..e.shape)
    Studio.inspector.source:SetEnabled(e.kind=="text")
    Studio.inspector.shape:SetEnabled(e.kind=="ornament" or e.kind=="panel" or e.kind=="target")
    Studio.inspector.vertical:SetEnabled(e.kind=="health" or e.kind=="cast")
    Studio.inspector.reverse:SetEnabled(e.kind=="health" or e.kind=="cast")
    Studio.inspector.fields.fontSize:SetEnabled(e.kind=="text")
end
function Studio.Change(patch)
    if attempt(Studio.session:Update(Studio.session.selected,patch)) then Studio.Refresh() end
end
function Studio.EndDrag(commit)
    local d=Studio.drag
    if not d then return end
    Studio.canvas:SetScript("OnUpdate",nil); Studio.drag=nil
    if commit and not NS.InCombat() then
        local x,y=GetCursorPosition(); local scale=Studio.view.root:GetEffectiveScale()
        attempt(Studio.session:Move(d.id,d.x+(x-d.cursorX)/scale,d.y+(y-d.cursorY)/scale))
    end
    Studio.Refresh()
end
function Studio.RefreshHandles()
    if not Studio.canvas then return end
    for _,h in ipairs(Studio.handles) do h:Hide() end
    for i,e in ipairs(Studio.session.layout.elements) do
        local h=Studio.handles[i]
        if not h then
            h=CreateFrame("Button",nil,Studio.view.root); h:RegisterForDrag("LeftButton")
            local mark=h:CreateTexture(nil,"OVERLAY"); mark:SetAllPoints(h); mark:SetColorTexture(.9,.7,.3,.2); h.mark=mark
            h:SetScript("OnClick",function(self) Studio.Select(self.element.id) end)
            h:SetScript("OnDragStart",function(self)
                local item=self.element
                if NS.InCombat() or item.locked then return end
                Studio.Select(item.id)
                local x,y=GetCursorPosition()
                Studio.drag={id=item.id,x=item.x,y=item.y,cursorX=x,cursorY=y,handle=self}
                Studio.canvas:SetScript("OnUpdate",function()
                    if NS.InCombat() then Studio.EndDrag(false); return end
                    local cx,cy=GetCursorPosition(); local s=Studio.view.root:GetEffectiveScale()
                    local dx,dy=item.x+(cx-x)/s,item.y+(cy-y)/s
                    self:ClearAllPoints(); self:SetPoint("CENTER",Studio.view.root,"CENTER",dx,dy)
                    for _,part in ipairs(Studio.view.parts) do
                        if part.element.id==item.id then part.frame:ClearAllPoints(); part.frame:SetPoint("CENTER",Studio.view.root,"CENTER",dx,dy) end
                    end
                end)
            end)
            h:SetScript("OnDragStop",function() Studio.EndDrag(true) end)
            Studio.handles[i]=h
        end
        h.element=e; h:SetSize(math.max(10,e.width),math.max(10,e.height))
        h:ClearAllPoints(); h:SetPoint("CENTER",Studio.view.root,"CENTER",e.x,e.y)
        h:SetFrameLevel(Studio.view.root:GetFrameLevel()+25+e.layer)
        h.mark:SetShown(e.id==Studio.session.selected); h:SetShown(e.enabled and (e.kind~="artwork" or NS.Media.files[e.asset]~=nil))
    end
end
function Studio.Refresh()
    if not Studio.session then return end
    R.Apply(Studio.view,Studio.session.layout)
    R.Update(Studio.view,Studio.scenarios[Studio.scenario])
    Studio.view.root:SetScale(Studio.zoom)
    Studio.RefreshHandles(); Studio.RefreshInspector(); Studio.Status()
end
function Studio.ShowPage(name)
    if NS.InCombat() then NS.Print(NS.L.combat); return end
    for key,page in pairs(Studio.pages) do page:SetShown(key==name) end
    Studio.page=name
    if name=="studio" then Studio.Refresh() end
    if name=="profiles" then Studio.RefreshProfiles() end
    if name=="diagnostics" then Studio.RefreshDiagnostics() end
end
local function makePage(root)
    local p=CreateFrame("Frame",nil,root); p:SetSize(872,566); p:SetPoint("TOPLEFT",182,-76); return p
end
function Studio.CreateGallery(page)
    W.Label(page,NS.L.gallery,22,0,0)
    W.Label(page,"Twelve silhouettes. Original procedural placeholders; artwork pending.",11,0,-32)
    for index,preset in ipairs(NS.Presets) do
        local x=((index-1)%3)*288; local y=-58-math.floor((index-1)/3)*124
        local card=W.Button(page,"",x,y,278,function()
            if NS.InCombat() then NS.Print(NS.L.combat); return end
            if attempt(NS.DB.Save(preset.layout)) then Studio.LoadSession(); Studio.ShowPage("studio") end
        end)
        card:SetHeight(114); W.Line(card,0,0,278)
        W.Label(card,preset.layout.name,12,12,-10)
        W.Label(card,preset.description,9,12,-94)
        local view=R.Create(card); view.root:SetPoint("CENTER",card,"CENTER",0,-4); view.root:SetScale(.65)
        R.Apply(view,preset.layout); R.Update(view,{name="",health=72,healthText="",target=false,casting=false,castName=""})
    end
end
function Studio.CreateEditor(page)
    W.Label(page,NS.L.studio,22,0,0)
    local canvas=CreateFrame("Frame",nil,page); canvas:SetSize(590,416); canvas:SetPoint("TOPLEFT",0,-48); W.Paint(canvas,"bg")
    Studio.canvas=canvas
    W.Label(canvas,NS.L.preview,10,14,-12,{.65,.64,.6,1})
    for i=1,23 do
        local line=canvas:CreateTexture(nil,"BACKGROUND"); line:SetColorTexture(.2,.23,.3,.18)
        line:SetSize(1,368); line:SetPoint("TOPLEFT",12+i*24,-34)
    end
    for i=1,15 do
        local line=canvas:CreateTexture(nil,"BACKGROUND"); line:SetColorTexture(.2,.23,.3,.18)
        line:SetSize(566,1); line:SetPoint("TOPLEFT",12,-34-i*24)
    end
    Studio.view=R.Create(canvas); Studio.view.root:SetPoint("CENTER",canvas,"CENTER",0,0)
    W.Button(page,NS.L.undo,0,-478,88,function() attempt(Studio.session:Undo()); Studio.Refresh() end)
    W.Button(page,NS.L.redo,96,-478,88,function() attempt(Studio.session:Redo()); Studio.Refresh() end)
    W.Button(page,"−",194,-478,30,function() Studio.zoom=math.max(.5,Studio.zoom-.25); Studio.Refresh() end)
    W.Button(page,"+",232,-478,30,function() Studio.zoom=math.min(2,Studio.zoom+.25); Studio.Refresh() end)
    W.Button(page,"Grid: 4 px / off",270,-478,138,function() Studio.session.snap=Studio.session.snap==0 and 4 or 0; Studio.Status("Snap: "..Studio.session.snap.." px") end)
    W.Button(page,"Preview state",416,-478,174,function()
        Studio.scenario=Studio.scenario%#Studio.scenarios+1; Studio.Refresh()
    end)
    W.Label(page,"Drag elements on the canvas. Changes save to the active profile.",11,0,-518)
    local inspector=CreateFrame("Frame",nil,page); inspector:SetSize(258,486); inspector:SetPoint("TOPLEFT",610,-48); W.Paint(inspector,"panel")
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
        local e=Studio.session:Element(); local id=e.id
        W.Color(e.color,function(color) if attempt(Studio.session:Update(id,{color=color})) then Studio.Refresh() end end)
    end)
    Studio.inspector.visible=W.Toggle(inspector,"Visible",12,-274,110,true,function(v) Studio.Change({enabled=v}) end)
    Studio.inspector.locked=W.Toggle(inspector,"Locked",130,-274,116,false,function(v) Studio.Change({locked=v}) end)
    Studio.inspector.vertical=W.Toggle(inspector,"Vertical",12,-306,110,false,function(v) Studio.Change({vertical=v}) end)
    Studio.inspector.reverse=W.Toggle(inspector,"Reverse",130,-306,116,false,function(v) Studio.Change({reverse=v}) end)
    Studio.inspector.source=W.Button(inspector,"Source",12,-338,234,function()
        local options={"name","health","level","cast","static"}; local e=Studio.session:Element()
        for i,v in ipairs(options) do if e.source==v then Studio.Change({source=options[i%#options+1]}); break end end
    end)
    Studio.inspector.shape=W.Button(inspector,"Shape",12,-370,234,function()
        local options={"rect","diamond","rune","brackets","segments"}; local e=Studio.session:Element()
        for i,v in ipairs(options) do if e.shape==v then Studio.Change({shape=options[i%#options+1]}); break end end
    end)
    W.Button(inspector,"Copy",12,-406,70,function() Studio.session:Copy() end)
    W.Button(inspector,"Paste",90,-406,70,function() attempt(Studio.session:Paste()); Studio.Refresh() end)
    W.Button(inspector,"Delete",168,-406,78,function() attempt(Studio.session:Delete()); Studio.Refresh() end)
    W.Button(inspector,"Reset element",12,-442,110,function() attempt(Studio.session:ResetElement()); Studio.Refresh() end)
    W.Edit(inspector,130,-442,116,"Static text",function(value) Studio.Change({text=value}) end)
end
function Studio.RefreshProfiles()
    local names={}; for name in pairs(NS.DB.data.profiles) do names[#names+1]=name end; table.sort(names)
    Studio.profileNames=names
    Studio.profileList:SetText("Active: "..NS.DB.CurrentName().."\n\n"..table.concat(names,"\n"))
    Studio.character:SetValue(NS.DB.character and NS.DB.data.characters[NS.DB.character]~=nil or false)
end
function Studio.CreateProfiles(page)
    W.Label(page,NS.L.profiles,22,0,0)
    Studio.profileList=W.Label(page,"",12,0,-52); Studio.profileList:SetWidth(220)
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
    edit:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",11); edit:SetMaxLetters(48000); W.Paint(edit,"bg")
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
function Studio.Open()
    if NS.InCombat() then NS.Print(NS.L.combat); return end
    if NS.databaseBlocked then NS.Print("Database version is newer; preserve it before downgrading."); return end
    if not Studio.root then
        Studio.LoadSession()
        local root=CreateFrame("Frame","ForeverNameplatesStudio",UIParent); root:SetSize(1080,680); root:SetPoint("CENTER")
        root:SetFrameStrata("DIALOG"); root:EnableMouse(true); root:SetMovable(true); root:RegisterForDrag("LeftButton"); W.Paint(root,"bg")
        root:SetScale(math.min(1,(UIParent:GetWidth()-40)/1080,(UIParent:GetHeight()-40)/680))
        root:SetScript("OnDragStart",function(self) if not NS.InCombat() then self:StartMoving() end end)
        root:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
        root:SetScript("OnHide",function() Studio.EndDrag(false) end)
        Studio.root=root
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
            for i,v in ipairs(options) do if W.skin==v then W.Skin(options[i%3+1]); break end end
        end)
        Studio.status=W.Label(root,"",10,490,-648)
        Studio.pages={}
        for _,name in ipairs({"gallery","studio","profiles","diagnostics"}) do Studio.pages[name]=makePage(root) end
        Studio.CreateGallery(Studio.pages.gallery); Studio.CreateEditor(Studio.pages.studio)
        Studio.CreateProfiles(Studio.pages.profiles); Studio.CreateDiagnostics(Studio.pages.diagnostics)
        for i,name in ipairs({"gallery","studio","profiles","diagnostics"}) do
            W.Button(root,NS.L[name],20,-90-(i-1)*38,146,function() Studio.ShowPage(name) end)
        end
        W.Label(root,"FNP  0.1\n\nOriginal layouts\nLive preview\nLocal profiles\n\nArtwork pending",10,28,-294,{.6,.6,.62,1})
        UISpecialFrames=UISpecialFrames or {}; table.insert(UISpecialFrames,"ForeverNameplatesStudio")
    end
    Studio.root:Show(); Studio.ShowPage(Studio.page or "gallery")
end
