-- We will manually destroy all hidden components and then recreate them.
-- This will also clean up all orphans automatically, and cases where
-- multiple hidden guages are stacked underneath a valve. We need to
-- then call rebuild to fix everything.

do return end

for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{ name = {
        "valves-guage-input",
        "valves-guage-output",
        "valves-tiny-combinator",
    }}) do
        entity.destroy()
    end
end

require("scripts.rebuilder").rebuild()