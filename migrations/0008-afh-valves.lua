-- This migration turns all the old 1.1 py-valves into a configurable valve
-- with the correct circuit conditions

if not script.active_mods["underground-pipe-pack"] then return end

local util = require("util")

local replace_behaviour = {
    ["10-overflow-valve"]   = { name = "valves-overflow", constant = 10 },
    ["20-overflow-valve"]   = { name = "valves-overflow", constant = 20 },
    ["30-overflow-valve"]   = { name = "valves-overflow", constant = 30 },
    ["40-overflow-valve"]   = { name = "valves-overflow", constant = 40 },
    ["50-overflow-valve"]   = { name = "valves-overflow", constant = 50 },
    ["60-overflow-valve"]   = { name = "valves-overflow", constant = 60 },
    ["70-overflow-valve"]   = { name = "valves-overflow", constant = 70 },
    ["80-overflow-valve"]   = { name = "valves-overflow", constant = 80 },
    ["90-overflow-valve"]   = { name = "valves-overflow", constant = 90 },
    ["10-top-up-valve"]   = { name = "valves-top_up", constant = 10 },
    ["20-top-up-valve"]   = { name = "valves-top_up", constant = 20 },
    ["30-top-up-valve"]   = { name = "valves-top_up", constant = 30 },
    ["40-top-up-valve"]   = { name = "valves-top_up", constant = 40 },
    ["50-top-up-valve"]   = { name = "valves-top_up", constant = 50 },
    ["60-top-up-valve"]   = { name = "valves-top_up", constant = 60 },
    ["70-top-up-valve"]   = { name = "valves-top_up", constant = 70 },
    ["80-top-up-valve"]   = { name = "valves-top_up", constant = 80 },
    ["90-top-up-valve"]   = { name = "valves-top_up", constant = 90 },
    ["check-valve"]      = { name = "valves-one_way" },
}

for _, surface in pairs(game.surfaces) do
    for entity_name, config in pairs(replace_behaviour) do
        for _, entity in pairs(surface.find_entities_filtered{name = entity_name}) do
            local position = entity.position
            local direction = util.oppositedirection(entity.direction)
            local force = entity.force
            entity.destroy{raise_destroy = true}

            local valve = surface.create_entity{
                name = config.name,
                position = position,
                force = force,
                direction = direction,
                raise_built = true,
            }
            if not entity_name ~= "check-valve" then
                local control_behaviour = valve.get_or_create_control_behavior()
                local circuit_condition = control_behaviour.circuit_condition
                circuit_condition.constant = config.constant
                control_behaviour.circuit_condition = circuit_condition
            end
        end
    end
end