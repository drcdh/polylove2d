local grid = {}

local json = require "dkjson"

grid.common = require "games.grid.common"

grid.name = "Grid"

local size = 5
local players = {}

function move(name, dx, dy)
    x, y = players[name].x, players[name].y
    if x == 0 and dx == -1 then
        print("left bonk")
        dx = 0
    elseif x == size - 1 and dx == 1 then
        print("right bonk")
        dx = 0
    end
    if y == 0 and dy == -1 then
        dy = 0
    elseif y == size - 1 and dy == 1 then
        dy = 0
    end
    if dx ~= 0 or dy ~= 0 then
        players[name] = {x = x + dx, y = y + dy}
        print(string.format("%s moved from %d,%d to %d,%d", name, x, y,
                            players[name].x, players[name].y))
    end
end

function grid.update(cmd, param)
    if cmd == 'join' then
        local name = param
        -- todo: validate name (alphanumeric only)
        players[name] = {x = 1, y = 1}
        print(string.format("%s joined %s and was given state %s", name,
                            grid.name,
                            json.encode(players[name], {indent = false})))
    elseif cmd == 'move' then
        local name, dx, dy = param:match("^(%S-),(%-?[%d.e]+),(%-?[%d.e]+)")
        if players[name] then
            dx, dy = tonumber(dx), tonumber(dy)
            move(name, dx, dy)
        else
            print(string.format("%s does not exist"))
        end
    else
        print(string.format("unrecognized command '%s'", cmd))
    end
end

function grid.player_leave(player_name)
  players[player_name] = nil
end

function grid.get_state()
    return grid.common.state_to_string({size = size, players = players})
end

return grid

