local constants = require("__valves__.constants")
local util = require("util")

local configuration = { }

---@alias ValveType "overflow" | "top_up" | "one_way"

---@param behaviour LuaPumpControlBehavior
---@param valve_type ValveType
function configuration.set_type(behaviour, valve_type)
    local new_circuit_condition = util.table.deepcopy(constants.valve_types[valve_type])

    if valve_type == "overflow" or valve_type == "top_up" then
        new_circuit_condition.constant = storage.default_thresholds[valve_type]
    end

    behaviour.circuit_condition = new_circuit_condition
end

---@param valve_type ValveType
---@param behaviour LuaPumpControlBehavior
function configuration.initialize(valve_type, behaviour)
    if behaviour.circuit_enable_disable then
        -- This valve's condition has already been set. Don't overwrite it.
        -- Probably cause this is a ghost of a dead valve, or from a blueprint.
        return
    end

    behaviour.circuit_enable_disable = true
    configuration.set_type(behaviour, valve_type)
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