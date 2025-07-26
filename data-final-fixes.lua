local max_fluid_flow = data.raw["utility-constants"]["default"].max_fluid_flow
---@type table<ValveMode, float>
local default_threshold_settings = {
    ["overflow"] = settings.startup["valves-default-threshold-overflow"].value /  100,
    ["top-up"] = settings.startup["valves-default-threshold-top_up"].value /  100, -- Note: uses old style
}

for valve_name in pairs(data.raw["mod-data"]["mod-valves"].data.valves --[[@as table]]) do
    local valve = data.raw.valve[valve_name]
    assert(valve, "Valve '" .. valve_name .. "' not found in data.raw.valve")

    -- If the utility constant `max_fluid_flow` is higher than the "pump" speed then it will
    -- then it will look like the valve is not pumping at full capacity. So instead we will
    -- just cap the pump speed to the maximum fluid flow.
    -- https://lua-api.factorio.com/latest/prototypes/UtilityConstants.html#max_fluid_flow
    -- https://mods.factorio.com/mod/configurable-valves/discussion/687adff5090859d1e32f130e
    valve.flow_rate = math.min(valve.flow_rate, max_fluid_flow)

    -- Also ensure it uses the correct default value
    if valve.mode == "overflow" or valve.mode == "top-up" then
        valve.threshold = default_threshold_settings[valve.mode] or valve.threshold
    end
end
