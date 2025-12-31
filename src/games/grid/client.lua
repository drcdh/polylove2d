local grid = { mod = "grid", name = "Grid" }

local objects = require("games.grid.objects")
local util = require("util")

local W, H

GridClient = {}
GridClient.__index = GridClient

function GridClient:new()
  local o = {
    -- game_state = nil,
    mod = grid.mod,
    name = grid.name,
    num_players = 0,
    pits = {},
    players = {},
    player_scores = {},
    playing = true,
    walls = {},
  }
  setmetatable(o, self)
  return o
end

function GridClient:initialize(game_state)
  print("Initializing...")
  W, H = love.graphics.getWidth(), love.graphics.getHeight()
  self.size = game_state.size
  self.dH = H / self.size
  self.dW = W / self.size
  for cid, player in pairs(game_state.players) do
    -- self.players[cid] = player
    self.players[cid] = objects.Player:new(player.i, player.j, cid)
    self.player_scores[cid] = player.score
  end
  for i = 0, self.size - 1 do
    for j = 0, self.size - 1 do
      local l = i + self.size * j + 1
      if game_state.pits[l] then self.pits[l] = objects.Pit:new(i, j) end
      self.walls[l] = game_state.walls[l]
    end
  end
end

function GridClient:update(my_cid, update, param)
  print(string.format("Processing %s:%s", update, param))
  if update == "state" then
    self:initialize(util.decode(param))
  elseif update == "setplayer" then
    local cid, i, j, score = param:match("^(%S-),(%S-),(%S-),(%S*)")
    i, j, score = tonumber(i), tonumber(j), tonumber(score)
    -- self.players[cid] = { i = tonumber(i), j = tonumber(j), score = tonumber(score) }
    if not self.players[cid] then
      self.players[cid] = objects.Player:new(i, j)
    else
      self.players[cid]:setpos(i, j)
    end
    self.player_scores[cid] = score
  elseif update == "removepit" then
    local i, j = data:match("^(%-?[%d.e]+),(%-?[%d.e]+)")
    local l = i + self.size * j + 1
    self.pits[l] = nil
  elseif update == "leave" then
    local cid = param
    self.players[cid] = nil
    if cid == my_cid then self.playing = false end
  elseif update == "score" then
    local cid = param
    self.player_scores[cid] = self.player_scores[cid] + 1
  else
    print(string.format("Unrecognized update '%s'", update))
  end
end

function GridClient:draw()
  if self.size then -- initialized
    love.graphics.setColor(1, 1, 1)
    for _x = self.dW, W, self.dW do love.graphics.line(_x, 0, _x, H) end
    for _y = self.dH, H, self.dH do love.graphics.line(0, _y, W, _y) end
    do
      local _x, _y = self.dW / 2, self.dH / 2
      for _i = 0, self.size * self.size - 1 do
        if _i > 0 then
          if _i % self.size == 0 then
            _x = self.dW / 2
            _y = _y + self.dH
          else
            _x = _x + self.dW
          end
        end
        if self.walls[_i + 1] then
          -- print(string.format("drawing wall at %d", _i))
          love.graphics.setColor(.3, .4, .5)
          love.graphics.rectangle("fill", _x - .9 * self.dW / 2, _y - .9 * self.dH / 2,
                                  .9 * self.dW, .9 * self.dH)
        elseif self.pits[_i + 1] then
          self.pits[_i + 1]:draw(self.dH, self.size)
        end
      end
    end
    do
      love.graphics.setColor(0, .1, .3)
      love.graphics.rectangle("fill", 10, 10, 100, 20 * (1 + self.num_players))
      local ys = 20 -- pixel position for score
      love.graphics.setColor(1, 1, 1)
      for cid, player in pairs(self.players) do
        player:draw(self.dH, self.size)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("%s: %d   (%.2f, %.2f)", cid, self.player_scores[cid],
                                          player.i, player.j), 20, ys)
        ys = ys + 20
      end
    end
  else
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("NO game_state", 0, 0)
  end
end

function GridClient:love_update(dt)
  for _, pit in pairs(self.pits) do pit:update(dt) end
  -- for _, player in pairs(self.players) do player:update(dt, self.size) end
end

function grid.new() return GridClient:new() end

return grid
