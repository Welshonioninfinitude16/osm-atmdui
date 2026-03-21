-- Qbox Server Bridge Adapter
-- Qbox is QBCore-based but uses ox_inventory and ox_lib

if Bridge.Framework ~= 'qbox' then return end

local QBX = exports['qbx_core']:GetCoreObject()

-- Get player object
function Bridge.GetPlayer(source)
    return QBX.Functions.GetPlayer(source)
end

-- Get player money
function Bridge.GetPlayerMoney(source, account)
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return 0 end
    
    if account == 'cash' then
        return Player.PlayerData.money.cash or 0
    elseif account == 'bank' then
        return Player.PlayerData.money.bank or 0
    end
    return 0
end

-- Add money to player
function Bridge.AddMoney(source, account, amount, reason)
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return false end
    
    return Player.Functions.AddMoney(account, amount, reason or 'atm-transaction')
end

-- Remove money from player
function Bridge.RemoveMoney(source, account, amount, reason)
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return false end
    
    return Player.Functions.RemoveMoney(account, amount, reason or 'atm-transaction')
end

-- Get player identifier (citizenid)
function Bridge.GetPlayerIdentifier(source)
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return nil end
    return Player.PlayerData.citizenid
end

-- Get player name
function Bridge.GetPlayerName(source)
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return 'Unknown' end
    local charinfo = Player.PlayerData.charinfo
    return charinfo.firstname .. ' ' .. charinfo.lastname
end

-- Send notification (uses ox_lib)
function Bridge.Notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'ATM',
        description = message,
        type = type or 'info',
    })
end

-- Check if player has item (ox_inventory)
function Bridge.HasItem(source, itemName)
    local count = exports.ox_inventory:Search(source, 'count', itemName)
    return count and count > 0
end

-- Get item data (for bank card PIN)
function Bridge.GetItemData(source, itemName)
    local items = exports.ox_inventory:Search(source, 'slots', itemName)
    if items and #items > 0 then
        return items[1].metadata
    end
    return nil
end

-- Get player by identifier
function Bridge.GetPlayerByIdentifier(identifier)
    return QBX.Functions.GetPlayerByCitizenId(identifier)
end

-- Add Item
function Bridge.AddItem(source, item, amount, info)
    return exports.ox_inventory:AddItem(source, item, amount, info)
end

if GetResourceState('ox_inventory') == 'started' then
    exports('use_atm_receipt', function(event, item, inventory, slot, data)
        if event == 'usingItem' then
            if item.metadata then
                TriggerClientEvent('atm-dui:client:viewReceipt', inventory.id, item.metadata)
            else
                TriggerClientEvent('atm-dui:client:viewReceipt', inventory.id, item.info)
            end
            return false -- don't consume
        end
    end)
end

-- Create callback helper (uses ox_lib)
function Bridge.CreateCallback(name, cb)
    lib.callback.register(name, cb)
end

Bridge.Ready = true
