-- Just renaming the 0003 migration so that it doesn't run twice.
local rebuilder = require("__valves__.scripts.rebuilder")
rebuilder.rebuild()