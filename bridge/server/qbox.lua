-- Qbox Server Bridge Adapter
-- Qbox exposes an export-based API and does not use GetCoreObject().

if Bridge.Framework ~= 'qbox' then return end

if GetResourceState('ox_inventory') ~= 'started' then
    error('^1[atm-dui] QBox Framework requires ox_inventory! Please install and start ox_inventory.^0')
    return
end

local qbx = exports.qbx_core

---Returns the Qbox player instance for a source.
function Bridge.GetPlayer(source)
    return qbx:GetPlayer(source)
end

---Returns the player's cash or bank balance.
function Bridge.GetPlayerMoney(source, account)
    local player = Bridge.GetPlayer(source)
    if not player or not player.PlayerData or not player.PlayerData.money then return 0 end

    return player.PlayerData.money[account] or 0
end

---Adds money through the Qbox player object.
function Bridge.AddMoney(source, account, amount, reason)
    local player = Bridge.GetPlayer(source)
    if not player then return false end

    return player.Functions.AddMoney(account, amount, reason or 'atm-transaction')
end

---Removes money through the Qbox player object.
function Bridge.RemoveMoney(source, account, amount, reason)
    local player = Bridge.GetPlayer(source)
    if not player then return false end

    return player.Functions.RemoveMoney(account, amount, reason or 'atm-transaction')
end

---Returns the player's citizen id.
function Bridge.GetPlayerIdentifier(source)
    local player = Bridge.GetPlayer(source)
    if not player or not player.PlayerData then return nil end

    return player.PlayerData.citizenid
end

---Returns a readable character name.
function Bridge.GetPlayerName(source)
    local player = Bridge.GetPlayer(source)
    if not player or not player.PlayerData then return 'Unknown' end

    local charinfo = player.PlayerData.charinfo or {}
    local firstName = charinfo.firstname or ''
    local lastName = charinfo.lastname or ''
    local fullName = (firstName .. ' ' .. lastName):gsub('^%s*(.-)%s*$', '%1')

    return fullName ~= '' and fullName or 'Unknown'
end

---Sends a Qbox notification to a target player.
function Bridge.Notify(source, message, type)
    qbx:Notify(source, message, type or 'inform')
end

---Checks whether a player has at least one item.
function Bridge.HasItem(source, itemName)
    local count = exports.ox_inventory:Search(source, 'count', itemName)
    return count and count > 0 or false
end

---Returns metadata from the first matching inventory slot.
function Bridge.GetItemData(source, itemName)
    local items = exports.ox_inventory:Search(source, 'slots', itemName)
    if items and #items > 0 then
        return items[1].metadata or items[1].info
    end

    return nil
end

---Looks up an online player by citizen id.
function Bridge.GetPlayerByIdentifier(identifier)
    return qbx:GetPlayerByCitizenId(identifier)
end

---Adds an item with ox_inventory metadata.
function Bridge.AddItem(source, item, amount, info)
    return exports.ox_inventory:AddItem(source, item, amount, info)
end

exports('use_atm_receipt', function(event, item, inventory)
    if event == 'usingItem' then
        TriggerClientEvent('atm-dui:client:viewReceipt', inventory.id, item.metadata or item.info)
        return false -- don't consume
    end
end)

---Registers a server callback using ox_lib.
function Bridge.CreateCallback(name, cb)
    lib.callback.register(name, cb)
end

Bridge.Ready = true
