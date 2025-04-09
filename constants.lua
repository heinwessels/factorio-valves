local constants = { }

---@type table<ValveType, boolean>
constants.valve_types = {
    overflow    = true,
    top_up      = true,
    one_way     = true,
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

if prototypes and script then
    -- We're in runtime! Store the default values
    ---@type table<ValveType, number>
    constants.default_thresholds = { }
    for valve_type in pairs(constants.valve_types) do
        if valve_type == "one_way" then goto continue end
        local threshold = prototypes.entity["valves-"..valve_type].valve_threshold
        constants.default_thresholds[valve_type] = threshold
        ::continue::
    end
end

return constants