local _,NS=...
local S,W=NS.Studio,NS.W
function S.ComponentPreview(layout)
    local ui=S.componentUI; if not ui or not ui.view then return end
    layout=layout or S.session.layout
    local positions=NS.Features.Positions(layout)
    local left,right,bottom,top=0,1,0,1
    for _,e in ipairs(layout.elements) do if e.enabled then
        local p=positions[e.id]
        left=math.min(left,p.x-e.width/2); right=math.max(right,p.x+e.width/2)
        bottom=math.min(bottom,p.y-e.height/2); top=math.max(top,p.y+e.height/2)
    end end
    ui.view.previewScale=math.min(.7,600/(right-left),54/(top-bottom))
    ui.view.root:ClearAllPoints(); ui.view.root:SetPoint("CENTER",ui.preview,"CENTER",-(left+right)/2*ui.view.previewScale,-(bottom+top)/2*ui.view.previewScale)
    NS.Renderer.Apply(ui.view,layout); NS.Renderer.Update(ui.view,S.scenarios[S.scenario])
end
local function preview(key,field,value)
    if value==nil then S.ComponentPreview(); return end
    local layout=NS.Copy(S.session.layout); local _,index=S.session:Element()
    local e=layout.elements[index]
    e[key]=NS.Copy(e[key] or (key=="aura" and NS.Features.AuraDefaults() or NS.Features.CastDefaults()))
    e[key][field]=value
    if key=="aura" then e.width,e.height=NS.Features.AuraSize(e[key]) end
    if NS.Model.Validate(layout) then S.ComponentPreview(layout) end
end
local function change(key,patch)
    local ok,err=S.session:UpdateFeature(key,patch)
    if not ok then NS.Print(err) end
    S.Refresh(); return ok==true
end
local function anchor(ref,point,relative,snap)
    local ok,err=S.session:SetAnchor(ref,point,relative,snap)
    if not ok then NS.Print(err) end
    S.Refresh(); return ok==true
end
function S.RefreshComponents()
    local ui=S.componentUI; if not ui then return end
    local e=S.session:Element(); local a=e.anchor or {ref="",point="CENTER",relativePoint="CENTER"}
    ui.picker:SetValue(e.id); ui.reference:SetValue(a.ref); ui.point:SetValue(a.point); ui.relativePoint:SetValue(a.relativePoint)
    ui.reference:SetEnabled(not e.locked); ui.point:SetEnabled(not e.locked and e.anchor~=nil)
    ui.relativePoint:SetEnabled(not e.locked and e.anchor~=nil); ui.snap:SetEnabled(not e.locked and e.anchor~=nil)
    ui.offsets:SetText(W.Tr("X/Y in Layout Studio are anchor offsets. Detaching preserves position.",
        "X/Y im Layout-Studio sind Ankerabstände. Ablösen erhält die Position."))
    local aura=e.aura or NS.Features.AuraDefaults()
    for key,control in pairs(ui.aura) do
        if key=="limit" or key=="columns" or key=="size" or key=="gap" or key=="spells" then control:SetText(tostring(aura[key]))
        else control:SetValue(aura[key]) end
        control:SetEnabled(not e.locked and e.kind=="auras")
    end
    local cast=e.castStyle or NS.Features.CastDefaults()
    for key,control in pairs(ui.cast) do
        if key=="sparkWidth" or key=="sparkAlpha" then control:SetText(tostring(cast[key]))
        elseif key=="enabled" or key=="spark" then control:SetValue(cast[key]) end
        control:SetEnabled(not e.locked and e.kind=="cast")
    end
    ui.status:SetText(NS.Compat.auraReason or W.Tr("Aura sorting uses the client. Missing/secret icons stay hidden.",
        "Aura-Sortierung übernimmt der Client. Fehlende/geheime Icons bleiben verborgen."))
    ui.previewPicker:SetValue(S.scenario); S.ComponentPreview()
end
function S.CreateComponents(page)
    local tr=W.Tr
    W.Label(page,tr("Anchors, auras & casts","Anker, Auren & Casts"),22,0,0)
    local ui={aura={},cast={}}; S.componentUI=ui
    ui.picker=W.Dropdown(page,0,-40,350,function()
        local choices={}; for _,e in ipairs(S.session.layout.elements) do choices[#choices+1]={value=e.id,label=e.id.." ["..e.kind.."]"} end
        return choices
    end,function(id) S.Select(id); S.RefreshComponents() end)
    W.Label(page,tr("Select a component; settings apply to that element.","Komponente wählen; Einstellungen gelten für dieses Element."),11,380,-46)
    W.Label(page,tr("Relative anchor","Relativer Anker"),14,0,-85)
    ui.reference=W.Dropdown(page,0,-110,270,function()
        local choices={{value="",label=tr("Plate center / absolute","Plate-Mitte / absolut")}}
        for _,e in ipairs(S.session.layout.elements) do if e.id~=S.session.selected then choices[#choices+1]={value=e.id,label=e.id} end end
        return choices
    end,function(ref) local a=S.session:Element().anchor; return anchor(ref,a and a.point or "LEFT",a and a.relativePoint or "RIGHT") end)
    local points={}; for _,point in ipairs(NS.Features.pointNames) do points[#points+1]={value=point,label=point} end
    ui.point=W.Dropdown(page,0,-148,270,points,function(point)
        local a=S.session:Element().anchor; if a then return anchor(a.ref,point,a.relativePoint) end; return false
    end)
    ui.relativePoint=W.Dropdown(page,0,-186,270,points,function(point)
        local a=S.session:Element().anchor; if a then return anchor(a.ref,a.point,point) end; return false
    end)
    ui.snap=W.Button(page,tr("Snap to anchor (zero offsets)","An Anker setzen (Abstand null)"),0,-224,270,function()
        local a=S.session:Element().anchor; if a then anchor(a.ref,a.point,a.relativePoint,true) end
    end)
    ui.offsets=W.Label(page,"",11,0,-270); ui.offsets:SetWidth(270)
    W.Button(page,tr("Edit position / size","Position / Größe bearbeiten"),0,-330,270,function() S.ShowPage("studio") end)
    ui.status=W.Label(page,"",11,0,-405); ui.status:SetWidth(270)
    W.Label(page,tr("Aura / debuff icons","Aura-/Debuff-Icons"),14,302,-85)
    ui.aura.filter=W.Dropdown(page,302,-110,270,{{value="HARMFUL",label=tr("Debuffs","Debuffs")},{value="HELPFUL",label=tr("Buffs","Buffs")}},function(v) return change("aura",{filter=v}) end)
    ui.aura.sort=W.Dropdown(page,302,-148,270,{{value="Unsorted",label=tr("Client order","Client-Reihenfolge")},
        {value="ExpirationOnly",label=tr("Expiration time","Ablaufzeit")},{value="NameOnly",label=tr("Spell name","Zaubername")}},function(v) return change("aura",{sort=v}) end)
    ui.aura.direction=W.Dropdown(page,302,-186,270,{{value="Normal",label=tr("Normal order","Normale Reihenfolge")},
        {value="Reverse",label=tr("Reverse order","Umgekehrte Reihenfolge")}},function(v) return change("aura",{direction=v}) end)
    ui.aura.own=W.Toggle(page,tr("Only mine","Nur eigene"),302,-224,130,false,function(v) change("aura",{own=v}) end)
    ui.aura.cooldown=W.Toggle(page,tr("Cooldown","Cooldown"),442,-224,130,true,function(v) change("aura",{cooldown=v}) end)
    local ranges={limit={1,12},columns={1,12},size={8,32},gap={0,8}}
    local labels={limit=tr("Icon limit","Icon-Limit"),columns=tr("Columns","Spalten"),size=tr("Icon size","Icon-Größe"),gap=tr("Spacing","Abstand")}
    for i,key in ipairs({"limit","columns","size","gap"}) do
        local x=302+((i-1)%2)*140; local y=-260-math.floor((i-1)/2)*56
        W.Label(page,labels[key],11,x,y)
        ui.aura[key]=W.Number(page,x,y-18,130,"1",ranges[key][1],ranges[key][2],1,function(v) return change("aura",{[key]=tonumber(v) or -1}) end,
            function(value) preview("aura",key,value) end)
    end
    ui.aura.listMode=W.Dropdown(page,302,-392,270,{{value="all",label=tr("All spells","Alle Zauber")},
        {value="include",label=tr("Only listed spell IDs","Nur gelistete Zauber-IDs")},{value="exclude",label=tr("Hide listed spell IDs","Gelistete Zauber-IDs ausblenden")}},function(v) return change("aura",{listMode=v}) end)
    W.Label(page,tr("Spell IDs, separated by commas","Zauber-IDs, durch Komma getrennt"),10,302,-425)
    ui.aura.spells=W.Edit(page,302,-443,270,"",function(v) change("aura",{spells=v}) end,true); ui.aura.spells:SetMaxLetters(240)
    W.Label(page,tr("Cast states & spark","Castzustände & Spark"),14,600,-85)
    ui.cast.enabled=W.Toggle(page,tr("Use state colors","Zustandsfarben verwenden"),600,-110,262,false,function(v) change("castStyle",{enabled=v}) end)
    local colors={normal=tr("Normal cast color","Normale Castfarbe"),channel=tr("Channel color","Kanalfarbe"),
        shield=tr("Non-interruptible color","Nicht unterbrechbar: Farbe"),sparkColor=tr("Spark color","Spark-Farbe")}
    for i,key in ipairs({"normal","channel","shield","sparkColor"}) do
        local y=key=="sparkColor" and -300 or -148-(i-1)*38
        ui.cast[key]=W.Button(page,colors[key],600,y,262,function()
            local session,id=S.session,S.session.selected
            local c=session:Element().castStyle or NS.Features.CastDefaults()
            W.Color(c[key],function(color)
                if S.session~=session then return end
                local ok,err=session:UpdateFeature("castStyle",{[key]=color},id)
                if not ok then NS.Print(err) end; S.Refresh()
            end)
        end)
    end
    ui.cast.spark=W.Toggle(page,tr("Show cast spark","Cast-Spark anzeigen"),600,-262,262,false,function(v) change("castStyle",{spark=v}) end)
    W.Label(page,tr("Spark width","Spark-Breite"),11,600,-340); W.Label(page,tr("Spark opacity","Spark-Deckkraft"),11,740,-340)
    ui.cast.sparkWidth=W.Number(page,600,-358,122,"8",1,32,1,function(v) return change("castStyle",{sparkWidth=tonumber(v) or -1}) end,
        function(value) preview("castStyle","sparkWidth",value) end)
    ui.cast.sparkAlpha=W.Number(page,740,-358,122,"1",0,1,.01,function(v) return change("castStyle",{sparkAlpha=tonumber(v) or -1}) end,
        function(value) preview("castStyle","sparkAlpha",value) end)
    W.Label(page,tr("Native spark follows the bar texture.\nUnknown interruptibility uses normal/channel color.",
        "Nativer Spark folgt der Balkentextur.\nUnbekannte Unterbrechbarkeit nutzt Cast-/Kanalfarbe."),11,600,-414)
    ui.preview=CreateFrame("Frame",nil,page); ui.preview:SetSize(632,74); ui.preview:SetPoint("TOPLEFT",230,-488)
    W.Paint(ui.preview,"bg"); ui.preview:SetClipsChildren(true); ui.view=NS.Renderer.Create(ui.preview)
    W.Button(page,NS.L.undo,0,-488,100,function() S.session:Undo(); S.Refresh() end)
    W.Button(page,NS.L.redo,110,-488,100,function() S.session:Redo(); S.Refresh() end)
    ui.previewPicker=W.Dropdown(page,0,-530,210,function()
        local choices={}; for i,state in ipairs(S.scenarios) do choices[#choices+1]={value=i,label=state.name} end; return choices
    end,function(value) S.scenario=value; S.Refresh() end)
end
function S.RefreshSearch(reset)
    local ui=S.searchUI; if not ui then return end
    if reset then ui.page=1 end
    local entries=NS.Settings.Find(ui.query:GetText())
    ui.page=math.max(1,math.min(ui.page,math.max(1,math.ceil(#entries/10))))
    for i,button in ipairs(ui.results) do
        local entry=entries[(ui.page-1)*10+i]
        button:SetShown(entry~=nil); button.entry=entry
        if entry then button.label:SetText(NS.L[entry.page].."  /  "..entry.label); W.Help(button,entry.label,entry.help) end
    end
    ui.previous:SetEnabled(ui.page>1); ui.next:SetEnabled(ui.page*10<#entries)
    ui.count:SetText(#entries..W.Tr(" settings / page "," Einstellungen / Seite ")..ui.page)
end
function S.SearchCommand(value)
    if not S.ShowPage("search") then return end
    S.searchUI.query:SetText(value or ""); S.RefreshSearch(true)
end
function S.CreateSearch(page)
    W.Label(page,NS.L.search,22,0,0)
    local ui={page=1,results={}}; S.searchUI=ui
    ui.query=W.Edit(page,0,-42,600,"",function() S.RefreshSearch(true) end)
    ui.query:SetScript("OnTextChanged",function() S.RefreshSearch(true) end)
    W.Button(page,NS.L.search,614,-42,248,function() S.RefreshSearch(true) end)
    for i=1,10 do
        local button=W.Button(page,"",0,-90-(i-1)*36,862,function(self) if self.entry then NS.Settings.Open(self.entry) end end)
        ui.results[i]=button
    end
    ui.previous=W.Button(page,"‹",0,-492,100,function() ui.page=ui.page-1; S.RefreshSearch() end)
    ui.next=W.Button(page,"›",110,-492,100,function() ui.page=ui.page+1; S.RefreshSearch() end)
    ui.count=W.Label(page,"",11,230,-500)
    W.Help(ui.query,NS.L.search,W.Tr("Find settings by name or keyword. Click a result to open and highlight its control.",
        "Einstellungen nach Name oder Stichwort finden. Treffer klicken öffnet und markiert das Control."))
end
