local constants = require("__valves__.constants")
local util = require("util")

local configuration = { }

---@alias ValveType "overflow" | "top_up" | "one_way"

---@param behaviour LuaPumpControlBehavior
---@param valve_type ValveType
---@param overwrite_threshold integer?
function configuration.set_type(behaviour, valve_type, overwrite_threshold)
    local new_circuit_condition = util.table.deepcopy(constants.valve_types[valve_type])

    if valve_type == "overflow" or valve_type == "top_up" then
        new_circuit_condition.constant = overwrite_threshold or storage.default_thresholds[valve_type]
    end

    behaviour.circuit_condition = new_circuit_condition
end

---@param valve_type ValveType
---@param behaviour LuaPumpControlBehavior
function configuration.initialize(valve_type, behaviour)
    -- This needs to account for:
    --  - Blueprints/died-ghosts being built with existing thresholds
    --  - New ghosts being placed with default thresholds.
    --  - Outdated blueprints being placed with outdated conditions.
    --  - The rebuilder rebuilding all valves
    -- Therefore we will always overwrite the main circuit conditions, and if
    -- it had a threshold before, then we will apply that again.

    ---@type integer?
    local old_threshold
    if (valve_type == "overflow" or valve_type == "top_up") and behaviour.circuit_enable_disable then
        old_threshold = behaviour.circuit_condition.constant
    end

    behaviour.circuit_enable_disable = true
    configuration.set_type(behaviour, valve_type, old_threshold)
end

---@param event EventData.on_runtime_mod_setting_changed
local function on_runtime_mod_setting_changed(event)
    local valve_type = constants.setting_to_valve_type[event.setting]
    if not valve_type then return end -- Not our setting
    storage.default_thresholds[valve_type] = settings.global[event.setting].value --[[@as uint]]
end

configuration.events = {
    [defines.events.on_runtime_mod_setting_changed] = on_runtime_mod_setting_changed,
}

local function init()
    ---@type table<ValveType, uint>
    storage.default_thresholds = { }
    for setting, valve_type in pairs(constants.setting_to_valve_type) do
        storage.default_thresholds[valve_type] = settings.global[setting].value --[[@as uint]]
    end
end
configuration.on_init = init
configuration.on_configuration_changed = init

return configuration