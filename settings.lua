local constants = require("__valves__.constants")

local default_threshold_settings = {
    overflow = 80,
    top_up = 50,
}

for setting, valve_type in pairs(constants.setting_to_valve_type) do
    local default_value = default_threshold_settings[valve_type]
    assert(default_value, "unexpected condition for valve type "..valve_type)
    data:extend({
        {
            type = "int-setting",
            name = setting,
            setting_type = "startup",
            order = "a["..setting.."]",
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
        order = "b[pump-speed]",
        minimum_value = 60,
        maximum_value = 24000,
        default_value = 1200,
    },
    {
        type = "bool-setting",
        name = "valves-disable-py-migration",
        setting_type = "startup",
        order = "z[migration]-a[py]",
        default_value = false,
        hidden = mods["pyindustry"] == nil
    },
})