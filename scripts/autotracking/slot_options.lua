function get_slot_options(slot_data)

    if slot_data["second_fossil_check_condition"] then
	end

    if slot_data["require_item_finder"] then
	end

    if slot_data["randomize_hidden_items"] then
	end

    if slot_data["badges_needed_for_hm_moves"] then
	end

    if slot_data["oaks_aide_rt2"] then
	end

    if slot_data["oaks_aide_rt11"] then
	end

    if slot_data["oaks_aide_rt15"] then
	end

    if slot_data["extra_key_items"] then
	end

    if slot_data["extra_strength_boulders"] then
	end

    if slot_data["tea"] then
	end

    if slot_data["old_man"] then
	end

    if slot_data["elite_four_badges_condition"] then
	end
    
    if slot_data["elite_four_key_items_condition"] then
	end

    if slot_data["elite_four_pokedex_condition"] then
	end

    if slot_data["victory_road_condition"] then
	end

    if slot_data["route_22_gate_condition"] then
	end

    if slot_data["route_3_condition"] then
	end

    if slot_data["robbed_house_officer"] then
	end

    if slot_data["viridian_gym_condition"] then
	end

    if slot_data["cerulean_cave_badges_condition"] then
	end

    if slot_data["cerulean_cave_key_items_condition"] then
	end

    if slot_data["free_fly_map"] then
	end

    if slot_data["town_map_free_fly"] then
	end

    if slot_data["extra_badges"] then
	end

    if slot_data["randomize_pokedex"] then
	end

    if slot_data["trainersanity"] then
	end

    if slot_data["death_link"] then
	end

    if slot_data["prizesanity"] then
	end

    if slot_data["key_items_only"] then
	end

    if slot_data["poke_doll_skip"] then
	end

    if slot_data["bicycle_gate_skips"] then
	end

    if slot_data["stonesanity"] then
	end

    if slot_data["dark_rock_tunnel_logic"] then
	end

    if slot_data["split_card_key"] then
	end
end

function dexsanity_init()
    missing = Archipelago.MissingLocations
	locations = Archipelago.CheckedLocations
	dex_checks = {}
    --loop through all checked and unchecked locations
	for _, v in pairs(missing) do
		dex_checks[v] = true
	end
	for _, v in pairs(locations) do
		dex_checks[v] = true
	end

	for i = 0, 150 do
        --check to see if the dexsanity location exists in the list of all checks
		index = i + 172000549
		check_exists = dex_checks[index]
		--if it doesn't, set it to the disabled stage
        --otherwise leave at default
		if not check_exists then
			loc = LOCATION_MAPPING[index]
			obj = Tracker:FindObjectForCode(loc[1])
			if obj then
				obj.CurrentStage = 2
			end
		end
	end
end