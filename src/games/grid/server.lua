print("GRID SERVER")

local grid = {}

local util = require "util"

grid.name = "Grid"

local game_state = {}

-- GAME PARAMETERS
game_state.size = 5

-- GAME STATE
game_state.num_players = 0
game_state.players = {}
game_state.player_scores = {}
game_state.pits = {}
game_state.walls = {}

-- Callbacks defined in code using this module
grid.update_player = nil
grid.update_all_players = nil

function grid.initialize()
  game_state.pits = {}
  game_state.players = {}
  game_state.player_scores = {}
  game_state.walls = {
    true,
    true,
    false,
    true,
    true,
    true,
    false,
    false,
    false,
    true,
    false,
    false,
    true,
    false,
    false,
    true,
    false,
    false,
    false,
    true,
    true,
    true,
    false,
    true,
    true,
  }
  for i = 1, #game_state.walls do game_state.pits[i] = not game_state.walls[i] end
end

function grid.initialize_player(player_name)
  grid.update_player(player_name, "state", util.encode(game_state))
end

local function eat_pit(player_name, i, j)
  local l = i + game_state.size * j + 1
  game_state.pits[l] = false
  grid.update_all_players("removepit", string.format("%d,%d", i, j))
  game_state.player_scores[player_name] = game_state.player_scores[player_name] + 1
  grid.update_all_players("score", player_name)
end

local function move(player_name, i, j)
  local i0, j0 = game_state.players[player_name].i, game_state.players[player_name].j
  game_state.players[player_name].i = i
  game_state.players[player_name].j = j
  grid.update_all_players("move", string.format("%s,%d,%d", player_name, i, j))
  print(string.format("%s moved from %d,%d to %d,%d", player_name, i0, j0, i, j))
end

local TRYMOVE = "trymove"
local function try_move(player_name, di, dj)
  local i, j = game_state.players[player_name].i, game_state.players[player_name].j
  local i1, j1 = i, j
  if i == 0 and di == -1 then
    i1 = game_state.size - 1
  elseif i == game_state.size - 1 and di == 1 then
    i1 = 0
  else
    i1 = i + di
  end
  if j == 0 and dj == -1 then
    j1 = game_state.size - 1
  elseif j == game_state.size - 1 and dj == 1 then
    j1 = 0
  else
    j1 = j + dj
  end
  if i ~= i1 or j ~= j1 then
    local l = i1 + game_state.size * j1 + 1
    if game_state.walls[l] then
      print("bonk")
    else
      move(player_name, i1, j1)
      if game_state.pits[l] then eat_pit(player_name, i1, j1) end
    end
  end
end

function grid.player_join(player_name)
  game_state.num_players = game_state.num_players + 1
  game_state.players[player_name] = { i = 1, j = 1 } -- todo: face
  game_state.player_scores[player_name] = 0
  grid.update_all_players("newplayer",
                          string.format("%s,%d,%d", player_name, game_state.players[player_name].i,
                                        game_state.players[player_name].j))
end

function grid.update(player_name, cmd, param)
  if cmd == TRYMOVE then
    local di, dj = param:match("^(%-?[%d.e]+),(%-?[%d.e]+)")
    if game_state.players[player_name] then
      di, dj = tonumber(di), tonumber(dj)
      try_move(player_name, di, dj)
    else
      print(string.format("%s does not exist"))
    end
  else
    print(string.format("unrecognized command '%s'", cmd))
  end
end

function grid.player_leave(player_name)
  game_state.num_players = game_state.num_players - 1
  game_state.players[player_name] = nil
  game_state.player_scores[player_name] = nil
  grid.update_all_players("removeplayer", player_name)
end

return grid

