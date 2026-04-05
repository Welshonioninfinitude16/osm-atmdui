-- ESX Client Bridge Adapter

if Bridge.Framework ~= 'esx' then return end

if GetResourceState('ox_inventory') ~= 'started' then
    print('^1[atm-dui] ESX Framework requires ox_inventory!^0')
    return
end

local ESX = exports['es_extended']:getSharedObject()
local PlayerData = {}

-- Get player data
function Bridge.GetPlayerData()
    local xPlayer = ESX.GetPlayerData()
    if not xPlayer then return nil end
    
    local cash = 0
    local bank = 0
    
    for _, account in pairs(xPlayer.accounts or {}) do
        if account.name == 'money' then
            cash = account.money
        elseif account.name == 'bank' then
            bank = account.money
        end
    end
    
    local fName = xPlayer.firstName or ""
    local lName = xPlayer.lastName or ""
    local defaultName = xPlayer.name or ""
    
    local finalName = fName .. ' ' .. lName
    if finalName == ' ' or finalName == '' then finalName = defaultName end

    return {
        identifier = xPlayer.identifier,
        name = finalName,
        cash = cash,
        bank = bank,
        job = xPlayer.job,
    }
end

-- Show notification
function Bridge.Notify(message, type)
    local notifyType = 'info'
    if type == 'error' then notifyType = 'error'
    elseif type == 'success' then notifyType = 'success'
    end
    
    ESX.ShowNotification(message, notifyType)
end

-- Check if player has item (uses ox_inventory)
function Bridge.HasItem(itemName)
    local item = exports.ox_inventory:Search('count', itemName)
    return item and item > 0
end

-- Get item data (for bank card PIN)
function Bridge.GetItemData(itemName)
    local items = exports.ox_inventory:Search('slots', itemName)
    if items and #items > 0 then
        return items[1].metadata
    end
    return nil
end

-- Trigger server callback (ESX uses callbacks differently)
function Bridge.TriggerCallback(name, cb, ...)
    ESX.TriggerServerCallback(name, cb, ...)
end

Bridge.Ready = true
