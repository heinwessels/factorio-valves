-- Just renaming the 0003 migration so that it doesn't run twice.
-- And I'm doing this twice. Never do optimizations without thorough testing.
-- Third time the charm I guess. Fluidbox connection didn't migrate as I expected.
local rebuilder = require("__valves__.scripts.rebuilder")
rebuilder.rebuild({ full = true })