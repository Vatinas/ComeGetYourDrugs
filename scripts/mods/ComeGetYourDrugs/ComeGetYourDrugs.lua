local mod = get_mod("ComeGetYourDrugs")

local SmartTag = require("scripts/extension_systems/smart_tag/smart_tag")
local REMOVE_TAG_REASONS = SmartTag.REMOVE_TAG_REASONS
local reason_cancelled_by_owner = REMOVE_TAG_REASONS.canceled_by_owner

mod.waiting_for_tag = false
mod.tag_id = nil
mod.tracked_deployable = nil


mod.remove_tag = function()
    if not mod.tag_id then
        mod:echo("Error - Tried to remove a tag when none are known to be placed by the mod")
        return
    end
    local smart_tag_system = Managers.state.extension:system("smart_tag_system")
    local player = Managers.player:local_player(1)
    local player_unit = player.player_unit
    mod:echo("Removing tag")
    smart_tag_system:cancel_tag(mod.tag_id, player_unit, reason_cancelled_by_owner)
    mod.tag_id = nil
end


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

    -- Remember that we're waiting for a tag to be placed so we can store the tag_id to remove it later
    mod.waiting_for_tag = true
    -- Syntax: smart_tag_system:set_tag(template_name, player_unit, target_unit, target_location)
    smart_tag_system:set_tag(tag_type, player_unit, nil, pos)
    --[[
    local res = smart_tag_system:set_tag(tag_type, player_unit, nil, pos)
    if res then
        mod:echo("Returned from set_tag: "..tostring(res))
    end
    --]]
end

-- Track placed tags to yoink the tag_id that we need
mod:hook_safe(CLASS.SmartTagSystem, "_create_tag_locally", function(self, tag_id, template_name, tagger_unit, target_unit, target_location, replies, is_hotjoin_synced)
    if mod.waiting_for_tag then
        mod.tag_id = tag_id
        mod.waiting_for_tag = false
    end
end)

-- Check if we need to remove the tag
mod.update = function(dt)
    if not mod.tag_id then
        return
    end
    if not Unit.alive(mod.tracked_deployable) then
        -- Deployable has expired, let's remove its tag
        mod.remove_tag()
        mod.tracked_deployable = nil
    end
end


mod.place_marker_on_player = function()
    local player = Managers.player:local_player(1)
    local player_unit = player.player_unit
    local player_position = Unit.world_position(player_unit, 1)

    -- Syntax: smart_tag_system:set_tag(template_name, player_unit, target_unit, target_location)
    place_marker(player_position)
end


mod:command("place_pos_marker", "Place a tag on the player's position", mod.place_marker_on_player)
mod:command("remove_marker", "Remove the tag currently placed by the mod, if there is one", mod.remove_tag)


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

        local message_prefix = deploying_player_name.." placed a medkit/stimm pack - "

        if deploying_player ~= player then
            mod:echo(message_prefix.."This is not you, I won't do anything")
            return
        else
            mod:echo(message_prefix.."This is you, placing marker")
        end

        local deployable_position = Unit.world_position(unit, 1)

        place_marker(deployable_position)
        mod.tracked_deployable = unit

        mod._owner_session_id = nil
    end
end)