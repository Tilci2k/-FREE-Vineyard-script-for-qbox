-- Check if player has required items
RegisterNetEvent('vineyard:server:checkItems', function(action)
    local src = source
    local Player = exports['qbx_core']:GetPlayer(src)
    if not Player then return end
    
    local hasItems = false
    
    if action == 'process' then
        local grapeItem = Player.Functions.GetItemByName(Config.Items.grape)
        if grapeItem and grapeItem.amount >= Config.Requirements.process.amount then
            hasItems = true
        end
    elseif action == 'craft' then
        local mashItem = Player.Functions.GetItemByName(Config.Items.grape_mash)
        if mashItem and mashItem.amount >= Config.Requirements.craft.amount then
            hasItems = true
        end
    end
    
    TriggerClientEvent('vineyard:client:itemCheckResponse', src, action, hasItems)
end)

-- Harvest grapes
RegisterNetEvent('vineyard:server:harvestGrapes', function()
    local src = source
    local Player = exports['qbx_core']:GetPlayer(src)
    if not Player then return end
    
    local success = exports.ox_inventory:AddItem(src, Config.Items.grape, Config.Rewards.harvest.amount)
    if success then
        TriggerClientEvent('QBX:Notify', src, Config.Text.notify_harvest_success, 'success')
    else
        TriggerClientEvent('QBX:Notify', src, Config.Text.error_no_space, 'error')
    end
end)

-- Process grapes into mash
RegisterNetEvent('vineyard:server:processGrapes', function()
    local src = source
    local Player = exports['qbx_core']:GetPlayer(src)
    if not Player then return end
    
    local grapeCount = exports.ox_inventory:GetItem(src, Config.Items.grape, nil, true)
    if grapeCount and grapeCount >= Config.Requirements.process.amount then
        local removeSuccess = exports.ox_inventory:RemoveItem(src, Config.Items.grape, Config.Requirements.process.amount)
        if removeSuccess then
            local addSuccess = exports.ox_inventory:AddItem(src, Config.Items.grape_mash, Config.Rewards.process.amount)
            if addSuccess then
                TriggerClientEvent('QBX:Notify', src, Config.Text.notify_process_success, 'success')
            else
                exports.ox_inventory:AddItem(src, Config.Items.grape, Config.Requirements.process.amount)
                TriggerClientEvent('QBX:Notify', src, Config.Text.error_no_space, 'error')
            end
        else
            TriggerClientEvent('QBX:Notify', src, 'Failed to remove grapes!', 'error')
        end
    else
        TriggerClientEvent('QBX:Notify', src, Config.Text.notify_process_fail, 'error')
    end
end)

-- Craft wine from grape mash
RegisterNetEvent('vineyard:server:craftWine', function()
    local src = source
    local Player = exports['qbx_core']:GetPlayer(src)
    if not Player then return end
    
    local mashCount = exports.ox_inventory:GetItem(src, Config.Items.grape_mash, nil, true)
    if mashCount and mashCount >= Config.Requirements.craft.amount then
        local removeSuccess = exports.ox_inventory:RemoveItem(src, Config.Items.grape_mash, Config.Requirements.craft.amount)
        if removeSuccess then
            local addSuccess = exports.ox_inventory:AddItem(src, Config.Items.wine, Config.Rewards.craft.amount)
            if addSuccess then
                TriggerClientEvent('QBX:Notify', src, Config.Text.notify_craft_success, 'success')
            else
                exports.ox_inventory:AddItem(src, Config.Items.grape_mash, Config.Requirements.craft.amount)
                TriggerClientEvent('QBX:Notify', src, Config.Text.error_no_space, 'error')
            end
        else
            TriggerClientEvent('QBX:Notify', src, 'Failed to remove grape mash!', 'error')
        end
    else
        TriggerClientEvent('QBX:Notify', src, Config.Text.notify_craft_fail, 'error')
    end
end)

-- Complete delivery and remove wine from inventory
RegisterNetEvent('vineyard:server:completeDelivery', function(order)
    local src = source
    local Player = exports['qbx_core']:GetPlayer(src)
    if not Player then return end
    
    local requiredWine = tonumber(string.match(order.items, "%d+")) or 1
    
    local wineCount = exports.ox_inventory:GetItem(src, Config.Items.wine, nil, true)
    if wineCount and wineCount >= requiredWine then
        local removeSuccess = exports.ox_inventory:RemoveItem(src, Config.Items.wine, requiredWine)
        if removeSuccess then
            Player.Functions.AddMoney('cash', order.reward)
            
            TriggerClientEvent('vineyard:client:deliveryComplete', src)
            
            TriggerClientEvent('QBX:Notify', src, string.gsub(Config.Text.delivery_complete_success, "${reward}", order.reward), 'success')
        else
            TriggerClientEvent('QBX:Notify', src, string.gsub(Config.Text.delivery_failed_remove_items, "{item}", "wine bottles"), 'error')
        end
    else
        local notEnoughMessage = string.gsub(Config.Text.delivery_not_enough_items, "{item}", "wine bottles")
        notEnoughMessage = string.gsub(notEnoughMessage, "{amount}", requiredWine)
        TriggerClientEvent('QBX:Notify', src, notEnoughMessage, 'error')
    end
end)