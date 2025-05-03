local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local constants = require("__valves__.constants")

local to_vanilla_mode = {
  ["overflow"] = "overflow",
  ["top_up"] = "top-up",
  ["one_way"] = "one-way",
}

local item_sub_group = "energy-pipe-distribution"
if data.raw["item"]["pump"] then
  item_sub_group = data.raw["item"]["pump"].subgroup
end

local function create_valve(valve_type)
  local name = "valves-"..valve_type
  local threshold = nil
  if valve_type == "overflow" or valve_type == "top_up" then
    threshold = settings.startup["valves-default-threshold-"..valve_type].value /  100
  end
  data:extend{
      {
        type = "item",
        name = name,
        icon = "__valves__/graphics/"..valve_type.."/icon.png",
        subgroup = item_sub_group,
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
        type = "valve",
        name = name,
        icon = "__valves__/graphics/"..valve_type.."/icon.png",
        flags = {"placeable-neutral", "player-creation", "hide-alt-info"},
        localised_description = {"",
          {"entity-description."..to_vanilla_mode[valve_type].."-valve"},
          " ",
          {"valves.more-in-factoriopedia"},
        },
        factoriopedia_description = {"",
        {"entity-description."..to_vanilla_mode[valve_type].."-valve"},
          valve_type ~= "one_way" and {"valves.valve-shortcuts"} or nil,
          valve_type ~= "one_way" and {"valves.threshold-settings"} or nil,
        },
        minable = {mining_time = 0.2, result = name},
        mode = to_vanilla_mode[valve_type],
        threshold = threshold,
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
            { direction = defines.direction.south, position = {0, 0}, flow_direction = "output" },
            { direction = defines.direction.north, position = {0, 0}, flow_direction = "input-output" }
          },
          hide_connection_info = true,
        },
        energy_source = { type = "void" },
        energy_usage = "1W",
        flow_rate = settings.startup["valves-pump-speed"].value / 60, --[[@as number value given per second, convert to per tick]]
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
      },
  }
end

for valve_type in pairs(constants.valve_types) do
  create_valve(valve_type)
end