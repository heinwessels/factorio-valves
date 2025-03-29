-- Just kept for migrating from composite valves to engine-supported. Can remove them at some point.

local function create_valve(valve_type)
  data:extend{
        {
            type = "pump",
            name = "valves-"..valve_type.."-legacy",
            icon = "__valves__/graphics/"..valve_type.."/icon.png",
            flags = {"placeable-neutral", "player-creation", "hide-alt-info"},
            hidden = true,
            max_health = 180,
            collision_box = {{-0.29, -0.45}, {0.29, 0.45}},
            selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
            icon_draw_specification = {scale = 0.5},
            resistances = { },
            fluid_box =
            {
                volume = 400,
                pipe_connections = { },
                hide_connection_info = true,
            },
            energy_source = { type = "void" },
            energy_usage = "1W",
            pumping_speed = settings.startup["valves-pump-speed"].value / 60, --[[@as number value given per second, convert to per tick]]

            animations = util.empty_animation(1),
        },
  }
end

create_valve("overflow")
create_valve("top_up")
create_valve("one_way")
