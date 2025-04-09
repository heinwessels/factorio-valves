local handler = require("__core__/lualib/event_handler")
handler.add_libraries({
    require("__valves__.scripts.builder"),
    require("__valves__.scripts.shortcuts"),
    require("__valves__.scripts.cursor"),
})