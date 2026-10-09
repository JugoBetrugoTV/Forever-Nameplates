local _, NS = ...
local de = GetLocale and GetLocale() == "deDE"
local messages = {
    title = {"Forever Nameplates", "Forever Nameplates"},
    gallery = {"Preset Gallery", "Preset-Galerie"},
    studio = {"Layout Studio", "Layout-Studio"},
    sandbox = {"Design Sandbox", "Design-Vorschau"},
    confirm = {"Confirm", "Bestätigen"}, cancel = {"Cancel", "Abbrechen"},
    rules = {"Unit Rules", "Einheiten-Regeln"},
    profiles = {"Profiles & Sharing", "Profile & Austausch"},
    diagnostics = {"Diagnostics", "Diagnose"},
    components = {"Anchors / Auras / Casts", "Anker / Auren / Casts"},
    search = {"Search", "Suche"},
    combat = {"Editing paused during combat.", "Bearbeitung im Kampf pausiert."},
    apply = {"Apply layout", "Layout anwenden"},
    undo = {"Undo", "Rückgängig"}, redo = {"Redo", "Wiederholen"},
    preview = {"DESIGN SANDBOX", "DESIGN-VORSCHAU"},
    live = {"Apply layout to nameplates", "Layout auf Nameplates anwenden"},
    pending = {"Forever API and in-game validation pending", "Forever-API und Ingame-Test ausstehend"},
    minimapOpen = {"Left click: open / close the designer", "Linksklick: Designer öffnen / schließen"},
    minimapDiagnostics = {"Right click: diagnostics", "Rechtsklick: Diagnose"},
    minimapDrag = {"Drag: move around the minimap", "Ziehen: Position an der Minimap ändern"},
}
NS.L = setmetatable({}, {__index = function(_, key)
    return messages[key] and messages[key][de and 2 or 1] or key
end})
