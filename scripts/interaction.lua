local constants = require("__valves__.constants")

local interaction = {}

---@param threshold number
---@return string
local function format_threshold(threshold)
    return string.format("%d%%", math.floor((threshold * 100) + 0.5))
end

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
    if not constants.valve_names[entity.name] then return end -- TODO: Also show for ghosts
    local valve_type = constants.valve_names[entity.name]
    if valve_type == "one_way" then return end -- Doesn't have a threshold
    local threshold = entity.valve_threshold_override or constants.default_thresholds[valve_type]

    player_data.render_threshold = rendering.draw_text{
        text = format_threshold(threshold),
        surface = entity.surface,
        target = entity,
        color = {1, 1, 1, 0.8},
        scale = 1.5,
        vertical_alignment = "middle",
        players = { player },
        alignment = "center",
    }
end

---@param input "minus" | "plus"
---@param event EventData.CustomInputEvent
local function quick_toggle(input, event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local valve = player.selected
    if not valve then return end
    if not constants.valve_names[valve.name] and not (
        valve.name == "entity-ghost" and constants.valve_names[valve.ghost_name]
    ) then return end

    local valve_type = constants.valve_names[valve.name]
    if valve_type == "one_way" then
        player.create_local_flying_text{text = {"valves.configuration-doesnt-support-thresholds"}, create_at_cursor=true}
        return
    end

    local threshold = valve.valve_threshold_override or constants.default_thresholds[valve_type]
    threshold = threshold + (0.1 * (input == "plus" and 1 or -1 ))  -- Adjust
    threshold = math.min(1, math.max(0, threshold))                 -- Clamp
    threshold = math.floor(threshold * 10 + 0.5) / 10               -- Round
    valve.valve_threshold_override = threshold

    -- Visualize it to the player
    valve.create_build_effect_smoke()
    storage.players = storage.players or {}
    local player_data = storage.players[event.player_index]
    if not player_data then return end
    if player_data.render_threshold then
        player_data.render_threshold.text = format_threshold(threshold)
    end
end


interaction.events = {
    [defines.events.on_selected_entity_changed] = on_selected_entity_changed,
}
for input, custom_input in pairs({
    minus = "valves-threshold-minus",
    plus = "valves-threshold-plus",
}) do
    interaction.events[custom_input] = function(e) quick_toggle(input, e) end
end

return interaction
