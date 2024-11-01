-- Open GUI of hidden combinator
-- /c local c = game.surfaces[1].find_entities_filtered{name="valves-tiny-combinator-input"}[1]; assert(c); game.player.opened = c

local signal_each = { type = 'virtual', name = 'signal-each' }
local signal_input = { type = "virtual", name="signal-I" }
local signal_output = { type = "virtual", name="signal-O" }

---@type table<string, boolean>
local entity_has_fluidbox = { }
for name, prototype in pairs(prototypes.entity) do
    if name == "configurable-valve" then goto continue end
    if not next(prototype.fluidbox_prototypes) then goto continue end

    entity_has_fluidbox[name] = true

    ::continue::
end

-----------------------------------------------------------
--- LOGIC -------------------------------------------------
-----------------------------------------------------------

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

---@param entity LuaEntity
---@return LuaEntity? valve
local function find_connected_valve(entity)
    for index=1,#entity.fluidbox do
        for _, connection in pairs(entity.fluidbox.get_pipe_connections(index)) do
            local target = connection.target
            if target and target.owner.name == "configurable-valve" then
                return target.owner
            end
        end
    end
end

---@param valve LuaEntity
---@param direction "input" | "output"
---@return LuaEntity? guage
local function find_connectable(valve, direction)
    for _, connection in pairs(valve.fluidbox.get_pipe_connections(1)) do
        if connection.flow_direction ~= direction then goto continue end
        local target = connection.target
        if target then
            return target.owner
        end
        ::continue::
    end
end

---@param valve LuaEntity
---@param direction "input" | "output"
---@return LuaEntity? guage
local function try_create_guage(valve, direction)
    local connectable = find_connectable(valve, direction)
    if not connectable then return end

    -- We place the guage either on the input pipe, or on the valve.
    -- Never on the output pipe. This makes finding them easy.
    local guage = connectable.surface.create_entity{
        name = "valves-hidden-tank",
        position = direction == "input" and connectable.position or valve.position,
        force = connectable.force,
        create_build_effect_smoke = false
    }
    assert(guage)
    connectable.fluidbox.add_linked_connection(0xdeadbeef, guage, 0xdeadbeef)
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

    local behaviour = combinator.get_or_create_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior ]]
    behaviour.parameters = {
        first_signal = signal_each,
        operation = '+',
        second_constant = 0,
        output_signal = is_input and signal_input or signal_output,
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

---@param entity LuaEntity
local function handle_connectable_creation(entity)
    local valve = find_connected_valve(entity)
    if valve then
        local input_guage = try_create_guage(valve, "input")
        create_hidden_combinator(valve, input_guage, true)
    end

end

---@param entity LuaEntity
local function handle_connectable_destroyed(entity)
end

---@param valve LuaEntity
local function handle_valve_creation(valve)
    local input_guage = valve.surface.create_entity{
        name = "configurable-valve-guage-input",
        position = valve.position,
        force = valve.force,
        direction = valve.direction,
    }
    assert(input_guage)
    input_guage.fluidbox.add_linked_connection(31113, valve, 31113-1)
    assert(has_linked_pipe_connection(valve, input_guage))

    local output_guage = valve.surface.create_entity{
        name = "configurable-valve-guage-output",
        position = valve.position,
        force = valve.force,
        direction = valve.direction,
    }
    assert(output_guage)
    output_guage.fluidbox.add_linked_connection(31113, valve, 31113+1)
    assert(has_linked_pipe_connection(valve, output_guage))

    -- local input_guage = try_create_guage(valve, "input")
    create_hidden_combinator(valve, input_guage, true)
    -- local output_guage = try_create_guage(valve, "output")
    create_hidden_combinator(valve, output_guage, false)
end

---@param valve LuaEntity
local function handle_valve_destroyed(valve)
    local output_gauge = valve.surface.find_entity("valves-hidden-tank", valve.position)
    if output_gauge then output_gauge.destroy() end
    local connectable = find_connectable(valve, "input")
    if connectable then
        local input_guage = connectable.surface.find_entity("valves-hidden-tank", connectable.position)
        if input_guage then input_guage.destroy() end
    end
end

-----------------------------------------------------------
--- DISPATCHER --------------------------------------------
-----------------------------------------------------------

---@param event EventData.on_robot_built_entity|EventData.on_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_entity_cloned
local function on_entity_created(event)
    local entity = event.entity
    if entity.name == "configurable-valve" then
        handle_valve_creation(entity)
    elseif entity_has_fluidbox[entity.name] then
        handle_connectable_creation(entity)
    end
end

local function on_entity_destroyed(event)
    local entity = event.entity
    if entity.name == "configurable-valve" then
        handle_valve_destroyed(entity)
    elseif entity_has_fluidbox[entity.name] then
        handle_connectable_destroyed(entity)
    end
end

script.on_event(defines.events.on_robot_built_entity, on_entity_created)
script.on_event(defines.events.on_built_entity, on_entity_created)
script.on_event(defines.events.script_raised_built, on_entity_created)
script.on_event(defines.events.script_raised_revive, on_entity_created)
script.on_event(defines.events.on_entity_cloned, on_entity_created)
script.on_event(defines.events.on_space_platform_built_entity, on_entity_created)

script.on_event(defines.events.on_player_mined_entity, on_entity_destroyed)
script.on_event(defines.events.on_robot_mined_entity, on_entity_destroyed)
script.on_event(defines.events.on_entity_died, on_entity_destroyed)
script.on_event(defines.events.script_raised_destroy, on_entity_destroyed)
script.on_event(defines.events.on_space_platform_mined_entity, on_entity_destroyed)

