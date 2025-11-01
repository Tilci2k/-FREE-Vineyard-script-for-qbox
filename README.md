A complete vineyard farming and delivery system for QBox/FiveM servers. Players can harvest grapes, process them into mash, craft wine, and deliver orders for profit.

Features
**:grapes: Farming System**
   Multiple grape harvesting locations with cooldowns
   Realistic harvesting animations and progress bars
   Configurable cooldown timers per location
**:factory: Production System**
   Process grapes into grape mash
   Craft wine from grape mash
   Skill-check minigames for advanced processing
   Inventory  management with ox_inventory integration
**:truck: Delivery System**
   Interactive delivery ped for taking orders
   Dynamic customer spawning at various locations
   Order clipboard with details copied to player's clipboard
   Map waypoints to customer locations
   Automatic wine removal upon delivery
   Configurable rewards and order types
**:dart: User Experience**
   ox_target integration for all interactions
   ox_lib notifications and progress bars
   Configurable text system (easy translation)
   Clean UI with persistent order display
   Real-time feedback and notifications
**Dependencies**
   qbx_core - Main framework
   ox_lib - Library for notifications and UI
   ox_target - Targeting system
   ox_inventory - Inventory system
**Installation**
   Extract the script folder to your resources directory
   Add ensure vineyard to your server.cfg
   Configure item names in shared/config.lua to match your server
   Add required items to your ox_inventory:
    ['wine'] = {
        label = 'Wine',
        weight = 500,
    },

    ['wine_bottle'] = {
        label = 'Wine Bottle',
        weight = 500,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            cancel = true,
            notification = 'You drank some refreshing wine'
        }
    },

    ['grape_mash'] = {
        label = 'Grape mesh',
        weight = 10,
    },