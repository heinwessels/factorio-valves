local constants = require("__valves__.constants")

local shortcuts = { }

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

    local control_behaviour = valve.get_or_create_control_behavior()
    ---@cast control_behaviour LuaPumpControlBehavior
    local circuit_condition = control_behaviour.circuit_condition --[[@as CircuitCondition]]
    local constant = circuit_condition.constant or 50
    local valve_type = constants.valve_names[valve.name]

    if valve_type == "one_way" then
        player.create_local_flying_text{text = {"valves.configuration-doesnt-support-thresholds"}, create_at_cursor=true}
        return
    end

    constant = (math.floor(constant/10)*10) + (10 * (input == "plus" and 1 or -1 ))
    constant = math.min(100, math.max(0, constant))
    circuit_condition.constant = constant
    control_behaviour.circuit_condition = circuit_condition

    valve.create_build_effect_smoke()
    local msg = {"", {"valves."..valve_type}}
    if constant then table.insert(msg, ": "..tostring(constant).."%") end
    player.create_local_flying_text{text = msg, position = valve.position, speed = 30}
end

shortcuts.events = { }
for input, custom_input in pairs({
    minus = "valves-threshold-minus",
    plus = "valves-threshold-plus",
}) do
    shortcuts.events[custom_input] = function(e) quick_toggle(input, e) end
end


return shortcuts