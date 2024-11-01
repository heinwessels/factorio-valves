local prototypes_with_fluidbox = {
    ["boiler"] = { "fluid_box" },
    ["fluid-turret"] = { "fluid_box" },
    ["fusion-generator"] = { "input_fluid_box", "output_fluid_box" },
    ["generator"] = { "fluid_box" },
    ["mining-drill"] = { "input_fluid_box", "output_fluid_box" },
    ["offshore-pump"] = { "fluid_box" },
    ["pipe"] = { "fluid_box" },
    ["pipe-to-ground"] = { "fluid_box" },
    ["pump"] = { "fluid_box" },
    ["storage-tank"] = { "fluid_box" },
    ["thruster"] = { "fuel_fluid_box", "oxidizer_fluid_box " },
}

local prototypes_with_fluidboxes = {
    ["assembling-machine"] = { "fluid_boxes" },
    ["furnace"] = { "fluid_boxes" },
}

---@param fluidbox data.FluidBox?
---@param prototype_type string
local function add_linked_connection(fluidbox, prototype_type)
    if not fluidbox then return end
    table.insert(fluidbox.pipe_connections, {
        flow_direction = prototype_type == "pump" and "input" or nil,
        direction = defines.direction.north,
        connection_type = "linked",
        position = {0, 0},
        linked_connection_id = 0xdeadbeef,
    })
end

for prototype_type, fluidbox_definitions in pairs(prototypes_with_fluidbox) do
    for name, prototype in pairs(data.raw[prototype_type] or { }) do
        if name ~= "configurable-valve" then
            for _, fluidbox_definition in pairs(fluidbox_definitions) do
                add_linked_connection(prototype[fluidbox_definition], prototype_type)
            end
        end
    end
end

for prototype_type, fluidboxes_definitions in pairs(prototypes_with_fluidboxes) do
    for _, prototype in pairs(data.raw[prototype_type] or { }) do
        for _, fluidboxes_definition in pairs(fluidboxes_definitions) do
            for _, fluidbox in pairs(prototype[fluidboxes_definition] or { }) do
                add_linked_connection(fluidbox, prototype_type)
            end
        end
    end
end
