-- Open GUI of hidden combinator
-- /c local c = game.surfaces[1].find_entities_filtered{name="valves-tiny-combinator-input"}[1]; assert(c); game.player.opened = c

local debug = false

local constants = require("__configurable-valves__.constants")

---@param valve LuaEntity
local function set_defualt_behaviour(valve)
    local control_behaviour = valve.get_or_create_control_behavior()
    ---@cast control_behaviour LuaPumpControlBehavior

    if control_behaviour.circuit_enable_disable then
        -- This valve's condition has already been set. Don't overwrite it.
        return
    end

    control_behaviour.circuit_enable_disable = true
    control_behaviour.circuit_condition = constants.behaviour.overflow
end

---@param input "toggle" | "minus" | "plus"
---@param event EventData.CustomInputEvent
local function quick_toggle(input, event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local valve = player.selected
    if not valve then return end
    if valve.name ~= "configurable-valve" and not (
        valve.name == "entity-ghost" and valve.ghost_name == "configurable-valve"
    ) then return end

    ---@type "overflow" | "top_up" | "no_return"?
    local behaviour_type
    local control_behaviour = valve.get_or_create_control_behavior()
    ---@cast control_behaviour LuaPumpControlBehavior
    local circuit_condition = control_behaviour.circuit_condition --[[@as CircuitCondition]]
    local first = circuit_condition.first_signal and circuit_condition.first_signal.name
    local second = circuit_condition.second_signal and circuit_condition.second_signal.name
    local constant = circuit_condition.constant or 0
    if first == "signal-I" and not second and circuit_condition.comparator == ">" then
        behaviour_type = "overflow"
    elseif first == "signal-O" and not second and circuit_condition.comparator == "<" then
        behaviour_type = "top_up"
    elseif first == "signal-I" and second == "signal-O" and circuit_condition.comparator == ">" then
        behaviour_type = "no_return"
    end

    if input == "toggle" then
        local new_behaviour_type = behaviour_type and next(constants.behaviour, behaviour_type)
        if not new_behaviour_type then
            new_behaviour_type = next(constants.behaviour)
        end
        behaviour_type = new_behaviour_type
        control_behaviour.circuit_condition = constants.behaviour[behaviour_type]
        constant = control_behaviour.circuit_condition.constant
    else
        if not behaviour_type or behaviour_type == "no_return" then
            player.create_local_flying_text{text = {"configurable-valves.config-not-supported"}, create_at_cursor=true}
            return
        end
        constant = (math.floor(constant/10)*10) + (10 * (input == "plus" and 1 or -1 ))
        constant = math.min(100, math.max(0, constant))
        circuit_condition.constant = constant
        control_behaviour.circuit_condition = circuit_condition
    end

    valve.create_build_effect_smoke()
    local msg = {"", {"configurable-valves."..behaviour_type}}
    if constant then table.insert(msg, ": "..tostring(constant).."%") end
    player.create_local_flying_text{text = msg, position = valve.position, speed = 30}
end
for input, custom_input in pairs({
    toggle = "configurable-valves-switch",
    minus = "configurable-valves-minus",
    plus = "configurable-valves-plus",
}) do
    script.on_event(custom_input, function(e) quick_toggle(input, e) end)
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
local function handle_valve_creation(valve)
    local input_guage = valve.surface.create_entity{
        name = "configurable-valve-guage-input",
        position = valve.position,
        force = valve.force,
        direction = valve.direction,
    }
    assert(input_guage)
    input_guage.destructible = false
    input_guage.fluidbox.add_linked_connection(31113, valve, 31113-1)
    if debug then assert(has_linked_pipe_connection(valve, input_guage)) end

    local output_guage = valve.surface.create_entity{
        name = "configurable-valve-guage-output",
        position = valve.position,
        force = valve.force,
        direction = valve.direction,
    }
    assert(output_guage)
    output_guage.destructible = false
    output_guage.fluidbox.add_linked_connection(31113, valve, 31113+1)
    if debug then assert(has_linked_pipe_connection(valve, output_guage)) end

    create_hidden_combinator(valve, input_guage, true)
    create_hidden_combinator(valve, output_guage, false)

    set_defualt_behaviour(valve)
end

---@param valve LuaEntity
local function handle_valve_destroyed(valve)
    for _, name in pairs{
        "configurable-valve-guage-input",
        "configurable-valve-guage-output",
        "valves-tiny-combinator-input",
        "valves-tiny-combinator-output",
    } do
        local entity = valve.surface.find_entity(name, valve.position)
        if entity then entity.destroy() end
    end
end

---@param event EventData.on_player_rotated_entity
script.on_event(defines.events.on_player_rotated_entity, function(event)
    ---@TODO This doesn't work yet
    local valve = event.entity
    if valve.name ~= "configurable-valve" then return end
    for _, name in pairs{
        "configurable-valve-guage-input",
        "configurable-valve-guage-output",
    } do
        local entity = valve.surface.find_entity(name, valve.position)
        if entity then entity.direction = valve.direction end
    end
end)

-----------------------------------------------------------
--- DISPATCHER --------------------------------------------
-----------------------------------------------------------

---@param event EventData.on_robot_built_entity|EventData.on_built_entity|EventData.script_raised_built|EventData.script_raised_revive|EventData.on_entity_cloned
local function on_entity_created(event)
    local entity = event.entity
    if entity.name == "configurable-valve" then
        handle_valve_creation(entity)
    elseif entity.name == "entity-ghost" and entity.ghost_name == "configurable-valve" then
        set_defualt_behaviour(entity)
    end
end

local function on_entity_destroyed(event)
    local entity = event.entity
    if entity.name == "configurable-valve" then
        handle_valve_destroyed(entity)
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

