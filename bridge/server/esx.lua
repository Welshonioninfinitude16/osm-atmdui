-- ESX Server Bridge Adapter

if Bridge.Framework ~= 'esx' then return end

local ESX = exports['es_extended']:getSharedObject()

-- Get player object
function Bridge.GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

-- Get player money
function Bridge.GetPlayerMoney(source, account)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 0 end
    
    if account == 'cash' then
        return xPlayer.getMoney()
    elseif account == 'bank' then
        return xPlayer.getAccount('bank').money
    end
    return 0
end

-- Add money to player
function Bridge.AddMoney(source, account, amount, reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    if account == 'cash' then
        xPlayer.addMoney(amount, reason)
    elseif account == 'bank' then
        xPlayer.addAccountMoney('bank', amount, reason)
    end
    return true
end

-- Remove money from player
function Bridge.RemoveMoney(source, account, amount, reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    if account == 'cash' then
        if xPlayer.getMoney() < amount then return false end
        xPlayer.removeMoney(amount, reason)
    elseif account == 'bank' then
        if xPlayer.getAccount('bank').money < amount then return false end
        xPlayer.removeAccountMoney('bank', amount, reason)
    end
    return true
end

-- Get player identifier
function Bridge.GetPlayerIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    return xPlayer.getIdentifier()
end

-- Get player name
function Bridge.GetPlayerName(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 'Unknown' end
    return xPlayer.getName()
end

-- Send notification
function Bridge.Notify(source, message, type)
    TriggerClientEvent('esx:showNotification', source, message, type)
end

-- Check if player has item
function Bridge.HasItem(source, itemName)
    if GetResourceState('ox_inventory') == 'started' then
        local item = exports.ox_inventory:Search(source, 'count', itemName)
        return item and item > 0
    else
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        local item = xPlayer.getInventoryItem(itemName)
        return item and item.count > 0
    end
end

-- Get item data
function Bridge.GetItemData(source, itemName)
    if GetResourceState('ox_inventory') == 'started' then
        local items = exports.ox_inventory:Search(source, 'slots', itemName)
        if items and #items > 0 then
            return items[1].metadata
        end
    end
    return nil
end

-- Get player by identifier
function Bridge.GetPlayerByIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

-- Add Item
function Bridge.AddItem(source, item, amount, info)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(source, item, amount, info)
    else
        return xPlayer.addInventoryItem(item, amount)
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
    ESX.RegisterUsableItem('atm_receipt', function(source)
        -- ESX doesn't natively support item metadata easily without ox_inventory
        -- so if using raw ESX, they might not see full receipt data unless customized
        -- but this prevents a crash
        TriggerClientEvent('atm-dui:client:viewReceipt', source, {
            type = 'ATM Receipt',
            amount = 'Unknown',
            account = 'Unknown',
            balance = 'Unknown',
            date = os.date('%Y-%m-%d %H:%M:%S')
        })
    end)
end

-- Create callback helper
function Bridge.CreateCallback(name, cb)
    ESX.RegisterServerCallback(name, cb)
end

Bridge.Ready = true
