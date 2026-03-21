-- Main Server Script
-- Handles banking operations and callbacks

local _print = print
local print = function(...)
    if Config.Debug then _print(...) end
end

local Transactions = {}

-- Wait for bridge to be ready
CreateThread(function()
    while not Bridge.Ready do
        Wait(100)
    end
    
    Wait(500)
    print('^2[atm-dui] Server initialized!^0')
    
    -- Register callbacks based on framework
    ATM_Server.RegisterCallbacks()
end)

ATM_Server = {}

-- Register all callbacks
function ATM_Server.RegisterCallbacks()
    -- Use lib.callback for ox_lib (works with all frameworks)
    
    -- Verify PIN
    lib.callback.register('atm-dui:server:verifyPIN', function(source, enteredPIN)
        local src = source
        
        -- If PIN verification from card is required
        if Config.PIN.requireCard then
            local cardData = Bridge.GetItemData(src, 'bank_card')
            if cardData and cardData.cardPin then
                return tostring(cardData.cardPin) == tostring(enteredPIN)
            end
            -- No card or no PIN on card - allow if not strict
            return false
        end
        
        -- If no card required, just verify against a server-stored PIN or allow any
        -- For demo purposes, we'll accept any 4-digit PIN
        return #tostring(enteredPIN) == Config.PIN.length
    end)
    
    -- Withdraw money
    lib.callback.register('atm-dui:server:withdraw', function(source, amount)
        local src = source
        amount = tonumber(amount)
        
        if not amount or amount <= 0 then
            return false, 0, 'Invalid amount'
        end
        
        if amount > Config.Transactions.maxWithdraw then
            return false, 0, 'Amount exceeds limit'
        end
        
        local currentBank = Bridge.GetPlayerMoney(src, 'bank')
        
        if currentBank < amount then
            return false, currentBank, 'Insufficient funds'
        end
        
        -- Calculate fee if any
        local fee = Config.Transactions.fee + (amount * (Config.Transactions.feePercent / 100))
        local totalDeduct = amount + fee
        
        if currentBank < totalDeduct then
            return false, currentBank, 'Insufficient funds (including fee)'
        end
        
        -- Process withdrawal
        local success = Bridge.RemoveMoney(src, 'bank', totalDeduct, 'ATM Withdrawal')
        if not success then
            return false, currentBank, 'Transaction failed'
        end
        
        -- Give cash to player
        Bridge.AddMoney(src, 'cash', amount, 'ATM Withdrawal')
        
        -- Log transaction
        ATM_Server.LogTransaction(src, 'withdraw', amount, fee)
        
        local newBalance = Bridge.GetPlayerMoney(src, 'bank')
        return true, newBalance, nil
    end)
    
    -- Deposit money
    lib.callback.register('atm-dui:server:deposit', function(source, amount)
        local src = source
        amount = tonumber(amount)
        
        if not amount or amount <= 0 then
            return false, 0, 'Invalid amount'
        end
        
        if amount > Config.Transactions.maxDeposit then
            return false, 0, 'Amount exceeds limit'
        end
        
        local currentCash = Bridge.GetPlayerMoney(src, 'cash')
        
        if currentCash < amount then
            return false, Bridge.GetPlayerMoney(src, 'bank'), 'Insufficient cash'
        end
        
        -- Process deposit
        local success = Bridge.RemoveMoney(src, 'cash', amount, 'ATM Deposit')
        if not success then
            return false, Bridge.GetPlayerMoney(src, 'bank'), 'Transaction failed'
        end
        
        -- Add to bank
        Bridge.AddMoney(src, 'bank', amount, 'ATM Deposit')
        
        -- Log transaction
        ATM_Server.LogTransaction(src, 'deposit', amount, 0)
        
        local newBalance = Bridge.GetPlayerMoney(src, 'bank')
        return true, newBalance, nil
    end)
    
    -- Transfer money
    lib.callback.register('atm-dui:server:transfer', function(source, targetIdentifier, amount)
        local src = source
        amount = tonumber(amount)
        
        if not amount or amount <= 0 then
            return false, 0, 'Invalid amount'
        end
        
        if amount > Config.Transactions.maxTransfer then
            return false, 0, 'Amount exceeds limit'
        end
        
        if not targetIdentifier or targetIdentifier == '' then
            return false, 0, 'Invalid account number'
        end
        
        local currentBank = Bridge.GetPlayerMoney(src, 'bank')
        
        -- Calculate fee
        local fee = Config.Transactions.fee + (amount * (Config.Transactions.feePercent / 100))
        local totalDeduct = amount + fee
        
        if currentBank < totalDeduct then
            return false, currentBank, 'Insufficient funds'
        end
        
        -- Find target player
        local targetPlayer = Bridge.GetPlayerByIdentifier(targetIdentifier)
        if not targetPlayer then
            -- For offline transfers, you might want to handle this differently
            return false, currentBank, 'Account not found'
        end
        
        local targetSource = targetPlayer.PlayerData and targetPlayer.PlayerData.source or targetPlayer.source
        
        -- Prevent self-transfer
        local myIdentifier = Bridge.GetPlayerIdentifier(src)
        if myIdentifier == targetIdentifier then
            return false, currentBank, 'Cannot transfer to yourself'
        end
        
        -- Process transfer
        local success = Bridge.RemoveMoney(src, 'bank', totalDeduct, 'ATM Transfer to ' .. targetIdentifier)
        if not success then
            return false, currentBank, 'Transaction failed'
        end
        
        -- Add to target's bank
        Bridge.AddMoney(targetSource, 'bank', amount, 'ATM Transfer from ' .. myIdentifier)
        
        -- Notify target
        Bridge.Notify(targetSource, 'You received $' .. amount .. ' from a transfer', 'success')
        
        -- Log transaction
        ATM_Server.LogTransaction(src, 'transfer', amount, fee, targetIdentifier)
        
        local newBalance = Bridge.GetPlayerMoney(src, 'bank')
        return true, newBalance, nil
    end)
    
    -- Get balance
    lib.callback.register('atm-dui:server:getBalance', function(source)
        local src = source
        return {
            bank = Bridge.GetPlayerMoney(src, 'bank'),
            cash = Bridge.GetPlayerMoney(src, 'cash')
        }
    end)
    
    -- Get player data for ATM
    lib.callback.register('atm-dui:server:getPlayerData', function(source)
        local src = source
        local name = Bridge.GetPlayerName(src)
        local identifier = Bridge.GetPlayerIdentifier(src)
        
        return {
            name = name,
            identifier = identifier,
            bank = Bridge.GetPlayerMoney(src, 'bank'),
            cash = Bridge.GetPlayerMoney(src, 'cash')
        }
    end)
end

-- Log transaction (can be extended to save to database)
function ATM_Server.LogTransaction(source, transType, amount, fee, targetAccount)
    local identifier = Bridge.GetPlayerIdentifier(source)
    local timestamp = os.time()
    
    Transactions[#Transactions + 1] = {
        identifier = identifier,
        type = transType,
        amount = amount,
        fee = fee,
        target = targetAccount,
        timestamp = timestamp
    }
    
    -- Optional: Log to database
    -- MySQL.insert('INSERT INTO atm_transactions (identifier, type, amount, fee, target, timestamp) VALUES (?, ?, ?, ?, ?, ?)', 
    --     {identifier, transType, amount, fee, targetAccount, timestamp})
    
    print(string.format('^3[atm-dui] Transaction: %s | Type: %s | Amount: $%d | Fee: $%d^0', 
        identifier, transType, amount, fee))
end

-- Register commands after bridge is ready
CreateThread(function()
    while not Bridge.Ready do
        Wait(100)
    end
    
    RegisterNetEvent('atm-dui:server:createReceipt', function(info)
        local src = source
        if not src then return end
        
        info = info or {}
        info.date = os.date('%Y-%m-%d %H:%M:%S')
        
        -- Add receipt item
        if Bridge.AddItem then
            Bridge.AddItem(src, 'atm_receipt', 1, info)
        else
            -- Fallback
            local Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(src)
            if Player then
                if GetResourceState('ox_inventory') == 'started' then
                    exports.ox_inventory:AddItem(src, 'atm_receipt', 1, info)
                else
                    Player.Functions.AddItem('atm_receipt', 1, false, info)
                end
            end
        end
    end)
    
    -- Test command to give player a bank card with PIN
    -- RegisterCommand('givebankcard', function(source, args)
    --     local src = source
    --     print('^3[atm-dui] givebankcard command executed by source: ' .. src .. '^0')
        
    --     if src == 0 then
    --         print('^1[atm-dui] This command must be run by a player^0')
    --         return
    --     end
        
    --     local pin = tonumber(args[1]) or math.random(1000, 9999)
        
    --     -- Ensure PIN is 4 digits
    --     if pin < 1000 or pin > 9999 then
    --         pin = math.random(1000, 9999)
    --     end
        
    --     local cardNumber = string.format('%04d %04d %04d %04d', 
    --         math.random(1000, 9999),
    --         math.random(1000, 9999),
    --         math.random(1000, 9999),
    --         math.random(1000, 9999)
    --     )
        
    --     local identifier = Bridge.GetPlayerIdentifier(src)
    --     local playerName = Bridge.GetPlayerName(src)
        
    --     print('^3[atm-dui] Player: ' .. playerName .. ' (' .. identifier .. ')^0')
        
    --     local metadata = {
    --         cardPin = pin,
    --         cardNumber = cardNumber,
    --         citizenid = identifier,
    --         name = playerName,
    --         expiry = os.date('%m/%y', os.time() + (365 * 24 * 60 * 60 * 3)) -- 3 years from now
    --     }
        
    --     -- Give item based on framework
    --     local success = false
        
    --     print('^3[atm-dui] Framework: ' .. Bridge.Framework .. '^0')
        
    --     if Bridge.Framework == 'qbcore' then
    --         local QBCore = exports['qb-core']:GetCoreObject()
    --         local Player = QBCore.Functions.GetPlayer(src)
    --         if Player then
    --             print('^3[atm-dui] Player object found, adding bank_card item^0')
    --             success = Player.Functions.AddItem('bank_card', 1, false, metadata)
    --             print('^3[atm-dui] AddItem result: ' .. tostring(success) .. '^0')
    --             if success then
    --                 TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['bank_card'], 'add')
    --             end
    --         else
    --             print('^1[atm-dui] Player object not found!^0')
    --         end
    --     elseif Bridge.Framework == 'qbox' then
    --         success = exports.ox_inventory:AddItem(src, 'bank_card', 1, metadata)
    --     elseif Bridge.Framework == 'esx' then
    --         if GetResourceState('ox_inventory') == 'started' then
    --             success = exports.ox_inventory:AddItem(src, 'bank_card', 1, metadata)
    --         else
    --             -- Default ESX inventory doesn't support metadata well
    --             local xPlayer = exports['es_extended']:getSharedObject().GetPlayerFromId(src)
    --             if xPlayer then
    --                 xPlayer.addInventoryItem('bank_card', 1)
    --                 success = true
    --             end
    --         end
    --     end
        
    --     if success then
    --         Bridge.Notify(src, 'Bank card received! PIN: ' .. pin, 'success')
    --         print(string.format('^2[atm-dui] Gave bank card to %s (PIN: %d)^0', playerName, pin))
    --     else
    --         Bridge.Notify(src, 'Failed to give bank card', 'error')
    --         print('^1[atm-dui] Failed to give bank card^0')
    --     end
    -- end, false)
end)
