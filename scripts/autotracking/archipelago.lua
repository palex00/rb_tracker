ScriptHost:LoadScript("scripts/autotracking/slot_options.lua")
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/map_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

function onClear(slot_data)

    print("Contents of slot_data:")
    print(dump_table(slot_data))

    SLOT_DATA = slot_data
    CUR_INDEX = -1
    PLAYER_ID = Archipelago.PlayerNumber or -1
    TEAM_NUMBER = Archipelago.TeamNumber or 0
    
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
    
    -- reset manually tracked events
    for _, item in ipairs(HOSTED_ITEMS) do
        Tracker:FindObjectForCode(item).Active = false
    end

    -- This is a fallback since not all games have this slot data yet
    Tracker:FindObjectForCode("game_version").CurrentStage = 0
    Tracker:FindObjectForCode("exp_all").CurrentStage = 1

    for k, v in pairs(slot_data) do
        if STAGE_CODES[k] then
            --print("Setting "..k.." to "..v)
            Tracker:FindObjectForCode(STAGE_CODES[k]).CurrentStage = v
        elseif AMOUNT_CODES[k] then
            --print("Setting "..k.." to "..v)
            Tracker:FindObjectForCode(AMOUNT_CODES[k]).AcquiredCount = v
        elseif k == "game_version" then
            if v == 0 then
                Tracker:FindObjectForCode("opt_game_version").CurrentStage = 1
            elseif v == 1 then
                Tracker:FindObjectForCode("opt_game_version").CurrentStage = 2
            end
        elseif IGNORED_CODES[k] then
            --print("Ignored slot_data: "..k)
        else
            print("None found yet for " .. k)
        end
    end

    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}
    get_slot_options(slot_data)

    local ap_locations = get_ap_locations()
    
    trainersanity_init(ap_locations)
    dexsanity_init(ap_locations)

    if PLAYER_ID>-1 then
        updateEvents(0)
        
        EVENT_ID="pokemon_rb_events_"..TEAM_NUMBER.."_"..PLAYER_ID
        Archipelago:SetNotify({EVENT_ID})
        Archipelago:Get({EVENT_ID})
    end

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

function onNotify(key, value, old_value)
    if value ~= nil and value ~= 0 then
        if key == EVENT_ID then
            updateEvents(value)
        end
    end
end

function onNotifyLaunch(key, value)
    if value ~= nil and value ~= 0 then
        if key == EVENT_ID then
            updateEvents(value)
        end
    end
end

function updateEvents(value)
    if value ~= nil then
        for i, code in ipairs(FLAG_EVENT_CODES) do
            local obj = Tracker:FindObjectForCode(code)
            if obj ~= nil then
                obj.Active = false
            end
            local bit = value >> (i - 1) & 1
            if #code > 0 then
                local obj = Tracker:FindObjectForCode(code)
                obj.Active = obj.Active or bit == 1
                if obj.Active == true then
                    print(code .. " is now active!")
                end
            end
        end
    end
end

-- add AP callbacks
Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
Archipelago:AddBouncedHandler("map handler", onMap)
Archipelago:AddSetReplyHandler("notify handler", onNotify)
Archipelago:AddRetrievedHandler("notify launch handler", onNotifyLaunch)