local grid = {}

local json = require "dkjson"

grid.common = require "games.grid.common"

grid.name = "Grid"

-- GAME PARAMETERS
local size = 5

-- GAME STATE
local players = {}
local player_scores = {}
local pits = {}
local walls = {}

function grid.initialize()
    pits = {}
    players = {}
    player_scores = {}
    walls = {
        true, true, false, true, true, true, false, false, false, true, false,
        false, true, false, false, true, false, false, false, true, true, true,
        false, true, true
    }
    for i = 1, #walls do pits[i] = not walls[i] end
end

local function move(name, di, dj)
    local i, j = players[name].i, players[name].j
    local i1, j1 = i, j
    if i == 0 and di == -1 then
        i1 = size - 1
    elseif i == size - 1 and di == 1 then
        i1 = 0
    else
        i1 = i + di
    end
    if j == 0 and dj == -1 then
        j1 = size - 1
    elseif j == size - 1 and dj == 1 then
        j1 = 0
    else
        j1 = j + dj
    end
    if i ~= i1 or j ~= j1 then
        local l = i1 + size * j1 + 1
        if walls[l] then
            print("bonk")
        else
            players[name].i = i1
            players[name].j = j1
            print(string.format("%s moved from %d,%d to %d,%d", name, i, j, i1,
                                j1))
            if pits[l] then
                player_scores[name] = player_scores[name] + 1
                pits[l] = false
            end
        end
    end
end

function grid.player_join(name)
    players[name] = {i = 1, j = 1} -- todo: face
    player_scores[name] = 0
end

function grid.update(cmd, param)
    if cmd == 'move' then
        local name, di, dj = param:match("^(%S-),(%-?[%d.e]+),(%-?[%d.e]+)")
        if players[name] then
            di, dj = tonumber(di), tonumber(dj)
            move(name, di, dj)
        else
            print(string.format("%s does not exist"))
        end
    else
        print(string.format("unrecognized command '%s'", cmd))
    end
end

function grid.player_leave(player_name)
    players[player_name] = nil
    player_scores[player_name] = nil
end

function grid.get_state()
    return grid.common.state_to_string({
        size = size,
        players = players,
        player_scores = player_scores,
        pits = pits,
        walls = walls
    })
end

return grid

