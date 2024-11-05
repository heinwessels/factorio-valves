local constants = { }

---@type table<string, SignalID>
constants.signal = {
    each =      { type = 'virtual', name = "signal-each" },
    input =     { type = "virtual", name = "signal-I" },
    output =    { type = "virtual", name = "signal-O" },
}

---@type table<ValveType, CircuitCondition>
constants.valve_types = {
    overflow    = { comparator = '>', first_signal = constants.signal.input,  constant = 80, },
    top_up      = { comparator = '<', first_signal = constants.signal.output, constant = 50, },
    one_way     = { comparator = '>', first_signal = constants.signal.input,  second_signal = constants.signal.output, },
}

---@type table<string, ValveType>
constants.valve_names = { }
for valve_type in pairs(constants.valve_types) do
    constants.valve_names["valves-"..valve_type] = valve_type
end

return constants