STAGE_CODES = {
    require_item_finder = "opt_itemfinder",
    badges_needed_for_hm_moves = "opt_hm",
    randomize_hidden_items = "opt_hidden_items",
    extra_strength_boulders = "opt_extra_boulders",
    extra_key_items = "opt_extra_key_items",
    tea = "opt_tea",
    robbed_house_officer = "opt_officer",
    elite_four_badges_condition = "e4b_digit",
    victory_road_condition = "vr_digit",
    route_22_gate_condition = "rt22_digit",
    route_3_condition = "opt_rt3",
    viridian_gym_condition = "vg_digit",
    cerulean_cave_badges_condition = "ccaveB_digit",
    free_fly_map = "free_fly",
    town_map_fly_map = "tm_free_fly",
    randomize_pokedex = "opt_dex",
    prizesanity = "opt_prizesanity",
    key_items_only = "opt_keyonly",
    poke_doll_skip = "opt_pokedoll_skip",
    bicycle_gate_skips = "opt_bike_skips",
    stonesanity = "opt_stonesanity",
    dark_rock_tunnel_logic = "opt_dark_rock_tunnel",
    require_pokedex = "opt_dex_required",
    area_1_to_1_mapping = "opt_encounter",
    split_card_key = "opt_cardkey"
}

AMOUNT_CODES = {
    oaks_aide_rt_2 = "opt_aide_2",
    oaks_aide_rt_11 = "opt_aide_11",
    oaks_aide_rt_15 = "opt_aide_15",
    second_fossil_check_condition = "opt_fossilcheck"
}

IGNORED_CODES = {
    -- Unimplemented because logic irrelevant for Poptracker
    all_elevators_locked = "",
    type_chart = "",
    v5_update = "",
    death_link = "",
    warp_tile_shuffle = "",
    door_shuffle = "",
    
    -- Special handling for these
    old_man = "",
    elite_four_pokedex_condition = "",
    elite_four_key_items_condition = "",
    cerulean_cave_key_items_condition = "",
    extra_badges = "",
    blind_trainers = "",
    trainersanity = ""
}

function get_slot_options(slot_data)  

    if slot_data["old_man"] then
		local obj = Tracker:FindObjectForCode('opt_old_man')
		local setting = slot_data["old_man"]
		if setting == 2 then
			obj.CurrentStage = 1
		else
			obj.CurrentStage = 0
		end
	end

    if slot_data["elite_four_key_items_condition"] then
		local tens = Tracker:FindObjectForCode("e4k_digit1")
		local ones = Tracker:FindObjectForCode("e4k_digit2")
		local val = slot_data["elite_four_key_items_condition"]
		if tens and ones then
			tens.CurrentStage = val // 10
			ones.CurrentStage = val % 10
		end
	end

    if slot_data["elite_four_pokedex_condition"] then
		local hunds = Tracker:FindObjectForCode("e4p_digit1")
		local tens = Tracker:FindObjectForCode("e4p_digit2")
		local ones = Tracker:FindObjectForCode("e4p_digit3")
		local val = slot_data["elite_four_pokedex_condition"]
		if hunds and tens and ones then
			hunds.CurrentStage = val // 100
			tens.CurrentStage = val % 100 // 10
			ones.CurrentStage = val % 10
		end
	end

    if slot_data["cerulean_cave_key_items_condition"] then
		local tens = Tracker:FindObjectForCode("ccaveK_digit1")
		local ones = Tracker:FindObjectForCode("ccaveK_digit2")
		local val = slot_data["cerulean_cave_key_items_condition"]
		if tens and ones then
			tens.CurrentStage = val // 10
			ones.CurrentStage = val % 10
		end
	end
    
    if slot_data["extra_badges"] then
		hm_list = {"Cut", "Fly", "Surf", "Strength", "Flash"}
		stages = { boulder=1, cascade=2, thunder=3, rainbow=4, soul=5, marsh=6, volcano=7, earth=8}
		for i=1,5 do
			hm = hm_list[i]
			badge = slot_data["extra_badges"][hm]
			if  badge then
				badge = string.lower(badge)
				badge = string.gsub(badge, " badge", "")
				
				obj = Tracker:FindObjectForCode(string.lower(hm).."_"..badge)
				if obj then
					obj.CurrentStage = stages[badge]
				end

			end
		end

		badge = "boulder"
		hm = "fly"
	end

	if slot_data["blind_trainers"] then
		local sd_value = slot_data["blind_trainers"]
		if sd_value == 100 then
			Tracker:FindObjectForCode('opt_blind_trainers').CurrentStage = 1
		else
			Tracker:FindObjectForCode('opt_blind_trainers').CurrentStage = 0
		end
	end
end