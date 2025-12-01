local mod = get_mod("ComeGetYourDrugs")

local place_marker = function(pos)
    local smart_tag_system = Managers.state.extension:system("smart_tag_system")

    local tag_types = {
        "location_attention",
        "location_ping",
        "location_threat",
    }
    local tag_type = tag_types[1]

    local player = Managers.player:local_player(1)
    local player_unit = player.player_unit

    -- Syntax: smart_tag_system:set_tag(template_name, player_unit, target_unit, target_location)
    smart_tag_system:set_tag(tag_type, player_unit, nil, pos)
end

--[[
mod.place_marker_on_player = function()
    local smart_tag_system = Managers.state.extension:system("smart_tag_system")

    local tag_types = {
        "location_attention",
        "location_ping",
        "location_threat",
    }
    local tag_type = tag_types[1]

    local player = Managers.player:local_player(1)
    local player_unit = player.player_unit

    local player_position = Unit.world_position(player_unit, 1)

    -- Syntax: smart_tag_system:set_tag(template_name, player_unit, target_unit, target_location)
    smart_tag_system:set_tag(tag_type, player_unit, nil, player_position)
end
--]]

---[[
mod.place_marker_on_player = function()
    local player = Managers.player:local_player(1)
    local player_unit = player.player_unit
    local player_position = Unit.world_position(player_unit, 1)

    -- Syntax: smart_tag_system:set_tag(template_name, player_unit, target_unit, target_location)
    place_marker(player_position)
end
--]]


local command_desc = "Testing function for ComeGetYourDrugs (WIP)"
mod:command("place_pos_marker", command_desc, mod.place_marker_on_player)


------

local _place_unit_hook_function = function(self, action_settings, position, rotation, placed_on_unit)
    --[[
    local weapon_template = self._weapon_template
	local pickup_name = action_settings.pickup_name or weapon_template.pickup_name
    mod:echo("Item deployed - pickup_name = "..tostring(pickup_name))
    --]]

    local deployable_settings = action_settings.deployable_settings
	local unit_template = deployable_settings.unit_template
    --[[
    mod:echo("Item deployed - unit_template is:")
    for key, value in pairs(unit_template) do
        local value_displayed = type(value) == string and value or "[Table]"
        mod:echo(key.." - "..value_displayed)
    end
    --]]
    mod:echo("Item deployed - unit_template = "..tostring(unit_template))

    if unit_template == "medical_crate_deployable" then
        place_marker(position)
    end
end

--mod:hook_safe(CLASS.ActionPlacePickup, "_place_unit", _place_unit_hook_function)
mod:hook_safe(CLASS.ActionPlaceDeployable, "_place_unit", _place_unit_hook_function)