local constants = require("__valves__.constants")
local configuration = require("__valves__.scripts.configuration")

local builder = { }
local debug = false

---@param this LuaEntity
---@param that LuaEntity
---@return boolean
local function has_linked_pipe_connection(this, that)
    for index=1,#this.fluidbox do
        for _, connection in pairs(this.fluidbox.get_pipe_connections(index)) do
            if connection.connection_type == "linked" and connection.target then
                if connection.target.owner == that then
                    return true
                end
            end
        end
    end
    return false
end

---@param valve LuaEntity
---@param is_input boolean else it's an output
---@return LuaEntity
local function create_hidden_guage(valve, is_input)
    local guage = valve.surface.create_entity{
        name = "valves-guage-" .. (is_input and "input" or "output"),
        position = valve.position,
        force = valve.force,
        direction = valve.direction,
    }
    assert(guage)
    guage.destructible = false
    guage.fluidbox.add_linked_connection(31113, valve, 31113 + (is_input and -1 or 1))
    if debug then assert(has_linked_pipe_connection(valve, guage)) end
    return guage
end

---@param valve LuaEntity
---@param guage LuaEntity?
---@param is_input boolean else it's an output
---@return LuaWireConnector
local function create_hidden_combinator(valve, guage, is_input)
    local combinator = valve.surface.create_entity{
        name = "valves-tiny-combinator-" .. (is_input and "input" or "output"),
        position = valve.position,
        force = valve.force,
        create_build_effect_smoke = false
    }
    assert(combinator)
    combinator.destructible = false

    local behaviour = combinator.get_or_create_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior ]]
    behaviour.parameters = {
        first_signal = constants.signal.each,
        operation = '+',
        second_constant = 0,
        output_signal = is_input and constants.signal.input or constants.signal.output,
    }

    local combinator_output_connector = combinator.get_wire_connector(defines.wire_connector_id.combinator_output_green, true)
    local valve_connector = valve.get_wire_connector(defines.wire_connector_id.circuit_green, true)
    valve_connector.connect_to(combinator_output_connector, false, defines.wire_origin.script)

    if guage then
        local combinator_input_connector = combinator.get_wire_connector(defines.wire_connector_id.combinator_input_green, true)
        local guage_connector = guage.get_wire_connector(defines.wire_connector_id.circuit_green, true)
        guage_connector.connect_to(combinator_input_connector, false, defines.wire_origin.script)
    end

    return combinator_output_connector
end

---@param valve LuaEntity
---@param player LuaPlayer?
function builder.build(valve, player)
    local input_guage = create_hidden_guage(valve, true)
    local output_guage = create_hidden_guage(valve, false)

    local valve_type = constants.valve_names[valve.name]
    if constants.need.input[valve_type] then
        create_hidden_combinator(valve, input_guage, true)
    end
    if constants.need.output[valve_type] then
        create_hidden_combinator(valve, output_guage, false)
    end

    local control_behaviour = valve.get_or_create_control_behavior()
    ---@cast control_behaviour LuaPumpControlBehavior
    configuration.initialize(constants.valve_names[valve.name], control_behaviour, player)

    -- Otherwise the player could change it to anything they want by accident.
    if not debug then valve.operable = false end
end

---@param valve LuaEntity
function builder.destroy(valve)
    for _, name in pairs{
        "valves-guage-input",
        "valves-guage-output",
        "valves-tiny-combinator-input",
        "valves-tiny-combinator-output",
    } do
        local entity = valve.surface.find_entity(name, valve.position)
        if entity then entity.destroy() end
    end
end

---@param event EventData.on_robot_built_entity|EventData.on_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_entity_cloned
local function on_entity_created(event)
    local entity = event.entity
    local player = event.player_index and game.get_player(event.player_index) or nil
    if constants.valve_names[entity.name] then
        builder.build(entity, player)
    elseif entity.name == "entity-ghost" and constants.valve_names[entity.ghost_name] then
        local control_behaviour = entity.get_or_create_control_behavior()
        ---@cast control_behaviour LuaPumpControlBehavior
        configuration.initialize(constants.valve_names[entity.ghost_name], control_behaviour, player)
        if not debug then entity.operable = false end
    end
end

local function on_entity_destroyed(event)
    local entity = event.entity
    if constants.valve_names[entity.name] then
        builder.destroy(entity)
    end
end

---@param event EventData.on_player_rotated_entity
local function on_player_rotated_entity(event)
    local valve = event.entity
    if not constants.valve_names[valve.name] then return end
    for _, name in pairs{
        "valves-guage-input",
        "valves-guage-output",
    } do
        local entity = valve.surface.find_entity(name, valve.position)
        if entity then entity.direction = valve.direction end
    end
end

builder.events = {
    [defines.events.on_robot_built_entity] = on_entity_created,
    [defines.events.on_built_entity] = on_entity_created,
    [defines.events.script_raised_built] = on_entity_created,
    [defines.events.script_raised_revive] = on_entity_created,
    [defines.events.on_entity_cloned] = on_entity_created,
    [defines.events.on_space_platform_built_entity] = on_entity_created,

    [defines.events.on_player_mined_entity] = on_entity_destroyed,
    [defines.events.on_robot_mined_entity] = on_entity_destroyed,
    [defines.events.on_entity_died] = on_entity_destroyed,
    [defines.events.script_raised_destroy] = on_entity_destroyed,
    [defines.events.on_space_platform_mined_entity] = on_entity_destroyed,

    [defines.events.on_player_rotated_entity] = on_player_rotated_entity,
}

return builder