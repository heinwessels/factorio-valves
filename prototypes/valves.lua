local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local constants = require("__valves__.constants")

---@type table<ValveType, data.PipeConnectionDefinition[]>
local valve_pipe_connections = {
  ["overflow"] = {
    { direction = defines.direction.south, position = {0, 0}, flow_direction = "output" },
    { connection_type = "linked", flow_direction = "input", linked_connection_id=31113 - 1 }
  },
  ["top_up"] = {
    { connection_type = "linked", flow_direction = "output", linked_connection_id=31113 + 1 },
    { direction = defines.direction.north, position = {0, 0}, flow_direction = "input" }
  },
  ["one_way"] = {
    {connection_type = "linked", flow_direction = "output", linked_connection_id=31113 + 1 },
    {connection_type = "linked", flow_direction = "input", linked_connection_id=31113 - 1 }
  }
}

local function create_valve(valve_type)
  local name = "valves-"..valve_type
  data:extend{
      {
        type = "item",
        name = name,
        icon = "__valves__/graphics/"..valve_type.."/icon.png",
        subgroup = "energy-pipe-distribution",
        order = "b[pipe]-d["..name.."]",
        inventory_move_sound = item_sounds.fluid_inventory_move,
        pick_sound = item_sounds.fluid_inventory_pickup,
        drop_sound = item_sounds.fluid_inventory_move,
        place_result = name,
        stack_size = 20,
        random_tint_color = item_tints.iron_rust
      },
      {
        type = "recipe",
        name = name,
        energy_required = 2,
        ingredients = { }, -- Determined in data-updates
        results = {{type="item", name=name, amount=1}}
      },
      {
          type = "pump",
          name = name,
          icon = "__valves__/graphics/"..valve_type.."/icon.png",
          flags = {"placeable-neutral", "player-creation", "hide-alt-info"},
          localised_description = {"",
            {"entity-description."..name},
            " ",
            {"valves.more-in-factoriopedia"},
          },
          factoriopedia_description = {"",
            {"entity-description."..name},
            valve_type ~= "one_way" and {"valves.valve-shortcuts"} or nil,
            valve_type ~= "one_way" and {"valves.threshold-settings"} or nil,
          },
          minable = {mining_time = 0.2, result = name},
          allow_copy_paste = false, -- Because we can't detect pasting blueprint over existing entity.
          max_health = 180,
          fast_replaceable_group = "pipe",
          corpse = "pump-remnants",
          dying_explosion = "pump-explosion",
          collision_box = {{-0.29, -0.45}, {0.29, 0.45}},
          selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
          icon_draw_specification = {scale = 0.5},
          working_sound =
          {
            sound = { filename = "__base__/sound/pump.ogg", volume = 0.3 },
            audible_distance_modifier = 0.5,
            max_sounds_per_type = 2
          },
          damaged_trigger_effect = hit_effects.entity(),
          resistances =
          {
            {
              type = "fire",
              percent = 80
            },
            {
              type = "impact",
              percent = 30
            }
          },
          fluid_box =
          {
            volume = 400,
            pipe_covers = pipecoverspictures(),
            pipe_connections = valve_pipe_connections[valve_type],
            hide_connection_info = true,
          },
          energy_source = { type = "void" },
          energy_usage = "1W",
          pumping_speed = settings.startup["valves-pump-speed"].value / 60, --[[@as number value given per second, convert to per tick]]
          impact_category = "metal",
          open_sound = sounds.machine_open,
          close_sound = sounds.machine_close,

          animations =
          {
            north =
            {
              filename = "__valves__/graphics/"..valve_type.."/north.png",
              width = 128,
              height = 128,
              scale = 0.5,
              line_length = 1,
              frame_count = 1,
              animation_speed = 1,
            },
            east =
            {
              filename = "__valves__/graphics/"..valve_type.."/east.png",
              width = 128,
              height = 128,
              scale = 0.5,
              line_length = 1,
              frame_count = 1,
              animation_speed = 1,
            },
            south =
            {
              filename = "__valves__/graphics/"..valve_type.."/south.png",
              width = 128,
              height = 128,
              scale = 0.5,
              line_length = 1,
              frame_count = 1,
              animation_speed = 1,
            },
            west =
            {
              filename = "__valves__/graphics/"..valve_type.."/west.png",
              width = 128,
              height = 128,
              scale = 0.5,
              line_length = 1,
              frame_count = 1,
              animation_speed = 1,
            }
          },

          circuit_connector = circuit_connector_definitions.create_vector(universal_connector_template, {
            { variation = 24, main_offset = util.by_pixel(-15/2-3, -8.5/2), shadow_offset = util.by_pixel(0, -0.5), show_shadow = false },
            { variation = 26, main_offset = util.by_pixel(13.5/2, 4.5/2), shadow_offset = util.by_pixel(-7, -12.5), show_shadow = true },
            { variation = 24, main_offset = util.by_pixel(-14.5/2-3, -8.5/2), shadow_offset = util.by_pixel(-12.5, 6), show_shadow = false },
            { variation = 26, main_offset = util.by_pixel(-16/2, 3.5/2), shadow_offset = util.by_pixel(-14, 13.5), show_shadow = true },
          }),
          circuit_wire_max_distance = default_circuit_wire_max_distance
      },
  }
end

for valve_type in pairs(constants.valve_types) do
  create_valve(valve_type)
end