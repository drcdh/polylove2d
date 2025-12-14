local grid = {}

local json = require("dkjson")

function grid.state_to_string(game_state) return json.encode(game_state, { indent = false }) end

function grid.string_to_state(s) return json.decode(s) end

return grid

