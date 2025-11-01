-- Variables for tracking game state
local harvestCooldowns = {}
local deliveryPed = nil
local customerPed = nil
local currentOrder = nil
local activeWaypoint = false
local vineyardBlip = nil -- Single blip variable

-- Set up the script when it starts
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        harvestCooldowns = {}
        CreateTargets()
        SpawnProps()
        CreateVineyardBlip() -- Create single blip
        Citizen.SetTimeout(2000, function()
            SpawnDeliveryPed()
        end)
    end
end)

-- Clean up when script stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        RemoveTargets()
        DeleteProps()
        DeleteDeliveryPed()
        DeleteCustomerPed()
        DeleteVineyardBlip() -- Remove single blip
    end
end)

-- Create single vineyard blip
function CreateVineyardBlip()
    -- Check if blip is enabled
    if not Config.Blip.enabled then
        return
    end
    
    -- Create blip at configured coordinates
    vineyardBlip = AddBlipForCoord(Config.Blip.coords.x, Config.Blip.coords.y, Config.Blip.coords.z)
    
    -- Configure blip appearance
    SetBlipSprite(vineyardBlip, Config.Blip.sprite)
    SetBlipDisplay(vineyardBlip, 4)
    SetBlipScale(vineyardBlip, Config.Blip.scale)
    SetBlipColour(vineyardBlip, Config.Blip.color)
    SetBlipAsShortRange(vineyardBlip, true)
    
    -- Set blip label
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(vineyardBlip)
    
    print("Vineyard blip created at: " .. Config.Blip.coords.x .. ", " .. Config.Blip.coords.y)
end

-- Remove vineyard blip
function DeleteVineyardBlip()
    if vineyardBlip and DoesBlipExist(vineyardBlip) then
        RemoveBlip(vineyardBlip)
        vineyardBlip = nil
        print("Vineyard blip removed")
    end
end

-- Keep track of spawned props so we can clean them up
local spawnedProps = {}

-- Create the visual props in the world
function SpawnProps()
    -- Processing machine prop
    local processModel = GetHashKey(Config.Props.process.model)
    RequestModel(processModel)
    while not HasModelLoaded(processModel) do
        Wait(10)
    end
    local processCoords = Config.Props.process.coords
    local processProp = CreateObject(processModel, processCoords.x, processCoords.y, processCoords.z, false, false, false)
    SetEntityHeading(processProp, processCoords.w)
    FreezeEntityPosition(processProp, true)
    table.insert(spawnedProps, processProp)
    
    -- Wine barrel prop
    local craftModel = GetHashKey(Config.Props.craft.model)
    RequestModel(craftModel)
    while not HasModelLoaded(craftModel) do
        Wait(10)
    end
    local craftCoords = Config.Props.craft.coords
    local craftProp = CreateObject(craftModel, craftCoords.x, craftCoords.y, craftCoords.z, false, false, false)
    SetEntityHeading(craftProp, craftCoords.w)
    FreezeEntityPosition(craftProp, true)
    table.insert(spawnedProps, craftProp)
end

-- Remove all spawned props
function DeleteProps()
    for _, prop in pairs(spawnedProps) do
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    spawnedProps = {}
end

-- Create the delivery ped that gives orders
function SpawnDeliveryPed()
    local pedModel = GetHashKey(Config.DeliveryPed.model)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end
    
    local coords = Config.DeliveryPed.coords
    deliveryPed = CreatePed(4, pedModel, coords.x, coords.y, coords.z, coords.w, false, true)
    SetEntityHeading(deliveryPed, coords.w)
    FreezeEntityPosition(deliveryPed, true)
    SetEntityInvincible(deliveryPed, true)
    SetBlockingOfNonTemporaryEvents(deliveryPed, true)
    
    -- Make the ped stand with a clipboard
    TaskStartScenarioInPlace(deliveryPed, Config.DeliveryPed.scenario, 0, true)
    
    -- Add interaction target after a short delay
    Citizen.SetTimeout(2000, function()
        if DoesEntityExist(deliveryPed) then
            exports.ox_target:addLocalEntity(deliveryPed, {
                {
                    name = 'delivery_order',
                    event = 'vineyard:client:takeOrder',
                    icon = 'fas fa-clipboard-list',
                    label = Config.Text.delivery_take_order,
                    distance = 2.0
                }
            })
        end
    end)
end

-- Remove the delivery ped
function DeleteDeliveryPed()
    if deliveryPed and DoesEntityExist(deliveryPed) then
        exports.ox_target:removeLocalEntity(deliveryPed, 'delivery_order')
        DeleteEntity(deliveryPed)
        deliveryPed = nil
    end
end

-- Remove the customer ped and cleanup all UI
function DeleteCustomerPed()
    if customerPed and DoesEntityExist(customerPed) then
        -- Remove the interaction target
        exports.ox_target:removeLocalEntity(customerPed, 'deliver_order')
        -- Delete the ped entity
        DeleteEntity(customerPed)
        customerPed = nil
    end
    
    -- Reset order state
    currentOrder = nil
    activeWaypoint = false
    
    -- Remove waypoint from map
    if IsWaypointActive() then
        SetWaypointOff()
    end
    
    -- Hide the clipboard UI
    lib.hideTextUI()
    
    print("Customer ped removed and UI cleaned up")
end

-- Set up all the interaction targets
function CreateTargets()
    -- Grape harvesting spots
    for i, harvestLocation in ipairs(Config.Locations.harvest) do
        exports.ox_target:addSphereZone({
            coords = harvestLocation,
            radius = 1.5,
            debug = false,
            options = {{
                name = 'harvest_grapes_' .. i,
                event = 'vineyard:client:harvestGrapes',
                icon = 'fas fa-leaf',
                label = Config.Text.target_harvest,
                distance = 2.0
            }}
        })
    end
    
    -- Grape processing machine
    local processCoords = Config.Props.process.coords
    exports.ox_target:addSphereZone({
        coords = vector3(processCoords.x, processCoords.y, processCoords.z),
        radius = 1.5,
        debug = false,
        options = {{
            name = 'process_grapes',
            event = 'vineyard:client:processGrapes',
            icon = 'fas fa-blender',
            label = Config.Text.target_process,
            distance = 2.0
        }}
    })
    
    -- Wine crafting barrel
    local craftCoords = Config.Props.craft.coords
    exports.ox_target:addSphereZone({
        coords = vector3(craftCoords.x, craftCoords.y, craftCoords.z),
        radius = 1.5,
        debug = false,
        options = {{
            name = 'craft_wine',
            event = 'vineyard:client:craftWine',
            icon = 'fas fa-wine-bottle',
            label = Config.Text.target_craft,
            distance = 2.0
        }}
    })
end

-- Remove all targets
function RemoveTargets()
    for i, _ in ipairs(Config.Locations.harvest) do
        exports.ox_target:removeZone('harvest_grapes_' .. i)
    end
    exports.ox_target:removeZone('process_grapes')
    exports.ox_target:removeZone('craft_wine')
end

-- Harvest grapes from vines
RegisterNetEvent('vineyard:client:harvestGrapes', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    -- Find the closest grape spot
    local closestLocation = nil
    local closestDistance = nil
    
    for i, location in ipairs(Config.Locations.harvest) do
        local distance = #(playerCoords - location)
        if not closestDistance or distance < closestDistance then
            closestDistance = distance
            closestLocation = location
        end
    end
    
    -- Create unique identifier for this spot
    if closestLocation then
        local locationKey = string.format("%.1f_%.1f_%.1f", closestLocation.x, closestLocation.y, closestLocation.z)
        
        -- Check if spot is on cooldown
        local currentTime = GetGameTimer()
        if harvestCooldowns[locationKey] and currentTime < harvestCooldowns[locationKey] then
            local remainingTime = math.ceil((harvestCooldowns[locationKey] - currentTime) / 1000)
            lib.notify({
                title = 'Cooldown',
                description = 'This spot is on cooldown for ' .. remainingTime .. ' seconds!',
                type = 'error'
            })
            return
        end
        
        -- Show the harvesting progress
        local success = lib.progressCircle({
            duration = Config.ProgressBars.harvest.duration,
            label = Config.ProgressBars.harvest.label,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                dict = Config.Animations.harvest.dict,
                clip = Config.Animations.harvest.anim
            }
        })
        
        if success then
            -- Set cooldown and notify server
            harvestCooldowns[locationKey] = GetGameTimer() + (Config.HarvestCooldown * 1000)
            TriggerServerEvent('vineyard:server:harvestGrapes')
        else
            ClearPedTasks(PlayerPedId())
            lib.notify({
                title = 'Cancelled',
                description = 'Grape harvesting cancelled',
                type = 'error'
            })
        end
    end
end)

-- Take a delivery order from the delivery ped
RegisterNetEvent('vineyard:client:takeOrder', function()
    -- Pick a random order
    local randomOrder = Config.Orders[math.random(1, #Config.Orders)]
    local orderContent = string.gsub(Config.Text.delivery_order_content, "{items}", randomOrder.items)
    orderContent = string.gsub(orderContent, "{description}", randomOrder.description)
    orderContent = string.gsub(orderContent, "${reward}", randomOrder.reward)
    
    -- Show order details
    local alert = lib.alertDialog({
        header = Config.Text.delivery_order_header,
        content = orderContent,
        centered = true,
        cancel = true,
        labels = {
            confirm = 'Accept Order',
            cancel = 'Decline'
        }
    })
    
    if alert == 'confirm' then
        -- Accept the order
        currentOrder = randomOrder
        
        -- Copy order to clipboard
        local clipboardText = "ORDER: " .. randomOrder.items .. "\t\n" ..
                             "REWARD: $" .. randomOrder.reward .. "\t\n" ..
                             "STATUS: Active"
        lib.setClipboard(clipboardText)
        
        lib.notify({
            title = 'Order Accepted',
            description = Config.Text.delivery_order_accepted,
            type = 'success'
        })
        
        -- Show order info on screen
        local clipboardContent = string.gsub(Config.Text.delivery_clipboard_content, "{items}", currentOrder.items)
        clipboardContent = string.gsub(clipboardContent, "${reward}", currentOrder.reward)
        lib.showTextUI(Config.Text.delivery_clipboard_header .. '\n' .. clipboardContent)
        
        -- Spawn customer at random location
        local randomLocation = Config.DeliveryLocations[math.random(1, #Config.DeliveryLocations)]
        SpawnCustomerPed(randomLocation)
        
        -- Mark location on map
        SetNewWaypoint(randomLocation.x, randomLocation.y)
        activeWaypoint = true
        
        lib.notify({
            title = 'Delivery Location',
            description = Config.Text.delivery_customer_location,
            type = 'inform'
        })
    else
        lib.notify({
            title = 'Order Declined',
            description = Config.Text.delivery_order_declined,
            type = 'error'
        })
    end
end)

-- Spawn the customer ped for delivery
function SpawnCustomerPed(coords)
    local pedModel = GetHashKey(Config.CustomerPed.model)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end
    
    -- Use the passed coordinates directly
    customerPed = CreatePed(4, pedModel, coords.x, coords.y, coords.z, 0.0, false, true)
    SetEntityHeading(customerPed, math.random(0, 360))
    FreezeEntityPosition(customerPed, true)
    SetEntityInvincible(customerPed, true)
    SetBlockingOfNonTemporaryEvents(customerPed, true)
    
    -- Make customer stand impatiently
    TaskStartScenarioInPlace(customerPed, Config.CustomerPed.scenario, 0, true)
    
    -- Add interaction target after delay
    Citizen.SetTimeout(2000, function()
        if DoesEntityExist(customerPed) then
            exports.ox_target:addLocalEntity(customerPed, {
                {
                    name = 'deliver_order',
                    event = 'vineyard:client:deliverOrder',
                    icon = 'fas fa-truck',
                    label = Config.Text.delivery_deliver_order,
                    distance = 2.0
                }
            })
            print("Customer ped spawned at: " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
        else
            print("Failed to spawn customer ped")
        end
    end)
end

-- Deliver order to customer
RegisterNetEvent('vineyard:client:deliverOrder', function()
    if not currentOrder then
        lib.notify({
            title = 'Error',
            description = Config.Text.delivery_no_active_order,
            type = 'error'
        })
        return
    end
    
    local dialogContent = string.gsub(Config.Text.delivery_complete_content, "{items}", currentOrder.items)
    dialogContent = string.gsub(dialogContent, "${reward}", currentOrder.reward)
    
    local alert = lib.alertDialog({
        header = Config.Text.delivery_complete_header,
        content = dialogContent,
        centered = true,
        cancel = true,
        labels = {
            confirm = 'Deliver',
            cancel = 'Cancel'
        }
    })
    
    if alert == 'confirm' then
        TriggerServerEvent('vineyard:server:completeDelivery', currentOrder)
    end
end)

-- Listen for delivery completion from server
RegisterNetEvent('vineyard:client:deliveryComplete', function()
    DeleteCustomerPed()
end)

-- Process grapes into mash
RegisterNetEvent('vineyard:client:processGrapes', function()
    TriggerServerEvent('vineyard:server:checkItems', 'process')
end)

-- Craft wine from grape mash
RegisterNetEvent('vineyard:client:craftWine', function()
    TriggerServerEvent('vineyard:server:checkItems', 'craft')
end)

-- Handle item check response from server
RegisterNetEvent('vineyard:client:itemCheckResponse', function(action, hasItems)
    if not hasItems then
        lib.notify({
            title = 'Error',
            description = Config.Text.error_missing_items,
            type = 'error'
        })
        return
    end
    
    if action == 'process' then
        -- Skill check for processing
        local skillSuccess = lib.skillCheck({'easy', 'medium', 'hard'}, {'w', 'a', 's', 'd'})
        if skillSuccess then
            local success = lib.progressCircle({
                duration = Config.ProgressBars.process.duration,
                label = Config.ProgressBars.process.label,
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                },
                anim = {
                    dict = Config.Animations.process.dict,
                    clip = Config.Animations.process.anim
                }
            })
            if success then
                TriggerServerEvent('vineyard:server:processGrapes')
            end
        else
            lib.notify({
                title = 'Failed',
                description = 'Skill check failed!',
                type = 'error'
            })
        end
    elseif action == 'craft' then
        -- Skill check for crafting
        local skillSuccess = lib.skillCheck({'medium', 'hard', 'hard'}, {'w', 'a', 's', 'd', 'w'})
        if skillSuccess then
            local success = lib.progressCircle({
                duration = Config.ProgressBars.craft.duration,
                label = Config.ProgressBars.craft.label,
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                },
                anim = {
                    dict = Config.Animations.craft.dict,
                    clip = Config.Animations.craft.anim
                }
            })
            if success then
                TriggerServerEvent('vineyard:server:craftWine')
            end
        else
            lib.notify({
                title = 'Failed',
                description = 'Skill check failed!',
                type = 'error'
            })
        end
    end
end)