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

-- Callbacks defined in code using this module
grid.state_callback = nil
grid.update_callback = nil

local function _update(update)
  util.update_table(game_state, update)
  grid.update_callback(update)
end

local function move(name, di, dj)
  local i, j = game_state.players[name].i, game_state.players[name].j
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
      local update = { players = { [name] = {} } }
      update.players[name].i = i1
      update.players[name].j = j1
      print(string.format("%s moved from %d,%d to %d,%d", name, i, j, i1, j1))
      if game_state.pits[l] then
        -- update.pits = { [l] = false }
        -- todo: because Lua doesn't have arrays, dkjson gets confused, so we send the entire list of pits when one changes
        update.pits = game_state.pits
        update.pits[l] = false
        update.player_scores = { [name] = game_state.player_scores[name] + 1 }
      end
      _update(update)
    end
  end
end

function grid.player_join(player_name)
  util.update_table(game_state, {
    num_players = game_state.num_players + 1,
    players = { [player_name] = { i = 1, j = 1 } }, -- todo: face
    player_scores = { [player_name] = 0 },
  })
  grid.state_callback(game_state)
end

function grid.update(cmd, param)
  if cmd == "move" then
    local name, di, dj = param:match("^(%S-),(%-?[%d.e]+),(%-?[%d.e]+)")
    if game_state.players[name] then
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
  _update({
    num_players = game_state.num_players - 1,
    players = { [player_name] = nil },
    player_scores = { [player_name] = nil },
  })
end

return grid

