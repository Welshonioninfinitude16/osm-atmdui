-- Qbox Client Bridge Adapter
-- Qbox is QBCore-based but uses ox_inventory and ox_lib

if Bridge.Framework ~= 'qbox' then return end

local QBX = exports['qbx_core']:GetCoreObject()

-- Get player data
function Bridge.GetPlayerData()
    local PlayerData = QBX.Functions.GetPlayerData()
    if not PlayerData then return nil end
    
    return {
        identifier = PlayerData.citizenid,
        name = PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname,
        cash = PlayerData.money.cash or 0,
        bank = PlayerData.money.bank or 0,
        job = PlayerData.job,
        gang = PlayerData.gang,
    }
end

-- Show notification (uses ox_lib)
function Bridge.Notify(message, type)
    lib.notify({
        title = 'ATM',
        description = message,
        type = type or 'info',
    })
end

-- Check if player has item (ox_inventory)
function Bridge.HasItem(itemName)
    local count = exports.ox_inventory:Search('count', itemName)
    return count and count > 0
end

-- Get item data (for bank card PIN)
function Bridge.GetItemData(itemName)
    local items = exports.ox_inventory:Search('slots', itemName)
    if items and #items > 0 then
        return items[1].metadata
    end
    return nil
end

-- Trigger server callback (uses ox_lib)
function Bridge.TriggerCallback(name, cb, ...)
    local result = lib.callback.await(name, false, ...)
    if cb then cb(result) end
    return result
end

Bridge.Ready = true
