local constants = require("__valves__.constants")
local builder = require("__valves__.scripts.builder")

local rebuilder = { }

function rebuilder.rebuild()
    ---@type string[]
    local valve_names = { }
    for valve_name in pairs(constants.valve_names) do
        table.insert(valve_names, valve_name)
    end

    for _, surface in pairs(game.surfaces) do
        for _, valve in pairs(surface.find_entities_filtered{name=valve_names}) do
            builder.destroy(valve)
            builder.build(valve)
        end
    end
end

rebuilder.add_remote_interface = function()
	remote.add_interface("valves", {

		rebuild_all = function()
            rebuilder.rebuild()
		end,

    })
end

return rebuilder