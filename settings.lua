local constants = require("__valves__.constants")

for setting, valve_type in pairs(constants.setting_to_valve_type) do
    local default_value = constants.valve_types[valve_type].constant
    assert(default_value, "unexpected condition for valve type "..valve_type)
    data:extend({
        {
            type = "int-setting",
            name = setting,
            setting_type = "startup",
            minimum_value = 0,
            maximum_value = 100,
            default_value = default_value,
        },
    })
end

data:extend({
    {
        type = "int-setting",
        name = "valves-pump-speed",
        setting_type = "startup",
        minimum_value = 60,
        maximum_value = 24000,
        default_value = 1200,
    },
})