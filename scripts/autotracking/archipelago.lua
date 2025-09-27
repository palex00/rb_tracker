ScriptHost:LoadScript("scripts/autotracking/slot_options.lua")
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/map_mapping.lua")

if IS_PSEUDOTRACKING then
	ScriptHost:LoadScript("scripts/autotracking/location_and_event_mapping.lua")
	else
	ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
end


CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

function onClear(slot_data)

    print("Contents of slot_data:")
    for key, value in pairs(slot_data) do
        print(key, value)
    end

    SLOT_DATA = slot_data
    CUR_INDEX = -1
    
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.Active = false
                elseif v[2] == "progressive_toggle" then
                    obj.Active = false
                    obj.CurrentStage = 0
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                else
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            else
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    
    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}
    get_slot_options(slot_data)

    local ap_locations = get_ap_locations()
    
    trainersanity_init(ap_locations)
    dexsanity_init(ap_locations)
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end

    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    
    local v = ITEM_MAPPING[item_id]
    if not v then
        return
    end

    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive_toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        else
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
    local v = LOCATION_MAPPING[location_id]

	for _, w in ipairs(v) do
		local obj = Tracker:FindObjectForCode(w)
		if obj then
			if w:sub(1, 1) == "@" then
				obj.AvailableChestCount = obj.AvailableChestCount - 1
			elseif obj.Type == "progressive" then
				obj.CurrentStage = obj.CurrentStage + 1
			else
				obj.Active = true
			end
		else
			print(string.format("onLocation: could not find object for code %s", v[1]))
		end
	end
end


-- add AP callbacks
Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
Archipelago:AddBouncedHandler("map handler", onMap)