local grid = { mod = "grid", name = "Grid" }

local util = require "util"

GridServer = {}
GridServer.__index = GridServer

function GridServer:new(gid, update, update_all)
  local o = {
    game_state = {
      -- GAME PARAMETERS
      size = 5,
      -- GAME STATE
      num_players = 0,
      players = {},
      player_scores = {},
      pits = {},
      walls = {},
    },
    gid = gid,
    mod = grid.mod,
    name = grid.name,
    update_player = update,
    update_all_players = update_all,
  }
  o.game_state.walls = {
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
  for i = 1, #o.game_state.walls do o.game_state.pits[i] = not o.game_state.walls[i] end
  setmetatable(o, self)
  return o
end

function GridServer:initialize_player(player_name)
  self.update_player(player_name, "state", util.encode(self.game_state))
end

function GridServer:eat_pit(player_name, i, j)
  local l = i + self.game_state.size * j + 1
  self.game_state.pits[l] = false
  self.update_all_players("removepit", string.format("%d,%d", i, j))
  self.game_state.player_scores[player_name] = self.game_state.player_scores[player_name] + 1
  self.update_all_players("score", player_name)
end

function GridServer:move(player_name, i, j)
  local i0, j0 = self.game_state.players[player_name].i, self.game_state.players[player_name].j
  self.game_state.players[player_name].i = i
  self.game_state.players[player_name].j = j
  self.update_all_players("move", string.format("%s,%d,%d", player_name, i, j))
  print(string.format("%s moved from %d,%d to %d,%d", player_name, i0, j0, i, j))
end

local TRYMOVE = "trymove"
function GridServer:try_move(player_name, di, dj)
  local i, j = self.game_state.players[player_name].i, self.game_state.players[player_name].j
  local i1, j1 = i, j
  if i == 0 and di == -1 then
    i1 = self.game_state.size - 1
  elseif i == self.game_state.size - 1 and di == 1 then
    i1 = 0
  else
    i1 = i + di
  end
  if j == 0 and dj == -1 then
    j1 = self.game_state.size - 1
  elseif j == self.game_state.size - 1 and dj == 1 then
    j1 = 0
  else
    j1 = j + dj
  end
  if i ~= i1 or j ~= j1 then
    local l = i1 + self.game_state.size * j1 + 1
    if self.game_state.walls[l] then
      print("bonk")
    else
      self:move(player_name, i1, j1)
      if self.game_state.pits[l] then self:eat_pit(player_name, i1, j1) end
    end
  end
end

function GridServer:player_join(player_name)
  self.game_state.num_players = self.game_state.num_players + 1
  self.game_state.players[player_name] = { i = 1, j = 1 } -- todo: face
  self.game_state.player_scores[player_name] = 0
  self.update_all_players("newplayer",
                          string.format("%s,%d,%d", player_name,
                                        self.game_state.players[player_name].i,
                                        self.game_state.players[player_name].j))
end

function GridServer:update(player_name, cmd, param)
  if cmd == TRYMOVE then
    local di, dj = param:match("^(%-?[%d.e]+),(%-?[%d.e]+)")
    if self.game_state.players[player_name] then
      di, dj = tonumber(di), tonumber(dj)
      self:try_move(player_name, di, dj)
    else
      print(string.format("%s does not exist"))
    end
  else
    print(string.format("unrecognized command '%s'", cmd))
  end
end

function GridServer:player_leave(player_name)
  self.game_state.num_players = self.game_state.num_players - 1
  self.game_state.players[player_name] = nil
  self.game_state.player_scores[player_name] = nil
  self.update_all_players("removeplayer", player_name)
end

function grid.new(gid, update, update_all) return GridServer:new(gid, update, update_all) end

return grid

