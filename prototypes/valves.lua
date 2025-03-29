local item_sounds = require("__base__.prototypes.item_sounds")
local hit_effects = require("__base__.prototypes.entity.hit-effects")

local constants = require("__valves__.constants")

local to_vanilla_type = {
  ["overflow"] = "overflow",
  ["top_up"] = "top-up",
  ["one_way"] = "one-way",
}

-- TODO: Move to settings
local default_thresholds = {
  ["overflow"] = 80,
  ["top_up"] = 50,
}

local function create_valve_entity(valve_type, threshold)
  data:extend{
    {
      type = "valve",
      name = "valves-"..valve_type..(threshold and ("-"..threshold) or ""),
      icon = "__valves__/graphics/"..valve_type.."/icon.png",
      flags = {"placeable-neutral", "player-creation", "hide-alt-info"},
      localised_description = {"",
        {"entity-description.valves-"..valve_type},
        " ",
        {"valves.more-in-factoriopedia"},
      },
      factoriopedia_description = {"",
        {"entity-description.valves-"..valve_type},
        valve_type ~= "one_way" and {"valves.valve-shortcuts"} or nil,
        valve_type ~= "one_way" and {"valves.threshold-settings"} or nil,
      },

      mode = to_vanilla_type[valve_type],
      threshold = threshold and threshold / 100 or nil, -- Threshold given in percentage
      flow_rate = settings.startup["valves-pump-speed"].value / 60, --[[@as number value given per second, convert to per tick]]

      minable = { mining_time = 0.2, result = "valves-"..valve_type },
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
        pipe_connections = {
          {direction = defines.direction.north, position = {0, 0}, flow_direction = "output"},
          {direction = defines.direction.south, position = {0, 0}, flow_direction = "input-output"},
        },
        hide_connection_info = true,
      },
      impact_category = "metal",

      -- TODO: Temporary, remove me.
      sprite = {filename = "__base__/graphics/entity/valve/valve.png", size = 64, scale = 0.5},

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
      }
    }
  }
end

local function create_valve_prototypes(valve_type)
  local default_threshold = default_thresholds[valve_type]
  data:extend{
    {
      type = "item",
      name = "valves-"..valve_type,
      icon = "__valves__/graphics/"..valve_type.."/icon.png",
      subgroup = "energy-pipe-distribution",
      order = "b[pipe]-d[valves-"..valve_type.."]",
      inventory_move_sound = item_sounds.fluid_inventory_move,
      pick_sound = item_sounds.fluid_inventory_pickup,
      drop_sound = item_sounds.fluid_inventory_move,
      place_result = "valves-"..valve_type..( default_threshold and ("-"..default_threshold) or "" ),
      stack_size = 20,
    },
    {
      type = "recipe",
      name = "valves-"..valve_type,
      energy_required = 2,
      ingredients = { }, -- Determined in data-updates
      results = {{type="item", name="valves-"..valve_type, amount=1}}
    }
  }

  if valve_type == "one_way" then
    create_valve_entity(valve_type)
  else
    for threshold = 0, 100, 10 do
      create_valve_entity(valve_type, threshold)
    end
  end
end

for valve_type in pairs(constants.valve_types) do
  create_valve_prototypes(valve_type)
end