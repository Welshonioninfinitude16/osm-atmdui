-- QBCore Server Bridge Adapter

local _print = print
local print = function(...)
    if Config.Debug then _print(...) end
end

print('^3[atm-dui] Loading QBCore adapter, Bridge.Framework = ' .. tostring(Bridge.Framework) .. '^0')

if Bridge.Framework ~= 'qbcore' then 
    print('^3[atm-dui] Skipping QBCore adapter (framework is ' .. tostring(Bridge.Framework) .. ')^0')
    return 
end

print('^2[atm-dui] Initializing QBCore adapter^0')

local success, QBCore = pcall(function()
    return exports['qb-core']:GetCoreObject()
end)

if not success or not QBCore then
    print('^1[atm-dui] Failed to get QBCore object: ' .. tostring(QBCore) .. '^0')
    return
end

print('^2[atm-dui] QBCore object obtained successfully^0')

-- Get player object
function Bridge.GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
end

-- Get player money
function Bridge.GetPlayerMoney(source, account)
    local Player = QBCore.Functions.GetPlayer(source)
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
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    return Player.Functions.AddMoney(account, amount, reason or 'atm-transaction')
end

-- Remove money from player
function Bridge.RemoveMoney(source, account, amount, reason)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    return Player.Functions.RemoveMoney(account, amount, reason or 'atm-transaction')
end

-- Get player identifier (citizenid)
function Bridge.GetPlayerIdentifier(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    return Player.PlayerData.citizenid
end

-- Get player name
function Bridge.GetPlayerName(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return 'Unknown' end
    local charinfo = Player.PlayerData.charinfo
    return charinfo.firstname .. ' ' .. charinfo.lastname
end

-- Send notification
function Bridge.Notify(source, message, type)
    TriggerClientEvent('QBCore:Notify', source, message, type or 'primary')
end

-- Check if player has item
function Bridge.HasItem(source, itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    return Player.Functions.GetItemByName(itemName) ~= nil
end

-- Get item data (for bank card PIN)
function Bridge.GetItemData(source, itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end
    
    local item = Player.Functions.GetItemByName(itemName)
    if item then
        return item.info
    end
    return nil
end

-- Get player by identifier
function Bridge.GetPlayerByIdentifier(identifier)
    return QBCore.Functions.GetPlayerByCitizenId(identifier)
end

-- Add Item
function Bridge.AddItem(source, item, amount, info)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(source, item, amount, info)
    else
        return Player.Functions.AddItem(item, amount, false, info)
    end
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
else
    QBCore.Functions.CreateUseableItem('atm_receipt', function(source, item)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end
        if item.info then
            TriggerClientEvent('atm-dui:client:viewReceipt', source, item.info)
        end
    end)
end

print('^2[atm-dui] QBCore functions registered^0')

-- Create callback helper (using ox_lib for consistency)
function Bridge.CreateCallback(name, cb)
    lib.callback.register(name, cb)
end

print('^2[atm-dui] QBCore adapter initialized successfully^0')
Bridge.Ready = true
print('^2[atm-dui] Bridge.Ready set to true^0')
