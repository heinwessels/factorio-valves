data:extend({
    {
        type = "int-setting",
        name = "valves-default-threshold-top_up",
        setting_type = "runtime-per-user",
        minimum_value = 0,
        maximum_value = 100,
        default_value = 50,
    },
    {
        type = "int-setting",
        name = "valves-default-threshold-overflow",
        setting_type = "runtime-per-user",
        minimum_value = 0,
        maximum_value = 100,
        default_value = 80,
    },
})