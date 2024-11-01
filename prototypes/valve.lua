local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

data:extend{
    {
      type = "item",
      name = "configurable-valve",
      icon = "__base__/graphics/icons/pump.png",
      subgroup = "energy-pipe-distribution",
      order = "b[pipe]-c[pump]",
      inventory_move_sound = item_sounds.fluid_inventory_move,
      pick_sound = item_sounds.fluid_inventory_pickup,
      drop_sound = item_sounds.fluid_inventory_move,
      place_result = "configurable-valve",
      stack_size = 20,
      random_tint_color = item_tints.iron_rust
    },
    {
      type = "recipe",
      name = "configurable-valve",
      energy_required = 2,
      enabled = false,
      ingredients =
      {
        {type = "item", name = "engine-unit", amount = 1},
        {type = "item", name = "steel-plate", amount = 1},
        {type = "item", name = "processing-unit", amount = 5},
        {type = "item", name = "pipe", amount = 1}
      },
      results = {{type="item", name="configurable-valve", amount=1}}
    },
    {
        type = "pump",
        name = "configurable-valve",
        icon = "__base__/graphics/icons/pump.png",
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.2, result = "configurable-valve"},
        max_health = 180,
        fast_replaceable_group = "pipe",
        corpse = "pump-remnants",
        dying_explosion = "pump-explosion",
        collision_box = {{-0.29, -0.9}, {0.29, 0.9}},
        selection_box = {{-0.5, -1}, {0.5, 1}},
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
          pipe_connections =
          {
            {connection_type = "linked", direction = defines.direction.north, position = {0, -0.4}, flow_direction = "output", linked_connection_id=31113 + 1 },
            {connection_type = "linked", direction = defines.direction.south, position = {0, 0.4}, flow_direction = "input", linked_connection_id=31113 - 1 }
          }
        },
        energy_source =
        {
          type = "electric",
          usage_priority = "secondary-input",
          drain = "1kW"
        },
        energy_usage = "29kW",
        pumping_speed = 20,
        impact_category = "metal",
        open_sound = sounds.machine_open,
        close_sound = sounds.machine_close,

        animations =
        {
          north =
          {
            filename = "__base__/graphics/entity/pump/pump-north.png",
            width = 103,
            height = 164,
            scale = 0.5,
            line_length =8,
            frame_count =32,
            animation_speed = 0.5,
            shift = util.by_pixel(8, 3.5)
          },
          east =
          {
            filename = "__base__/graphics/entity/pump/pump-east.png",
            width = 130,
            height = 109,
            scale = 0.5,
            line_length =8,
            frame_count =32,
            animation_speed = 0.5,
            shift = util.by_pixel(-0.5, 1.75)
          },

          south =
          {
            filename = "__base__/graphics/entity/pump/pump-south.png",
            width = 114,
            height = 160,
            scale = 0.5,
            line_length =8,
            frame_count =32,
            animation_speed = 0.5,
            shift = util.by_pixel(12.5, -8)
          },
          west =
          {
            filename = "__base__/graphics/entity/pump/pump-west.png",
            width = 131,
            height = 111,
            scale = 0.5,
            line_length =8,
            frame_count =32,
            animation_speed = 0.5,
            shift = util.by_pixel(-0.25, 1.25)
          }
        },

        fluid_animation =
        {
          north =
          {
            filename = "__base__/graphics/entity/pump/pump-north-liquid.png",
            apply_runtime_tint = true,
            width = 38,
            height = 22,
            scale = 0.5,
            line_length =8,
            frame_count =32,
            shift = util.by_pixel(-0.250, -16.750)
          },

          east =
          {
            filename = "__base__/graphics/entity/pump/pump-east-liquid.png",
            width = 35,
            height = 46,
            scale = 0.5,
            line_length =8,
            frame_count =32,
            shift = util.by_pixel(6.25, -8.5)
          },

          south =
          {
            filename = "__base__/graphics/entity/pump/pump-south-liquid.png",
            width = 38,
            height = 45,
            scale = 0.5,
            line_length =8,
            frame_count =32,
            shift = util.by_pixel(0.5, -9.25)
          },
          west =
          {
            filename = "__base__/graphics/entity/pump/pump-west-liquid.png",
            width = 35,
            height = 47,
            scale = 0.5,
            line_length =8,
            frame_count =32,
            shift = util.by_pixel(-6.5, -9.5)
          }
        },

        glass_pictures =
        {
          north =
          {
            filename = "__base__/graphics/entity/pump/pump-north-glass.png",
            width = 64,
            height = 128,
            scale = 0.5
          },
          east =
          {
            filename = "__base__/graphics/entity/pump/pump-east-glass.png",
            width = 128,
            height = 192,
            scale = 0.5
          },
          south =
          {
            filename = "__base__/graphics/entity/pump/pump-south-glass.png",
            width = 64,
            height = 128,
            scale = 0.5
          },
          west =
          {
            filename = "__base__/graphics/entity/pump/pump-west-glass.png",
            width = 192,
            height = 192,
            scale = 0.5,
            shift = util.by_pixel(-16, 0)
          }
        },

        circuit_connector = circuit_connector_definitions["pump"],
        circuit_wire_max_distance = default_circuit_wire_max_distance
    },
}