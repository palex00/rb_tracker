function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function has(item, amount)
	local count = Tracker:ProviderCountForCode(item)
	local amount = tonumber(amount)
	if not amount then
        if count > 0 then
            return AccessibilityLevel.Normal
        end
	elseif count >= amount then
        return AccessibilityLevel.Normal
	end
    return AccessibilityLevel.None
end

function has_location(loc)
    if loc.AvailableChestCount == 0 then
        return AccessibilityLevel.Normal
    else 
        return AccessibilityLevel.None
    end
end


function progCount(code)
	return Tracker:FindObjectForCode(code).CurrentStage
end

--returns whether we can access all given arguments
function access(...)
    local access = AccessibilityLevel.Normal
    local args = {...}
    for i,v in ipairs(args) do
        --break early if we hit min accessibility
        if v == AccessibilityLevel.None then
            return AccessibilityLevel.None
        end

        if access > v then
            access = v
        end
    end

    return access
end

--returns the maximum accessibility of the given arguments
function max(...)
    local maximum = AccessibilityLevel.None
    local args = {...}

    for i,v in ipairs(args) do
        if v == AccessibilityLevel.Normal then
            return AccessibilityLevel.Normal
        end

        if maximum < v then
            maximum = v
        end
    end
    return maximum
end

function scoutable()
    return AccessibilityLevel.Inspect
end

function get_ap_locations()
    local missing = Archipelago.MissingLocations
	local locations = Archipelago.CheckedLocations
	local existing_locations = {}
    --loop through all checked and unchecked locations
	for _, v in pairs(missing) do
		existing_locations[v] = true
	end
	for _, v in pairs(locations) do
		existing_locations[v] = true
	end
  return existing_locations
end

function toggle_item(code)
  local active = Tracker:FindObjectForCode(code).Active
  code = code.."_hosted"
  local object = Tracker:FindObjectForCode(code)
  if object then
    object.Active = active
  else
    if ENABLE_DEBUG_LOG then
      print(string.format("toggle_item: could not find object for code %s", code))
    end
  end
end

function toggle_hosted_item(code)
  local active = Tracker:FindObjectForCode(code).Active
  code = code:gsub("_hosted", "")
  local object = Tracker:FindObjectForCode(code)
  if object then
    object.Active = active
  else
    if ENABLE_DEBUG_LOG then
      print(string.format("toggle_hosted_item: could not find object for code %s", code))
    end
  end
end

function onMap(value)
    local automap = Tracker:FindObjectForCode("automap").CurrentStage == 0
    if automap and value ~= nil and value["data"] ~= nil then
        local map_number = value["data"]["currentMap"]
        
        -- Access correct mapping and activate tabs
        local tabs = MAP_MAPPING[map_number]
        
        for i, tab in ipairs(tabs) do
            Tracker:UiHint("ActivateTab", tab)
        end
    end
end

function toggle_itemgrid()
    local stones = Tracker:FindObjectForCode("opt_stonesanity").CurrentStage == 1
    print(stones)
    print(Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 2)
    
    if Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 2 and stones then
        Tracker:AddLayouts("layouts/itemgrids_extra.json")
        Tracker:AddLayouts("layouts/items_extra_full.json")
        toggle_maingrid()
    elseif stones then
        Tracker:AddLayouts("layouts/itemgrids_extra.json")
        Tracker:AddLayouts("layouts/items_extra_stones.json")
        toggle_maingrid()
    elseif Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 2 then
        Tracker:AddLayouts("layouts/itemgrids_extra.json")
        Tracker:AddLayouts("layouts/items_extra_cardkey.json")
        toggle_maingrid()
    elseif not (Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 2) and not stones then
        Tracker:AddLayouts("layouts/itemgrids.json")
        toggle_maingrid()
    else
        print("Something went terribly wrong in toggle_itemgrid()")
    end
end

function toggle_maingrid()
    local extra_key = Tracker:FindObjectForCode("opt_extra_key_items").CurrentStage == 1
    local tea = Tracker:FindObjectForCode("opt_tea").CurrentStage == 1
    
    if Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 2 then
        if extra_key and tea then
            Tracker:AddLayouts("layouts/items_main_3_full.json")
        elseif extra_key then
            Tracker:AddLayouts("layouts/items_main_3_extrakey.json")
        elseif tea then
            Tracker:AddLayouts("layouts/items_main_3_tea.json")
        elseif not tea and not extra_key then
            Tracker:AddLayouts("layouts/items_main_3_minimal.json")
        else
            print("Something went terribly wrong in toggle_maingrid()")
        end
    elseif Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 1 then
        if extra_key and tea then
            Tracker:AddLayouts("layouts/items_main_2_full.json")
        elseif extra_key then
            Tracker:AddLayouts("layouts/items_main_2_extrakey.json")
        elseif tea then
            Tracker:AddLayouts("layouts/items_main_2_tea.json")
        elseif not tea and not extra_key then
            Tracker:AddLayouts("layouts/items_main_2_minimal.json")
        else
            print("Something went terribly wrong in toggle_maingrid()")
        end
    elseif Tracker:FindObjectForCode("opt_cardkey").CurrentStage == 0 then
        if extra_key and tea then
            Tracker:AddLayouts("layouts/items_main_1_full.json")
        elseif extra_key then
            Tracker:AddLayouts("layouts/items_main_1_extrakey.json")
        elseif tea then
            Tracker:AddLayouts("layouts/items_main_1_tea.json")
        elseif not tea and not extra_key then
            Tracker:AddLayouts("layouts/items_main_1_minimal.json")
        else
            print("Something went terribly wrong in toggle_maingrid()")
        end
    else
        print("Oh nyo. This is even more terrible.")
    end
end

function toggle_grayscale()
    if Tracker:FindObjectForCode("colormap").CurrentStage == 0 then
        Tracker:AddMaps("maps/maps.json") 
    elseif Tracker:FindObjectForCode("colormap").CurrentStage == 1 then
        Tracker:AddMaps("maps/maps_bw.json") 
    else
        print("Oh Oh.")
    end
end

function toggle_splitmap()
    local off = Tracker:FindObjectForCode("splitmap").CurrentStage == 0
    local on = Tracker:FindObjectForCode("splitmap").CurrentStage == 1
    local reverse = Tracker:FindObjectForCode("splitmap").CurrentStage == 2
    
    if off then
        Tracker:AddLayouts("layouts/tabs_single.json")
    elseif on then
        Tracker:AddLayouts("layouts/tabs_split.json")
    elseif reverse then
        Tracker:AddLayouts("layouts/tabs_reverse.json")
    end
end