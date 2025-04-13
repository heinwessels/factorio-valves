local constants = require("__valves__.constants")
local migrator = require("__valves__.scripts.migrator")

local builder = { }

---@param valve LuaEntity
function builder.build(valve)
    local valve_type = constants.valve_names[valve.name]
    if valve_type ~= "overflow" or valve_type ~= "top_up" then return end

    -- We will set the valve's current threshold as the override
    -- threshold. That way if the player ever changes their default
    -- thresholds then it won't affect _all_ the already placed valves.
    -- This won't affect valves that already have overrides
    valve.valve_threshold_override = valve.valve_threshold_override
end

---@param event EventData.on_robot_built_entity|EventData.on_built_entity|EventData.script_raised_built|EventData.script_raised_revive
local function on_entity_created(event)
    local entity = event.entity
    if constants.valve_names[entity.name] then
        builder.build(entity)
    elseif entity.name == "entity-ghost" and constants.valve_names[entity.ghost_name] then
        builder.build(entity)
    end

    -- Also migrate legacy blueprints when placed.
    local migration_data = migrator.should_migrate(entity)
    if migration_data then migrator.migrate(entity, migration_data) end
end

builder.events = {
    [defines.events.on_robot_built_entity] = on_entity_created,
    [defines.events.on_built_entity] = on_entity_created,
    [defines.events.script_raised_built] = on_entity_created,
    [defines.events.script_raised_revive] = on_entity_created,
    [defines.events.on_space_platform_built_entity] = on_entity_created,
}

return builder