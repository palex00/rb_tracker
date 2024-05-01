function badges_count()
    return Tracker:ProviderCountForCode('badge')
end

function key_items_count()
    return Tracker:ProviderCountForCode('keyitem')
end

function fossil_count()
    local fossils = Tracker:ProviderCountForCode("fossil")
    return fossils
end

TODO: test this?
function cardkey(floor)
    return has('cardkey') or has('cardkey'..floor..'f') or has('cardkey_progressive', floor-1)
end


function elite4()
    local obj = Tracker:FindObjectForCode("e4b_digit")
    local badges_required = obj.CurrentStage
    -- local badges = badges()
    local hundreds = 0
    local tens = 0
    local ones = 0

    obj = Tracker:FindObjectForCode("e4k_digit1")
    if obj then
        tens = obj.CurrentStage
    end
    obj = Tracker:FindObjectForCode("e4k_digit2")
    if obj then
        ones = obj.CurrentStage
    end
    local key_items_required = (10 * tens) + ones
    -- local key_items = key_items()
    obj = Tracker:FindObjectForCode("e4p_digit1")
    if obj then
        hundreds = obj.CurrentStage
    end
    obj = Tracker:FindObjectForCode("e4p_digit2")
    if obj then
        tens = obj.CurrentStage
    end
    obj = Tracker:FindObjectForCode("e4p_digit3")
    if obj then
        ones = obj.CurrentStage
    end
    local pokedex_required = (100 * hundreds) + (10 * tens) + ones
    local pokedex = Tracker:ProviderCountForCode("pokemon")


    return ((badges() >= badges_required) and (key_items() >= key_items_required) and (pokedex >= pokedex_required))
end

function victoryroad()
    local obj = Tracker:FindObjectForCode("vr_digit")
    if obj then
        local count = obj.CurrentStage
        return (badges() >= count)
    end
    return false
end

function rt23()
    local obj = Tracker:FindObjectForCode("rt22_digit")
    local req = obj.CurrentStage
    return badges() >= req
end

function viridiangym()
    local obj = Tracker:FindObjectForCode("vg_digit")
    -- local badges = badges()
    if obj then
        local count = obj.CurrentStage
        return (badges() >= count)
    end
    return false
end

function ceruleancave()
    local obj = Tracker:FindObjectForCode("ccaveB_digit")
    -- local badges = badges()
    local badge_req = 0
    local tens = 0
    local ones = 0
    if obj then
        badge_req = obj.CurrentStage
    end
    obj = Tracker:FindObjectForCode("ccaveK_digit1")
    if obj then
        tens = obj.CurrentStage
    end
    obj = Tracker:FindObjectForCode("ccaveK_digit2")
    if obj then
        ones = obj.CurrentStage
    end
    local key_item_req = (10 * tens) + ones
    -- print(key_items() .. "items out of " .. key_item_count)
    -- print(badges().."out of "..badge_count)
    return (key_items() >= key_item_req) and (badges() >= badge_req)
end