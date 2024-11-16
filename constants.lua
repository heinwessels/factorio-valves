local constants = { }

---@type table<string, SignalID>
constants.signal = {
    each =      { type = 'virtual', name = "signal-each" },
    any =       { type = 'virtual', name = "signal-anything" },
    everything ={ type = 'virtual', name = "signal-everything" },
    input =     { type = "virtual", name = "signal-I" },
    output =    { type = "virtual", name = "signal-O" },
    check =     { type = "virtual", name = "signal-check" },
}

---@type table<ValveType, CircuitCondition>
constants.valve_types = {
    overflow    = { comparator = '>', first_signal = constants.signal.any,          constant = 80, },
    top_up      = { comparator = '<', first_signal = constants.signal.everything,   constant = 50, },
    one_way     = { comparator = '>', first_signal = constants.signal.check,        constant = 0, },
}

---@type table<string, ValveType>
constants.valve_names = { }
for valve_type in pairs(constants.valve_types) do
    constants.valve_names["valves-"..valve_type] = valve_type
end

---@type table<string, ValveType>
constants.setting_to_valve_type = { }
for valve_type in pairs(constants.valve_types) do
    if valve_type ~= "one_way" then
        constants.setting_to_valve_type["valves-default-threshold-"..valve_type] = valve_type
    end
end

return constants