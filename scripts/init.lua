-- entry point for all lua code of the pack
-- more info on the lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
ENABLE_DEBUG_LOG = false
-- get current variant
local variant = Tracker.ActiveVariantUID
-- check variant info
IS_ITEMS_ONLY = variant:find("itemsonly")

function split_key()
    local obj =  Tracker:FindObjectForCode('opt_cardkey_split')
    print('opt_split_key state" ' .. obj.CurrentStage)
    key = Tracker:FindObjectForCode('custom_cardkey')
    key:OnMiddleClickFunc()
    if obj.CurrentStage == 2 then
      Tracker:AddLayouts("layouts/split_cardkey.json")
    end
  end

print("-- Example Tracker --")
print("Loaded variant: ", variant)
if ENABLE_DEBUG_LOG then
    print("Debug logging is enabled!")
end

-- Utility Script for helper functions etc.
print("LOADING UTILS.LUA")
ScriptHost:LoadScript("scripts/utils.lua")

-- Logic
print("LOADING LOGIC.LUA")
ScriptHost:LoadScript("scripts/logic/logic.lua")

-- Items
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/options.json")
Tracker:AddItems("items/pokedex.json")

if not IS_ITEMS_ONLY then -- <--- use variant info to optimize loading
    -- Maps
    Tracker:AddMaps("maps/maps.json")    
    -- Locations
    Tracker:AddLocations("locations/locations.json")
    Tracker:AddLocations("locations/submaps.json")
    Tracker:AddLocations("locations/encountertab.json")
end

-- Layout
Tracker:AddLayouts("layouts/itemgrid.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")
Tracker:AddLayouts("layouts/dex.json")

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
-- Add a watch to dynamically load layout if progressive card keys enabled
if PopVersion and PopVersion >= "0.1.0" then
    ScriptHost:AddWatchForCode("load_card_key", "opt_cardkey_split", split_key)
    ScriptHost:AddWatchForCode("toggle_extra_key_items", "opt_extra_key_items", toggle_extra_key_items)
    ScriptHost:AddWatchForCode("toggle_tea", "opt_tea", toggle_tea)
end

ScriptHost:LoadScript('scripts/custom_items/cardkey.lua')