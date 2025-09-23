TRAINERSANITY_LOCATIONS = {}
TABLE_DUMP = TRUE

function trainer_visible(id)
    local obj = Tracker:FindObjectForCode('opt_trn')
    if (obj.CurrentStage == 0) then
        return false
    end
    -- playernumber doesn't matter, just checking if we're connected
    if Archipelago.PlayerNumber < 1 then
        return true
    end

    local key = tonumber(id)
    local x = TRAINERSANITY_LOCATIONS[key]
    return TRAINERSANITY_LOCATIONS[key]
end

function trainersanity_init(locations)
    TRAINERSANITY_LOCATIONS = {}
    -- trainersanity checks have ids in the range 172000215-172000531
    local start_index = 172000215
    local end_index = 172000531
    for i = start_index, end_index do
        local location_exists = locations[i]
        TRAINERSANITY_LOCATIONS[i] = location_exists
    end
end	

-- ITEM COUNT CHECKS

-- returns int of # of badges
function badges_count()
    return Tracker:ProviderCountForCode('badge')
end
-- returns int of # of key items
function key_items_count()
    return Tracker:ProviderCountForCode('keyitem')
end
-- returns int of # of pokemon caught
function pokedex_count()
    local hundreds = 0
    local tens = 0
    local ones = 0

    obj = Tracker:FindObjectForCode("dex_digit1")
    if obj then
        hundreds = obj.CurrentStage
    end
    obj = Tracker:FindObjectForCode("dex_digit2")
    if obj then
        tens = obj.CurrentStage
    end
    obj = Tracker:FindObjectForCode("dex_digit3")
    if obj then
        ones = obj.CurrentStage
    end
    return (100 * hundreds) + (10 * tens) + ones
end
-- returns whether we have enough fossils for a second check
function enough_fossils()
    local fossils = Tracker:ProviderCountForCode("fossil")
    local fossils_req = Tracker:FindObjectForCode('opt_fossilcheck').AcquiredCount
    return fossils >= fossils_req
end

-- HM CHECKS

--a table for lookups
badges = {"boulder", "cascade", "thunder", "rainbow", "soul", "marsh", "volcano", "earth"}

function cut()
    obj = Tracker:FindObjectForCode('cut')
    stage = 0
    extra = AccessibilityLevel.None
    if obj then
        stage = obj.CurrentStage
        if stage > 0 then
            extra = has(badges[stage])
        end
    end
    return access(has('cut'),max(has('cascade'),has('opt_hm_off'),extra))
end

function fly()
    obj = Tracker:FindObjectForCode('fly')
    stage = 0
    extra = AccessibilityLevel.None
    if obj then
        stage = obj.CurrentStage
        if stage > 0 then
            extra = has(badges[stage])
        end
    end

    return access(has('fly'), max(has('thunder'),has('opt_hm_off'),extra))
end

function surf()
    obj = Tracker:FindObjectForCode('surf')
    stage = 0
    extra = AccessibilityLevel.None
    if obj then
        stage = obj.CurrentStage
        if stage > 0 then
            extra = has(badges[stage])
        end
    end
    return access(has('surf'), max(has('soul'),has('opt_hm_off'),extra))
end

function strength()
    obj = Tracker:FindObjectForCode('strength')
    stage = 0
    extra = AccessibilityLevel.None
    if obj then
        stage = obj.CurrentStage
        if stage > 0 then
            extra = has(badges[stage])
        end
    end

    return access(has('strength'), max(has('rainbow'),has('opt_hm_off'),extra))
end

function flash()
    obj = Tracker:FindObjectForCode('flash')
    stage = 0
    extra = AccessibilityLevel.None
    if obj then
        stage = obj.CurrentStage
        if stage > 0 then
            extra = has(badges[stage])
        end
    end
    return access(has('flash'), max(has('boulder'),has('opt_hm_off'),extra))
end

function flyto(location)
    local map = access(has("map_fly_"..location),has('townmap'))
    return access(fly(),max(map,has("fly_"..location)))
end

-- ITEM ACCESS CHECKS
function cardkey(floor)
    return max(has('cardkey'), has('cardkey'..floor..'f'), has('cardkey_progressive', floor-1))
end

function hidden()
    return max(has('opt_itemfinder_off'),has('itemfinder'))
end

function aide(route)
    local code = 'opt_aide_' .. route
    local required = Tracker:FindObjectForCode(code).AcquiredCount
    local caught = pokedex_count()
    return required <= caught and max(has('pokedex'),has('opt_dex_required_off'))

end

function rt25_item()
    local blind = AccessibilityLevel.SequenceBreak
    if has('opt_blind_trainers_on') == AccessibilityLevel.Normal then
        blind = AccessibilityLevel.None
    end
    return max(cut(), blind)
end

-- ROADBLOCK CHECKS
function old_man()
    return max(has('opt_old_man_on'), has('parcel'))
end

function rt11_boulders()
    return max(has('opt_extra_boulders_off'), strength())
end

function boardwalk_boulders()
    return max(has('opt_extra_boulders_off'), strength(), surf())
end

function cyclingroad()
    return max(has('bicycle'), has('opt_bike_skips_on'))
end

function rock_tunnel()
    local in_logic = max(flash(), has('opt_dark_rock_tunnel_on'))
    local out_of_logic = AccessibilityLevel.SequenceBreak
    return max(in_logic, out_of_logic)
end

function officer()
    return max(has('bill'),has("opt_officer_off"))
end

-- LOCATION ACCESS CHECKS
function tea()
    local celadon = Tracker:FindObjectForCode("@Kanto/Celadon City").AccessibilityLevel
    
    if has("opt_tea_on") == 6 then
        return has("tea")
    else
        return celadon
    end
end

function rt3()
    local brock = access(has('opt_rt3brock'), has('brock_beaten'))
    local any_gym = access(has('opt_rt3gym'),has('gym_beaten'))
    local open = has('opt_rt3open')
    local boulder = access(has('opt_rt3boulder'),has('boulder'))
    local any_badge = access(has('opt_rt3badge'),has('badge'))

    return max(open, boulder, any_badge, brock, any_gym)
end


function elite4()
    local badges_required = Tracker:FindObjectForCode("e4b_digit").CurrentStage

    local tens = Tracker:FindObjectForCode("e4k_digit1").CurrentStage
    local ones = Tracker:FindObjectForCode("e4k_digit2").CurrentStage
    local key_items_required = 10 * tens + ones

    local hundreds = Tracker:FindObjectForCode("e4p_digit1").CurrentStage
    tens = Tracker:FindObjectForCode("e4p_digit2").CurrentStage
    ones = Tracker:FindObjectForCode("e4p_digit3").CurrentStage
    local pokedex_required = 100 * hundreds + 10 * tens + ones

    local enough_badges = badges_count() >= badges_required
    local enough_items = key_items_count() >= key_items_required
    local enough_dex = pokedex_count() >= pokedex_required

    if enough_badges and enough_items and enough_dex then
        return AccessibilityLevel.Normal
    elseif enough_badges and enough_items then
        return AccessibilityLevel.SequenceBreak
    else
        return scoutable()
    end
    return AccessibilityLevel.None
end

function victoryroad()
    local count = Tracker:FindObjectForCode("vr_digit").CurrentStage
    if badges_count() >= count then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function rt23()
    local obj = Tracker:FindObjectForCode("rt22_digit")
    local req = obj.CurrentStage
    if badges_count() >= req then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function viridiangym()
    local obj = Tracker:FindObjectForCode("vg_digit")
    if obj then
        local count = obj.CurrentStage
        if (badges_count() >= count) then
            return AccessibilityLevel.Normal
        end
    end
    return AccessibilityLevel.None
end

function ceruleancave()
    local badge_req = Tracker:FindObjectForCode("ccaveB_digit").CurrentStage
    local tens = Tracker:FindObjectForCode("ccaveK_digit1").CurrentStage
    local ones = Tracker:FindObjectForCode("ccaveK_digit2").CurrentStage
    local key_item_req = 10 * tens + ones
    if key_items_count() >= key_item_req and badges_count() >= badge_req then
        return AccessibilityLevel.Normal
    end
    return AccessibilityLevel.None
end

function fossils()
	local er = has("opt_er_on")
    local mt_moon = Tracker:FindObjectForCode("@Kanto/Mt Moon").AccessibilityLevel
    local cinnabar = Tracker:FindObjectForCode("@Kanto/Cinnabar Island").AccessibilityLevel
    
    if mt_moon == AccessibilityLevel.Normal or er == AccessibilityLevel.Normal then
        if (cinnabar == AccessibilityLevel.Normal or er == AccessibilityLevel.Normal) and enough_fossils() then
            return AccessibilityLevel.Normal
        end
        return AccessibilityLevel.SequenceBreak
    end
    return AccessibilityLevel.None
end
