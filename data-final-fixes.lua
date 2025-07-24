-- If the utility constant `max_fluid_flow` is higher than the "pump" speed then it will
-- then it will look like the valve is not pumping at full capacity. So instead we will
-- just cap the pump speed to the maximum fluid flow.
-- https://lua-api.factorio.com/latest/prototypes/UtilityConstants.html#max_fluid_flow
-- https://mods.factorio.com/mod/configurable-valves/discussion/687adff5090859d1e32f130e

local max_fluid_flow = data.raw["utility-constants"]["default"].max_fluid_flow
for valve_name in pairs(require("constants").valve_name_to_type) do
    assert(data.raw.valve[valve_name], "Valve '" .. valve_name .. "' not found in data.raw.valve")
    local valve = data.raw.valve[valve_name]
    valve.flow_rate = math.min(valve.flow_rate, max_fluid_flow)
end