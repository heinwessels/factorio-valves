local constants = require("__valves__.constants")
local builder = require("__valves__.scripts.builder")

local rebuilder = { }

---@param args {full:boolean?}?
function rebuilder.rebuild(args)
    args = args or { }

    ---@type string[]
    local valve_names = { }
    for valve_name in pairs(constants.valve_names) do
        table.insert(valve_names, valve_name)
    end

    for _, surface in pairs(game.surfaces) do
        for _, valve in pairs(surface.find_entities_filtered{name=valve_names}) do

            if not args.full then
                builder.destroy(valve)
            else
                local name = valve.name
                local position = valve.position
                local direction = valve.direction
                local force = valve.force
                local mirroring = valve.mirroring -- Technically not needed
                local marked_for_decon = valve.to_be_deconstructed()

                valve.destroy{raise_destroy = true}

                local new_valve = surface.create_entity{
                    name = name,
                    position = position,
                    direction = direction,
                    force = force,
                }
                assert(new_valve)
                valve = new_valve
                if marked_for_decon then valve.order_deconstruction(force) end
                valve.mirroring = mirroring
            end

            builder.build(valve) -- Will also ensure correct circuit condition
        end
    end
end

function rebuilder.remove_orphans(args)
    local gauges = {"valves-guage-input", "valves-guage-output"}
    local valves = {"valves-overflow", "valves-top_up", "valves-one_way"}
    for _, surface in pairs(game.surfaces) do
        for _, guage in pairs(surface.find_entities_filtered{name = gauges}) do
            if 0 == surface.count_entities_filtered{position=guage.position, name=valves} then
                guage.destroy()
            end
        end
    end
end

rebuilder.add_remote_interface = function()
	remote.add_interface("valves", {

		rebuild_all = function(args)
            rebuilder.rebuild(args or { })
		end,

        remove_orphans = function(args)
            rebuilder.remove_orphans(args or { })
		end,

    })
end

return rebuilder