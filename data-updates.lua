--[[
If PyIndustry is installed, we want to be equivalent to its
overflow/underflow valves. Otherwise we are equivalent to a pump.

Since the fancy Py valves are currently disabled, we pick the tech
based on the check valve, but still pull the recipe from the overflow
valve for balance reasons.
]]--

local constants = require("__valves__.constants")

---@type string
local base_recipe_item
local base_tech_item
if mods.pyindustry then
    base_recipe_item = "py-overflow-valve"
    base_tech_item = "py-check-valve"
else
    base_recipe_item = "pump"
    base_tech_item = "pump"
end

---@type data.TechnologyPrototype?
local tech_to_unlock
for _, technology in pairs(data.raw.technology) do
    if technology.effects then			
        for index, effect in pairs(technology.effects) do
            if effect.type == "unlock-recipe" then
                if effect.recipe == base_tech_item then
                  tech_to_unlock = technology
                  for valve_type in pairs(constants.valve_types) do
                    table.insert(tech_to_unlock.effects, index, {
                      type = "unlock-recipe",
                      recipe = "valves-"..valve_type
                    })
                  end
                  break
                end
            end
        end
        if tech_to_unlock then break end
    end
end

---@type data.IngredientPrototype?
local ingredients
for _, recipe in pairs(data.raw.recipe) do
  for _, result in pairs(recipe.results or { }) do
      if result.type == "item" then
          if result.name == base_recipe_item then
            ingredients = recipe.ingredients
            break
          end
      end
  end
  if ingredients then break end
end

-- Make sure the valves are grouped with the pumps
local item_sub_group = "energy-pipe-distribution"
if data.raw["item"]["pump"] then
  item_sub_group = data.raw["item"]["pump"].subgroup
end

for valve_type in pairs(constants.valve_types) do
  data.raw.recipe["valves-"..valve_type].enabled = tech_to_unlock == nil
  data.raw.recipe["valves-"..valve_type].ingredients = ingredients
  data.raw.item["valves-"..valve_type].subgroup = item_sub_group
end