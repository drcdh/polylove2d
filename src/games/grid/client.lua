local grid = { mod = "grid", name = "Grid" }

-- local tween = require("tween")

local objects = require("games.grid.objects")
local util = require("util")

local W, H

GridClient = {}
GridClient.__index = GridClient

function GridClient:new(gid, player_name, send)
  local o = {
    -- game_state = nil,
    gid = gid or string.format("G%04d", math.random(9999)),
    mod = grid.mod,
    name = grid.name,
    num_players = 0,
    pits = {},
    player_name = player_name,
    players = {},
    player_scores = {},
    -- player_state = { busy = false },
    send = send,
    -- tweens = {},
    -- tweens_busy = {},
    -- waiting = {},
    walls = {},
  }
  setmetatable(o, self)
  return o
end

function GridClient:initialize(game_state)
  W, H = love.graphics.getWidth(), love.graphics.getHeight()
  self.size = game_state.size
  self.dH = H / self.size
  self.dW = W / self.size
  for player_name, player in pairs(game_state.players) do
    self.players[player_name] = objects.Player:new(player.i, player.j, player_name)
    self.player_scores[player_name] = game_state.player_scores[player_name]
  end
  for i = 0, self.size - 1 do
    for j = 0, self.size - 1 do
      local l = i + self.size * j + 1
      if game_state.pits[l] then self.pits[l] = objects.Pit:new(i, j) end
      self.walls[l] = game_state.walls[l]
    end
  end
end

function GridClient:input_ready() return
  not self.sync_id and not self.players[self.player_name].busy end

function GridClient:process_input()
  if self.size and self:input_ready() then
    local di, dj = 0, 0
    if love.keyboard.isDown("up") then dj = dj - 1 end
    if love.keyboard.isDown("down") then dj = dj + 1 end
    if love.keyboard.isDown("left") then di = di - 1 end
    if love.keyboard.isDown("right") then di = di + 1 end
    if math.abs(di + dj) == 1 then
      self.sync_id = self.send(self.player_name, "trymove", self.gid,
                               string.format("%d,%d", di, dj), true)
    end
  end
end

function GridClient:process_update(update, data, sync_id)
  -- print(string.format("Processing %s:%s", update, data))
  if sync_id == self.sync_id then self.sync_id = nil end
  if update == "state" then
    self:initialize(util.decode(data))
  elseif update == "moveh" then
    local player_name, di = data:match("^(%S-),(%-?[%d.e]+)")
    self.players[player_name]:move_h(di)
  elseif update == "movev" then
    local player_name, dj = data:match("^(%S-),(%-?[%d.e]+)")
    self.players[player_name]:move_v(dj)
  elseif update == "newplayer" then
    local player_name, i, j = data:match("^(%S-),(%-?[%d.e]+),(%-?[%d.e]+)")
    i, j = tonumber(i), tonumber(j)
    self.num_players = self.num_players + 1
    self.players[player_name] = objects.Player:new(i, j, player_name)
    self.player_scores[player_name] = 0
  elseif update == "removepit" then
    local i, j = data:match("^(%-?[%d.e]+),(%-?[%d.e]+)")
    local l = i + self.size * j + 1
    self.pits[l] = nil
  elseif update == "removeplayer" then
    local player_name = data
    self.num_players = self.num_players - 1
    self.players[player_name] = nil
    self.player_scores[player_name] = nil
  elseif update == "score" then
    local player_name = data
    self.player_scores[player_name] = self.player_scores[player_name] + 1
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
      for player_name, player in pairs(self.players) do
        player:draw(self.dH, self.size)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("%s: %d   (%.2f, %.2f)", player_name,
                                          self.player_scores[player_name], player.i, player.j), 20,
                            ys)
        ys = ys + 20
      end
    end
  else
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("NO game_state", 0, 0)
  end
end

function GridClient:update(dt)
  for _, pit in pairs(self.pits) do pit:update(dt) end
  for _, player in pairs(self.players) do player:update(dt, self.size) end
  -- local tw = {}
  -- for _, _tw in ipairs(self.tweens) do if not _tw:update(dt) then tw[#tw + 1] = _tw end end
  -- self.tweens = tw
  -- local twb = {}
  -- for _, _twb in ipairs(self.tweens_busy) do if not _twb:update(dt) then twb[#twb + 1] = _twb end end
  -- self.tweens_busy = twb
  -- if #self.tweens_busy == 0 then self.player_state.busy = false end
end

function grid.new(gid, player_name, send) return GridClient:new(gid, player_name, send) end

return grid
