data:extend{
    {
        type = "storage-tank",
        name = "valves-hidden-tank",
        icon = "__base__/graphics/icons/storage-tank.png",
        flags = {
            "not-repairable",
            "not-on-map",
            "not-deconstructable",
            "not-blueprintable",
            "not-flammable",
            "not-upgradable",
            "not-in-kill-statistics",
            "hide-alt-info",
            "placeable-off-grid" -- To be directly above pump position
        },
        selectable_in_game = false,
        max_health = 500,
        fluid_box =
        {
            volume = 100,
            pipe_connections = {
                {
                    direction = defines.direction.north,
                    connection_type = "linked",
                    position = {0, 0},
                    linked_connection_id = 0xdeadbeef,
                },
            },
            hide_connection_info = true
        },
        show_fluid_icon = false,
        two_direction_only = true,
        window_bounding_box = {{0,0}, {0,0}},
        flow_length_in_ticks = 360,
        circuit_connector = circuit_connector_definitions["storage-tank"],
        circuit_wire_max_distance = default_circuit_wire_max_distance,
    },
}

