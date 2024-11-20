local constants = require("__valves__.constants")

local cursor = {}

local function on_selected_entity_changed(event)
    local player = game.get_player(event.player_index) --[[@cast player -? ]]

    -- Don't want to set up all the plumbing to create this data.
    -- This is a slow event, so it might be okay for now.
    storage.players = storage.players or {}
    local player_data = storage.players[event.player_index]
    if not player_data then
        storage.players[event.player_index] = {}
        player_data = storage.players[event.player_index]
    end

    -- Always destroy all current render_objects, if any, to keep logic simple.
    -- Regardless of wity is now selected.
    if player_data.render_threshold and player_data.render_threshold.valid then
        player_data.render_threshold.destroy()
    end
    player_data.render_threshold = nil

    local entity = player.selected
    if not (entity and entity.valid) then return end
    if not constants.valve_names[entity.name] then return end -- Ignore ghosts
    if constants.valve_names[entity.name] == "one_way" then return end -- Doesn't have a threshold

    local control_behaviour = entity.get_or_create_control_behavior()
    local constant = control_behaviour.circuit_condition.constant
    if not constant then return end
    ---@cast control_behaviour LuaPumpControlBehavior
    player_data.render_threshold = rendering.draw_text{
        text = tostring(constant),
        surface = entity.surface,
        target = entity,
        color = {1, 1, 1, 0.8},
        scale = 1.5,
        vertical_alignment = "middle",
        players = { player },
        alignment = "center",
    }
end

cursor.events = {
    [defines.events.on_selected_entity_changed] = on_selected_entity_changed,
}

return cursor
