local addonName, NS = ...
NS.name = "Forever Nameplates"
NS.version = "0.6.2"
NS.folder = addonName
NS.logs = {}
NS.listeners = {}

function NS.Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = NS.Copy(item) end
    return result
end

function NS.On(event, callback)
    NS.listeners[event] = NS.listeners[event] or {}
    table.insert(NS.listeners[event], callback)
end

function NS.Emit(event, ...)
    for _, callback in ipairs(NS.listeners[event] or {}) do callback(...) end
end

function NS.Log(message)
    table.insert(NS.logs, message)
    if #NS.logs > 50 then table.remove(NS.logs, 1) end
end

function NS.Print(message)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffd6b978Forever Nameplates|r: " .. message) end
end

function NS.InCombat()
    return InCombatLockdown and InCombatLockdown() or false
end
