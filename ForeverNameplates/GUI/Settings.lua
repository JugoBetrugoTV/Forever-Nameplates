local _,NS=...
local W=NS.W
local Settings={entries={}}
NS.Settings=Settings
local function add(page,path,en,de,keywords,helpEn,helpDe,kind)
    Settings.entries[#Settings.entries+1]={page=page,path=path,label=W.Tr(en,de),
        terms=en.." "..de.." "..keywords,help=W.Tr(helpEn,helpDe),kind=kind}
end
for _,field in ipairs({{"x","X position / offset","X-Position / Abstand"},{"y","Y position / offset","Y-Position / Abstand"},
    {"width","Width","Breite"},{"height","Height","Höhe"},{"layer","Layer","Ebene"},
    {"fontSize","Font size","Schriftgröße"},{"alpha","Opacity","Deckkraft"}}) do
    add("studio","inspector.fields."..field[1],field[2],field[3],"number slider size groesse größe position alpha",
        "Drag the slider, click +/− or use the mouse wheel. X/Y are offsets for anchored elements; exact values can also be typed.",
        "Regler ziehen, +/− klicken oder Mausrad nutzen. X/Y sind bei verankerten Elementen Abstände; genaue Werte lassen sich eingeben.",
        field[1]=="fontSize" and {"text","class"} or nil)
end
local editor={
    {"visible","Visible","Sichtbar","visibility anzeigen","Activates this component; its unit/cast conditions still apply.","Aktiviert die Komponente; ihre Unit-/Castbedingungen gelten weiter."},
    {"locked","Locked","Gesperrt","lock sperre","Unlock before moving, resizing or editing.","Vor Verschieben, Größenänderung oder Bearbeiten entsperren."},
    {"source","Text source / visibility condition","Textquelle / Sichtbarkeitsbedingung","name level target cast ziel",
        "Choose text content or whether the component appears only on the target/during casts.","Textinhalt oder Anzeige nur am Ziel/während Casts wählen."},
    {"shape","Shape","Form","rectangle diamond brackets segmente","Select the geometry of panels, target marks and decorations.","Geometrie von Panels, Zielmarkern und Dekorationen wählen."},
    {"asset","Font style / texture","Schriftstil / Textur","font artwork grafik","Choose a native style or available imported artwork. FFXIV labels use a fallback font.","Nativen Stil oder importierte Grafik wählen. FFXIV-Labels nutzen eine Ersatzschrift."},
    {"color","Component color","Komponentenfarbe","color farbe","Open the color picker. Native reaction/class/level styles may override the text color.","Farbwähler öffnen. Native Reaktions-/Klassen-/Levelstile können Textfarben ersetzen."},
    {"vertical","Vertical bar","Vertikaler Balken","orientation ausrichtung","Draw health/cast fill vertically.","Health-/Castfüllung vertikal darstellen."},
    {"reverse","Reverse fill","Umgekehrte Füllung","direction richtung","Reverse the fill edge; channels still use remaining-time direction.","Füllkante umkehren; Channels verwenden weiter verbleibende Zeit."},
    {"text","Custom text","Eigener Text","label name text","Used by custom/target text sources. Click away to save; Escape cancels.","Für eigene/zielgebundene Textquellen. Klick übernimmt, Escape verwirft."},
    {"reset","Reset element","Element zurücksetzen","defaults standard","Restore this component's source/preset settings; Undo can recover your edits.","Quellen-/Preseteinstellungen wiederherstellen; Undo holt Änderungen zurück."},
}
local editorKinds={shape={"panel","target","ornament"},asset={"health","cast","text","class","artwork"},
    vertical={"health","cast"},reverse={"health","cast"},text={"text"}}
for _,e in ipairs(editor) do add("studio","inspector."..e[1],e[2],e[3],e[4],e[5],e[6],editorKinds[e[1]]) end
add("studio","previewPicker","Preview state","Vorschauzustand","channel scenario simulation test",
    "Choose a simulated unit or cast state; preview data does not come from the game.",
    "Simulierte Unit oder Castzustand wählen; Vorschaudaten kommen nicht aus dem Spiel.")
add("studio","addButton","Add component","Komponente hinzufügen","class raid aura cast icon","Choose a component; menus with more than eight items have next/previous pages.","Komponente wählen; Menüs mit mehr als acht Einträgen haben Folgeseiten.")
add("studio","elementPicker","Select element","Element wählen","hidden locked versteckt","Select hidden or overlapping elements; right-click canvas overlaps also opens a list.","Versteckte/überlappende Elemente wählen; Rechtsklick auf Canvas-Überlappungen öffnet ebenfalls eine Liste.")
add("studio","gridButton","Snap grid","Einrastraster","snap raster zoom","Toggle the 4 px grid. Alignment actions are exact even with snapping enabled.","4-Pixel-Raster umschalten. Ausrichtungsaktionen bleiben trotz Raster exakt.")
add("studio","gameNameplatePicker","Game nameplates","Spiel-Nameplates","classic dragonflight ffxiv design","Choose a source draft; pending references/assets remain unavailable.","Quellenentwurf wählen; fehlende Referenzen/Assets bleiben nicht auswählbar.")
local anchorHelp={"Bindings follow changes to the referenced component. Switching references preserves position; Snap sets both offsets to zero.",
    "Verknüpfungen folgen Änderungen der Bezugskomponente. Bezugwechsel erhält die Position; An Anker setzen setzt beide Abstände auf null."}
for _,e in ipairs({{"reference","Anchor reference","Ankerbezug"},{"point","Own anchor point","Eigener Ankerpunkt"},
    {"relativePoint","Reference anchor point","Ankerpunkt am Bezug"},{"snap","Snap to anchor","An Anker setzen"}}) do
    add("components","componentUI."..e[1],e[2],e[3],"anchor anker relative health rand",anchorHelp[1],anchorHelp[2])
end
for _,e in ipairs({{"filter","Buff / debuff filter","Buff-/Debuff-Filter"},{"sort","Aura sort","Aura-Sortierung"},
    {"direction","Aura sort direction","Aura-Sortierrichtung"},{"own","Only my auras","Nur eigene Auren"},
    {"cooldown","Aura cooldown swipe","Aura-Cooldownanzeige"},{"limit","Aura icon limit","Aura-Icon-Limit"},
    {"columns","Aura columns","Aura-Spalten"},{"size","Aura icon size","Aura-Icon-Größe"},{"gap","Aura spacing","Aura-Abstand"},
    {"listMode","Aura spell list filter","Aura-Zauberliste filtern"},{"spells","Aura spell IDs","Aura-Zauber-IDs"}}) do
    add("components","componentUI.aura."..e[1],e[2],e[3],"aura debuff buff icon filter sort reihe zauber spell",
        "Select an Aura component. Up to 12 icons; client filtering/sorting, no secret time calculations. Listed IDs filter public spell IDs only.",
        "Aura-Komponente wählen. Bis zu 12 Icons; Clientfilter/-sortierung ohne geheime Zeitrechnung. ID-Listen filtern nur öffentliche Zauber-IDs.","auras")
end
for _,e in ipairs({{"enabled","Cast state colors","Castzustandsfarben"},{"normal","Normal cast color","Normale Castfarbe"},
    {"channel","Channel color","Kanalfarbe"},{"shield","Non-interruptible cast color","Nicht unterbrechbare Castfarbe"},
    {"spark","Cast spark","Cast-Spark"},{"sparkColor","Spark color","Spark-Farbe"},
    {"sparkWidth","Spark width","Spark-Breite"},{"sparkAlpha","Spark opacity","Spark-Deckkraft"}}) do
    add("components","componentUI.cast."..e[1],e[2],e[3],"cast channel interrupt effekt spark farbe",
        "Select a castbar. The spark follows its actual fill texture. Unknown interruptibility does not imply an uninterruptible cast.",
        "Castbar wählen. Spark folgt ihrer tatsächlichen Fülltextur. Unbekannte Unterbrechbarkeit bedeutet keinen nicht unterbrechbaren Cast.","cast")
end
for _,e in ipairs({{"globalMode","Default health color","Standard-Healthfarbe"},{"categoryPicker","Unit category","Unit-Kategorie"},
    {"enabled","Enable unit rule","Unit-Regel aktivieren"},{"visible","Rule visibility","Regelsichtbarkeit"},
    {"alpha","Rule opacity","Regeldeckkraft"},{"scale","Rule scale","Regelskalierung"},{"colorMode","Rule color mode","Regelfarbmodus"}}) do
    add("rules","ruleUI."..e[1],e[2],e[3],"rule regeln player npc target class reaction farbe",
        "Rules apply in order: unit category, classification, target/other. Later enabled rules replace earlier appearance settings.",
        "Regelreihenfolge: Unit-Kategorie, Klassifikation, Ziel/andere. Spätere aktive Regeln ersetzen frühere Darstellungseinstellungen.")
end
for _,e in ipairs({{"friendlyColor","Friendly health color","Freundliche Healthfarbe"},
    {"neutralColor","Neutral health color","Neutrale Healthfarbe"},{"hostileColor","Hostile health color","Feindliche Healthfarbe"},
    {"fixedColor","Rule fixed color","Feste Regelfarbe"}}) do
    add("rules","ruleUI."..e[1],e[2],e[3],"color farbe reaction reaktion fixed",
        "Open the color picker. Reaction colors apply in Reaction mode; the fixed color applies to the selected category in Fixed mode.",
        "Farbwähler öffnen. Reaktionsfarben gelten im Reaktionsmodus; die feste Farbe gilt für die gewählte Kategorie im Fixed-Modus.")
end
for _,e in ipairs({{"profilePicker","Active profile","Aktives Profil"},{"createProfile","Create profile copy","Profilkopie erstellen"},
    {"character","Character profile","Charakterprofil"},{"deleteProfile","Delete profile","Profil löschen"},{"resetProfile","Reset profile","Profil zurücksetzen"},
    {"shareBox","Share code","Austauschcode"}}) do
    add("profiles",e[1],e[2],e[3],"profile profil copy export import share backup",
        "Profiles save your layout. New features use FN3 codes; older FN1/FN2 imports remain supported. Export before a client restart.",
        "Profile speichern das Layout. Neue Funktionen nutzen FN3; FN1/FN2 bleiben importierbar. Vor Client-Neustart exportieren.")
end
add("diagnostics","live","Live application","Live-Anwendung","apply blizzard anwenden","Apply your layout to permitted nameplates; Off restores Blizzard visuals.","Layout auf zulässige Nameplates anwenden; Aus stellt Blizzard wieder her.")
add("diagnostics","minimapVisible","Minimap icon","Minimap-Icon","map karte icon sichtbar","Show/hide the launcher; drag it around the minimap to position it.","Starter ein-/ausblenden; zum Positionieren am Minimap-Rand ziehen.")
add("diagnostics","minimapAngle","Minimap position","Minimap-Position","map karte winkel angle","Set the angle around the minimap. 360 degrees wraps to zero.","Winkel um die Minimap einstellen. 360 Grad wird zu null.")
function Settings.Control(entry)
    local object=NS.Studio
    for key in entry.path:gmatch("[^.]+") do object=object and object[key] end
    return object
end
local function lower(text)
    return string.lower((text:gsub("Ä","ä"):gsub("Ö","ö"):gsub("Ü","ü"):gsub("ẞ","ss"):gsub("ß","ss")))
end
function Settings.Find(query)
    local words={}; for word in lower(query or ""):gmatch("%S+") do words[#words+1]=word end
    local matches={}
    for _,entry in ipairs(Settings.entries) do
        local text=lower(entry.terms); local match=true
        for _,word in ipairs(words) do if not text:find(word,1,true) then match=false; break end end
        if match then matches[#matches+1]=entry end
    end
    return matches
end
function Settings.Bind(page)
    for _,entry in ipairs(Settings.entries) do
        if entry.page==page then
            local control=Settings.Control(entry)
            if control then
                local help=entry.help
                if control.bounds then help=help.."\n"..W.Tr("Range: ","Bereich: ")..control.bounds end
                W.Help(control,entry.label,help)
                if control.slider then
                    W.Help(control.slider,entry.label,help); W.Help(control.minus,entry.label,help); W.Help(control.plus,entry.label,help)
                end
            end
        end
    end
end
function Settings.Open(entry)
    local studio=NS.Studio
    if NS.InCombat() then return false end
    local function accepts(kind)
        if type(entry.kind)=="table" then for _,value in ipairs(entry.kind) do if value==kind then return true end end; return false end
        return entry.kind==kind
    end
    if entry.kind and not accepts(studio.session:Element().kind) then
        for _,e in ipairs(studio.session.layout.elements) do if accepts(e.kind) then studio.Select(e.id); break end end
    end
    if not studio.ShowPage(entry.page) then return false end
    local control=Settings.Control(entry)
    if not control then return false end
    if not control.searchMark then
        control.searchMark=control:CreateTexture(nil,"OVERLAY"); control.searchMark:SetAllPoints(control)
        control.searchMark:SetColorTexture(1,.8,.3,.25)
    end
    control.searchMark:Show()
    if C_Timer and C_Timer.After then C_Timer.After(2,function() control.searchMark:Hide() end) end
    return true
end
