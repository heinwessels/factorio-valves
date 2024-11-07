local constants = require("__valves__.constants")
local util = require("util")

local configuration = { }

---@alias ValveType "overflow" | "top_up" | "one_way"

---@param behaviour LuaPumpControlBehavior
---@param valve_type ValveType
---@param player LuaPlayer?
function configuration.set_type(behaviour, valve_type, player)
    local new_circuit_condition = util.table.deepcopy(constants.valve_types[valve_type])

    if player and (valve_type == "overflow" or valve_type == "top_up") then
        -- TODO This is probably slow. Cache it
        local new_threshold = settings.get_player_settings(player)["valves-default-threshold-"..valve_type].value
        new_circuit_condition.constant = new_threshold
    end

    behaviour.circuit_condition = new_circuit_condition
end

---@param valve_type ValveType
---@param behaviour LuaPumpControlBehavior
---@param player LuaPlayer?
function configuration.initialize(valve_type, behaviour, player)
    if behaviour.circuit_enable_disable then
        -- This valve's condition has already been set. Don't overwrite it.
        -- Probably cause this is a ghost of a dead valve, or from a blueprint.
        return
    end

    behaviour.circuit_enable_disable = true
    configuration.set_type(behaviour, valve_type, player)
end

return configuration