local tween = require "tween"

Pit = {}
Pit.__index = Pit
Pit.RADIUS = 20
Pit.RADIUS_OSC = Pit.RADIUS * .1
Pit.T_OSC = 1
function Pit:new(i, j)
  local o = { i = i, j = j, osc = 0 }
  o._tw = tween.new(1, o, { osc = math.pi })
  setmetatable(o, self)
  return o
end
function Pit:draw()
  love.graphics.setColor(.5, .5, 0)
  love.graphics.circle("fill", self.i, self.j, self.RADIUS + self.RADIUS_OSC * math.sin(self.osc))
end
function Pit:update(dt) if self._tw:update(dt) then self._tw:reset() end end

Player = {}
Player.__index = Player
Player.RADIUS = 40
Player.SPEED = 3 -- grid spaces/sec
function Player:new(i, j, n, c)
  local o = { i = i, j = j, c = c or { .6, 0, 0 }, n = n }
  o.busy = false
  o._move_tw = nil
  setmetatable(o, self)
  return o
end
function Player:_draw(W, H, size)
  love.graphics.setColor(unpack(self.c))
  love.graphics.circle("fill", (self.i + .5) * W / size, (self.j + .5) * H / size, self.RADIUS)
end
function Player:_wrap(size)
  local W, H = love.graphics.getWidth(), love.graphics.getHeight()
  local rW, rH = 0, 0
  if self.i < 0 then rW = W end
  if self.i > size - 1 then rW = -W end
  if self.j < 0 then rH = H end
  if self.j > size - 1 then rH = -H end
  return rW, rH
end
function Player:draw(W, H, size)
  self:_draw(W, H, size)
  local rW, rH = self:_wrap(size)
  if rW ~= 0 then
    love.graphics.push()
    love.graphics.translate(rW, 0)
    self:_draw(W, H, size)
    love.graphics.pop()
  end
  if rH ~= 0 then
    love.graphics.push()
    love.graphics.translate(0, rH)
    self:_draw(W, H, size)
    love.graphics.pop()
  end
  if rW ~= 0 and rH ~= 0 then
    love.graphics.push()
    love.graphics.translate(rW, rH)
    self:_draw(W, H, size)
    love.graphics.pop()
  end
end
function Player:update(dt, size)
  if self._move_tw and self.busy then self.busy = not self._move_tw:update(dt) else
  self.i = self.i % size
  self.j = self.j % size
  end
end
function Player:move_h(d)
  local t = math.abs(d) / self.SPEED
  self._move_tw = tween.new(t, self, { i = self.i + d })
  self.busy = true
  print(string.format("%s moving horizontally by %d over %.1f seconds", self.n, d, t))
end
function Player:move_v(d)
  local t = math.abs(d) / self.SPEED
  self._move_tw = tween.new(t, self, { j = self.j + d })
  self.busy = true
  print(string.format("%s moving vertically by %d over %.1f seconds", self.n, d, t))
end

return { Pit = Pit, Player = Player }

