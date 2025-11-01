Config = {}

-- Single Blip Configuration (Easy on/off toggle)
Config.Blip = {
    enabled = true,           -- Set to false to disable blip
    coords = vector3(-1911.34, 2058.33, 140.74), -- Blip location (set to delivery ped location)
    sprite = 140,             -- Grape bunch sprite
    color = 11,               -- Green color
    scale = 0.8,              -- Blip size
    label = "Vineyard" -- Blip label
}

-- Text Configuration (All messages in one place)
Config.Text = {
    -- General notifications
    notify_harvest_start = "You start harvesting grapes...",
    notify_harvest_success = "You harvested some grapes!",
    notify_harvest_fail = "You need more space in your inventory!",
    notify_process_start = "Processing grapes into mash...",
    notify_process_success = "You processed grapes into mash!",
    notify_process_fail = "You don't have enough grapes!",
    notify_craft_start = "Crafting wine...",
    notify_craft_success = "You crafted some wine!",
    notify_craft_fail = "You don't have enough grape mash!",
    
    -- Target labels
    target_harvest = "Harvest Grapes",
    target_process = "Process Grapes",
    target_craft = "Make Wine",
    
    -- Error messages
    error_no_space = "Not enough space in inventory!",
    error_missing_items = "You don't have the required items!",
    
    -- Delivery System Messages
    delivery_order_header = "Delivery Order",
    delivery_order_content = "**Order Details:**\n\n• Items: {items}\n• Description: {description}\n• Reward: ${reward}\n\n**Requirements:**\n• You need to have the required wine in your inventory\n• Deliver to the marked location on your map",
    delivery_order_accepted = "Order accepted! Details copied to clipboard.",
    delivery_customer_location = "Customer location marked on map!",
    delivery_order_declined = "You declined the delivery order",
    delivery_take_order = "Take Order",
    
    delivery_complete_header = "Complete Delivery",
    delivery_complete_content = "Are you sure you want to deliver {items}?\n\nReward: ${reward}",
    delivery_deliver_order = "Deliver Order",
    delivery_no_active_order = "You don't have an active order!",
    delivery_complete_success = "Delivery complete! You received ${reward}",
    delivery_not_enough_items = "You don't have enough {item}! Required: {amount}",
    delivery_failed_remove_items = "Failed to remove {item} from inventory!",
    
    delivery_clipboard_header = "📋 ACTIVE ORDER",
    delivery_clipboard_content = "{items}\nReward: ${reward}"
}

-- Vineyard Locations
Config.Locations = {
    harvest = {
        vector3(-1878.79, 2098.8, 139.68), -- Original location
        vector3(-1889.95, 2099.65, 138.86), 
        vector3(-1858.85, 2097.83, 138.83), 
        vector3(-1847.02, 2103.5, 138.57),
        vector3(-1874.03, 2102.93, 138.01),
        vector3(-1888.3, 2104.01, 137.41),
        vector3(-1852.56, 2105.73, 136.31),
        vector3(-1840.22, 2111.44, 135.19)
    },
    process = vector3(-1884.88, 2092.95, 140.99), -- Grape processing location
    craft = vector3(-1902.31, 2093.15, 140.39)    -- Wine crafting location
}

-- Harvest cooldown settings (in seconds)
Config.HarvestCooldown = 20 -- 20 seconds cooldown per location

-- Props for each location
Config.Props = {
    process = {
        model = 'v_ret_ml_tableb',
        coords = vector4(-1888.31, 2093.45, 139.99, 358.07) -- x, y, z, heading
    },
    craft = {
        model = 'vw_prop_vw_barrel_pile_01a',
        coords = vector4(-1898.36, 2093.66, 139.39, 14.03) -- x, y, z, heading
    }
}

-- Items
Config.Items = {
    grape = 'grape',
    grape_mash = 'grape_mash',
    wine = 'wine_bottle'
}

-- Animation settings
Config.Animations = {
    harvest = {
        dict = 'anim@gangops@facility@servers@',
        anim = 'hotwire',
        duration = 5000
    },
    process = {
        dict = 'mini@repair',
        anim = 'fixing_a_player',
        duration = 7000
    },
    craft = {
        dict = 'amb@prop_human_bbq@male@base',
        anim = 'base',
        duration = 10000
    }
}

-- Progress bar settings
Config.ProgressBars = {
    harvest = {
        label = 'Harvesting Grapes...',
        duration = 5000,
        useSkillCheck = false
    },
    process = {
        label = 'Processing Grapes...',
        duration = 7000,
        useSkillCheck = true,
        skillDifficulty = 'easy' -- easy, medium, hard
    },
    craft = {
        label = 'Crafting Wine...',
        duration = 10000,
        useSkillCheck = true,
        skillDifficulty = 'medium'
    }
}

-- Required items amounts
Config.Requirements = {
    harvest = {
        item = nil,
        amount = 0
    },
    process = {
        item = Config.Items.grape,
        amount = 5
    },
    craft = {
        item = Config.Items.grape_mash,
        amount = 2
    }
}

-- Reward items amounts
Config.Rewards = {
    harvest = {
        item = Config.Items.grape,
        amount = 3
    },
    process = {
        item = Config.Items.grape_mash,
        amount = 1
    },
    craft = {
        item = Config.Items.wine,
        amount = 1
    }
}

-- Delivery Ped Configuration
Config.DeliveryPed = {
    model = 'a_m_m_business_01', -- You can change this to any ped model
    coords = vector4(-1924.29, 2058.65, 139.83, 344.75), -- x, y, z, heading
    scenario = 'WORLD_HUMAN_CLIPBOARD' -- Animation the ped will play
}

-- Customer Ped Configuration  
Config.CustomerPed = {
    model = 'a_m_y_business_01', -- Customer ped model
    scenario = 'WORLD_HUMAN_STAND_IMPATIENT' -- Animation for customer
}

-- Delivery Locations (10 locations)
Config.DeliveryLocations = {
    vector4(-615.52, 398.37, 100.63, 1.01), -- Original location
    vector4(304.29, -1775.59, 28.1, 223.19), 
    vector4(922.85, 45.55, 80.11, 60.99), 
    vector4(1695.76, 4785.41, 41.01, 83.79),
    vector4(-271.52, 6182.81, 30.4, 302.69),
    vector4(-3039.46, 492.76, 5.77, 263.5),
    vector4(-1269.79, -1296.24, 3.0, 293.78),
    vector4(1302.94, -528.21, 70.46, 154.15)
}

-- Possible orders (you can customize these)
Config.Orders = {
    {
        id = 1,
        items = "5 bottles of wine",
        reward = 750,
        description = "Customer needs 5 bottles of wine for a dinner party"
    },
    {
        id = 2,
        items = "6 bottles of wine",
        reward = 900,
        description = "Restaurant order for 6 bottles of premium wine"
    },
    {
        id = 3,
        items = "3 bottles of wine",
        reward = 450,
        description = "Small personal order for 3 bottles of wine"
    },
    {
        id = 4,
        items = "8 bottles of wine",
        reward = 1200,
        description = "Corporate event needs 8 bottles of wine"
    },
    {
        id = 5,
        items = "10 bottles of wine",
        reward = 1500,
        description = "Large wedding order for 10 bottles of wine"
    }
}

-- Active order tracking
Config.ActiveOrder = {
    playerId = nil,
    orderId = nil,
    customerCoords = nil,
    customerId = nil
}