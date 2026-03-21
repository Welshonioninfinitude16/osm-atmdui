-- Qbox Client Bridge Adapter
-- Qbox exposes direct exports and keeps player state in qbx_core.

if Bridge.Framework ~= 'qbox' then return end

local qbx = exports.qbx_core

---Returns normalized player data for the ATM UI.
function Bridge.GetPlayerData()
    local playerData = qbx:GetPlayerData()
    if not playerData then return nil end

    local charinfo = playerData.charinfo or {}
    local money = playerData.money or {}
    local firstName = charinfo.firstname or ''
    local lastName = charinfo.lastname or ''
    local fullName = (firstName .. ' ' .. lastName):gsub('^%s*(.-)%s*$', '%1')

    return {
        identifier = playerData.citizenid,
        name = fullName ~= '' and fullName or 'Unknown',
        cash = money.cash or 0,
        bank = money.bank or 0,
        job = playerData.job,
        gang = playerData.gang,
    }
end

---Shows a Qbox notification.
function Bridge.Notify(message, type)
    qbx:Notify(message, type or 'inform')
end

---Checks the local player's inventory for an item.
function Bridge.HasItem(itemName)
    local count = exports.ox_inventory:Search('count', itemName)
    return count and count > 0 or false
end

---Returns metadata from the first matching inventory slot.
function Bridge.GetItemData(itemName)
    local items = exports.ox_inventory:Search('slots', itemName)
    if items and #items > 0 then
        return items[1].metadata or items[1].info
    end

    return nil
end

---Triggers an ox_lib server callback.
function Bridge.TriggerCallback(name, cb, ...)
    local result = lib.callback.await(name, false, ...)
    if cb then cb(result) end

    return result
end

Bridge.Ready = true
