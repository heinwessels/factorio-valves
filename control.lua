local handler = require("__core__/lualib/event_handler")
handler.add_libraries({
    require("__configurable-valves__.scripts.configuration"),
    require("__configurable-valves__.scripts.builder"),
    require("__configurable-valves__.scripts.shortcuts"),
})