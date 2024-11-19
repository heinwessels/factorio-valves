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
    guage.mirroring = valve.mirroring -- Technically not needed.
    guage.destructible = false
    guage.fluidbox.add_linked_connection(31113, valve, 31113 + (is_input and -1 or 1))
    if debug then assert(has_linked_pipe_connection(valve, guage)) end
    return guage
end

---@type table<ValveType, fun(valve:LuaEntity)>
local build_valve_type = {
    ["overflow"] = function(valve)
        local guage = create_hidden_guage(valve, true)
        local valve_connector = valve.get_wire_connector(defines.wire_connector_id.circuit_green, true)
        local guage_connector = guage.get_wire_connector(defines.wire_connector_id.circuit_green, true)
        valve_connector.connect_to(guage_connector, false, defines.wire_origin.script)
    end,
    ["top_up"] = function(valve)
        local guage = create_hidden_guage(valve, false)
        local valve_connector = valve.get_wire_connector(defines.wire_connector_id.circuit_green, true)
        local guage_connector = guage.get_wire_connector(defines.wire_connector_id.circuit_green, true)
        valve_connector.connect_to(guage_connector, false, defines.wire_origin.script)
    end,
    ["one_way"] = function(valve)
        local combinator = valve.surface.create_entity{
            name = "valves-tiny-combinator",
            position = valve.position,
            force = valve.force,
            create_build_effect_smoke = false
        }
        assert(combinator)
        combinator.destructible = false
        local behaviour = combinator.get_or_create_control_behavior() --[[@as LuaDeciderCombinatorControlBehavior ]]

        behaviour.set_condition(1, {
            comparator = ">",
            compare_type = "or",
            first_signal = constants.signal.each,
            first_signal_networks = { green = true, red = false },
            second_signal = constants.signal.each,
            second_signal_networks = { green = false, red = true },
        })

        behaviour.set_output(1, {
            copy_count_from_input = false,
            networks = { green = true, red = false },
            signal = constants.signal.check,
        })

        do
            local input_guage = create_hidden_guage(valve, true)
            local input_guage_connector = input_guage.get_wire_connector(defines.wire_connector_id.circuit_green, true)
            local combinator_input_green = combinator.get_wire_connector(defines.wire_connector_id.combinator_input_green, true)
            input_guage_connector.connect_to(combinator_input_green, false, defines.wire_origin.script)
        end

        do
            local output_guage = create_hidden_guage(valve, false)
            local output_guage_connector = output_guage.get_wire_connector(defines.wire_connector_id.circuit_red, true)
            local combinator_input_red = combinator.get_wire_connector(defines.wire_connector_id.combinator_input_red, true)
            output_guage_connector.connect_to(combinator_input_red, false, defines.wire_origin.script)
        end

        do
            local valve_connector = valve.get_wire_connector(defines.wire_connector_id.circuit_green, true)
            local combinator_output_connector = combinator.get_wire_connector(defines.wire_connector_id.combinator_output_green, true)
            valve_connector.connect_to(combinator_output_connector, false, defines.wire_origin.script)
        end
    end,
}

---@param valve LuaEntity
function builder.build(valve)
    ---@type ValveType
    local valve_type = constants.valve_names[valve.name]

    build_valve_type[valve_type](valve)

    local control_behaviour = valve.get_or_create_control_behavior()
    ---@cast control_behaviour LuaPumpControlBehavior
    configuration.initialize(valve_type, control_behaviour)

    -- Otherwise the player could change it to anything they want by accident.
    if not debug then valve.operable = false end
end

---@param valve LuaEntity
function builder.destroy(valve)
    for _, name in pairs{
        "valves-guage-input",
        "valves-guage-output",
        "valves-tiny-combinator",
    } do
        local entity = valve.surface.find_entity(name, valve.position)
        if entity then entity.destroy() end
    end
end

---@param event EventData.on_robot_built_entity|EventData.on_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_entity_cloned
local function on_entity_created(event)
    local entity = event.entity or event.destination
    if constants.valve_names[entity.name] then
        if event.name == defines.events.on_entity_cloned then
            -- If it's a clone event they destroy it and recreate it to make sure all the parts are there.
            -- This is in case a mod calls `entity.clone(...)`. If it's an area or brush clone then all
            -- the components will already be cloned so it won't be duplicated, cause this event is only
            -- called _after_ all entities have been cloned.
            builder.destroy(entity)
        end

        builder.build(entity)
    elseif entity.name == "entity-ghost" and constants.valve_names[entity.ghost_name] then
        local control_behaviour = entity.get_or_create_control_behavior()
        ---@cast control_behaviour LuaPumpControlBehavior
        configuration.initialize(constants.valve_names[entity.ghost_name], control_behaviour)
        if not debug then entity.operable = false end
    end
end

local function on_entity_destroyed(event)
    local entity = event.entity
    if constants.valve_names[entity.name] then
        builder.destroy(entity)
    end
end

---@param event EventData.on_player_rotated_entity|EventData.on_player_flipped_entity
local function on_entity_changed_direction(event)
    local valve = event.entity
    if not constants.valve_names[valve.name] then return end
    for _, name in pairs{
        "valves-guage-input",
        "valves-guage-output",
    } do
        local entity = valve.surface.find_entity(name, valve.position)
        if entity then
            entity.direction = valve.direction
            entity.mirroring = valve.mirroring -- Technically not required, because the valves just rotate.
        end
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

    [defines.events.on_player_rotated_entity] = on_entity_changed_direction,
    [defines.events.on_player_flipped_entity] = on_entity_changed_direction,

}

return builder