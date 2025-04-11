--- First we changed something about player data so just destroy it completely.
--- Including the render objects. It will be recreated when the player selects a valve again.
for _, player_data in pairs(storage.players) do
    if player_data.render_threshold then
        player_data.render_threshold.destroy()
    end
end
storage.players = { }


---@type table<string, string>
local legacy_name_to_type = {
    ["valves-overflow-legacy"]  = "overflow",
    ["valves-top_up-legacy"]    = "top_up",
    ["valves-one_way-legacy"]   = "one_way",
}

local constants = require("__valves__.constants")

--- Now we need to migrate our old valves to the new ones. We used a json migration
--- to turn them into legacy versions. So we just find all those and replace them
--- with a new one.
---@param old_valve LuaEntity
local function replace_valve(old_valve)
    local surface = old_valve.surface
    local position = old_valve.position
    local direction = old_valve.direction
    local force = old_valve.force
    local health = old_valve.health
    local valve_type = legacy_name_to_type[old_valve.name]
    local quality = old_valve.quality
    local threshold

    if valve_type == "overflow" or valve_type == "top_up" then
        local control_behaviour = old_valve.get_or_create_control_behavior()
        ---@cast control_behaviour LuaPumpControlBehavior
        local circuit_condition = control_behaviour.circuit_condition --[[@as CircuitCondition]]
        threshold = circuit_condition.constant or constants.default_thresholds[valve_type]
        threshold = threshold / 100 -- Convert to a fraction which the new system uses
        threshold = math.min(1, math.max(0, threshold)) -- Clamp to 0-1
    end

    -- We need to destroy the old one first so that the fluid connections
    -- so are recreated correctly I think.
    old_valve.destroy{raise_destroy = true} -- Tell other mods, we don't listen anyway

    local new_valve = surface.create_entity{
        name = "valves-" .. valve_type,
        position = position,
        force = force,
        direction = direction,
        quality = quality,
        raise_built = true, -- We listen to this, but doesn't really matter
    }
    new_valve.health = health
    if threshold then
        new_valve.valve_threshold_override = threshold
    end
end

for _, surface in pairs(game.surfaces) do
    for old_legacy_name in pairs(legacy_name_to_type) do
        for _, old_valve in pairs(surface.find_entities_filtered{name = old_legacy_name}) do
            replace_valve(old_valve)
        end
    end
end