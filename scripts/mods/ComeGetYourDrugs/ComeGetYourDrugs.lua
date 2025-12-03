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

--mod:hook_safe(CLASS.ActionPlaceDeployable, "_place_unit", _place_unit_hook_function)




------
------

local _init = function()
    mod._owner_session_id = nil
end

mod.on_all_mods_loaded = function()
    _init()
end

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateLoading" and status == "enter" then
        _init()
    end
end


mod:hook_safe("Unit", "animation_event", function(unit, event)
    if event == "drop" then
        local player = Managers.player:player_by_unit(unit)

        if player and player:is_human_controlled() then
            mod._owner_session_id = player:session_id()
        end
    end
end)

mod:hook_safe("Unit", "flow_event", function(unit, event)
    if event == "lua_deploy" and mod._owner_session_id then
        --[[
        local is_deployable = Unit.has_data(unit, "deployable_type")
        if not is_deployable then
            mod:echo("is_deployable = "..tostring(is_deployable))
            return
        end

        local deployable_type = Unit.get_data(unit, "deployable_type")
        if not deployable_type == "medical_crate" then
            -- This means the used item is not a medkit and not a stimm pack
            mod:echo("is_deployable = "..tostring(is_deployable)..", deployable_type = "..tostring(deployable_type))
            return
        end
        --]]

        if Unit.has_data(unit, "pickup_type") then
            mod:echo("Deployed item is (hopefully) not a medkit/stimm pack")
            return
        end

        local player = Managers.player:local_player(1)
        local deploying_player = Managers.player:player_from_session_id(mod._owner_session_id)
        local deploying_player_name = deploying_player._profile and deploying_player:name()

        if not deploying_player then
            mod:echo("deploying_player = nil/false")
            return
        elseif not player then
            mod:echo("player = nil/false")
            return
        end

        mod:echo("Player "..deploying_player_name.." placed deployable")

        if not deploying_player == player then
            mod:echo("Deploying player is not you")
            return
        end

        local deployable_position = Unit.world_position(unit, 1)

        place_marker(deployable_position)

        --local player_slot = player.slot and player:slot()
        --local player_name = player._profile and player:name()
        --local slot_color = mod:get("enable_slot_color") and player_slot and UISettings.player_slot_colors[player_slot]
        --local suffix = is_local_player(player) and "self" or "others"
        --local event_id = "auto_deployed_:s:_" .. suffix
        --local message_type = "deploy_"

        --[[
        if Unit.has_data(unit, "pickup_type") then
            event_id = string.gsub(event_id, ":s:", Unit.get_data(unit, "pickup_type"))
            message_type = message_type .. "ammo"
        else
            event_id = string.gsub(event_id, ":s:", "medical_crate_deployable")
            message_type = message_type .. "med"
        end
        --]]

        mod._owner_session_id = nil
    end
end)