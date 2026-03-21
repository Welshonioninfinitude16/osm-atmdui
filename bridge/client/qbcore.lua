-- QBCore Client Bridge Adapter

local _print = print
local print = function(...)
    if Config.Debug then _print(...) end
end

print('^3[atm-dui] Loading QBCore client adapter, Bridge.Framework = ' .. tostring(Bridge.Framework) .. '^0')

if Bridge.Framework ~= 'qbcore' then 
    print('^3[atm-dui] Skipping QBCore client adapter^0')
    return 
end

print('^2[atm-dui] Initializing QBCore client adapter^0')

local QBCore = exports['qb-core']:GetCoreObject()

-- Get player data
function Bridge.GetPlayerData()
    local PlayerData = QBCore.Functions.GetPlayerData()
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

-- Show notification
function Bridge.Notify(message, type)
    QBCore.Functions.Notify(message, type or 'primary')
end

-- Check if player has item
function Bridge.HasItem(itemName)
    return QBCore.Functions.HasItem(itemName)
end

-- Get item data (for bank card PIN)
function Bridge.GetItemData(itemName)
    local items = QBCore.Functions.GetPlayerData().items
    if not items then return nil end
    
    for _, item in pairs(items) do
        if item and item.name == itemName then
            return item.info
        end
    end
    return nil
end

-- Trigger server callback
function Bridge.TriggerCallback(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb, ...)
end

print('^2[atm-dui] QBCore client adapter initialized^0')
Bridge.Ready = true
print('^2[atm-dui] Client Bridge.Ready set to true^0')
