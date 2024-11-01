local function get_pipe_connections(is_input)
    if is_input then
        return {
            { direction = defines.direction.north,                              position = {0, -0.5}, flow_direction = "input-output" },
            { connection_type = "linked", flow_direction = "input-output", linked_connection_id=31113 }
        }
    else
        return {
            { connection_type = "linked", flow_direction = "input-output", linked_connection_id=31113 },
            { direction = defines.direction.south,                              position = {0, 0.5}, flow_direction = "input-output" }
        }
    end
end

local function create_hidden_tank(name, is_input)
    data:extend{
        {
            type = "storage-tank",
            name = name,
            icon = "__base__/graphics/icons/storage-tank.png",
            flags = {
                "not-repairable",
                "not-on-map",
                "not-deconstructable",
                "not-blueprintable",
                "not-flammable",
                "not-upgradable",
                "not-in-kill-statistics",
                "placeable-off-grid" -- To be directly above pump position
            },
            selectable_in_game = false,
            max_health = 500,
            selection_box = {{-0.5, -1}, {0.5, 1}}, -- Needs to be same as valve
            collision_box = {{-0.29, -1}, {0.29, 1}},
            fluid_box =
            {
                volume = 100,
                pipe_connections = get_pipe_connections(is_input),
                hide_connection_info = true,
            },
            show_fluid_icon = false,
            two_direction_only = true,
            window_bounding_box = {{0,0}, {0,0}},
            flow_length_in_ticks = 360,
            circuit_connector = circuit_connector_definitions["storage-tank"],
            circuit_wire_max_distance = default_circuit_wire_max_distance,
        },
    }
end


create_hidden_tank("configurable-valve-guage-input", true)
create_hidden_tank("configurable-valve-guage-output", false)