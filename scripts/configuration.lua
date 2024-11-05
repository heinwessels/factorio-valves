local constants = require("__valves__.constants")

local configuration = { }

---@alias ValveType "overflow" | "top_up" | "one_way"

---@param behaviour LuaPumpControlBehavior
---@param valve_type ValveType
---@param player LuaPlayer?
function configuration.set_type(behaviour, valve_type, player)
    behaviour.circuit_condition = constants.valve_types[valve_type]
    ---@TODO Set custom threshold set per player setting
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