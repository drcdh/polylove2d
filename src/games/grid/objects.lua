local tween = require "tween"

Pit = {}
Pit.__index = Pit
Pit.DIAMETER = .2 -- relative to grid cell
Pit.DIAMETER_OSC = .2 -- relative to DIAMETER
Pit.T_OSC = 1 -- seconds
function Pit:new(i, j)
  local o = { i = i, j = j, osc = 0 }
  o._tw = tween.new(1, o, { osc = math.pi })
  setmetatable(o, self)
  return o
end
function Pit:draw(gp)
  love.graphics.setColor(.5, .5, 0)
  love.graphics.circle("fill", gp * (self.i + .5), gp * (self.j + .5),
                       gp * self.DIAMETER / 2 * (1 + self.DIAMETER_OSC * math.sin(self.osc)))
end
function Pit:update(dt) if self._tw:update(dt) then self._tw:reset() end end

Player = {}
Player.__index = Player
Player.DIAMETER = .8 -- relative to grid cell
Player.SPEED = 3 -- grid spaces/second
function Player:new(i, j, n, c)
  local o = { i = i, j = j, c = c or { .6, 0, 0 }, n = n }
  o.busy = false
  o._move_tw = nil
  setmetatable(o, self)
  return o
end
function Player:_draw(gp)
  love.graphics.setColor(unpack(self.c))
  love.graphics.circle("fill", gp * (self.i + .5), gp * (self.j + .5), gp * self.DIAMETER / 2)
end
function Player:_wrap(size)
  local rx, ry = 0, 0
  if self.i < 0 then rx = 1 end
  if self.i > size - 1 then rx = -1 end
  if self.j < 0 then ry = 1 end
  if self.j > size - 1 then ry = -1 end
  return rx, ry
end
function Player:draw(gp, size)
  self:_draw(gp)
  local rx, ry = self:_wrap(size)
  if rx ~= 0 then
    love.graphics.push()
    love.graphics.translate(rx * gp * size, 0)
    self:_draw(gp)
    love.graphics.pop()
  end
  if ry ~= 0 then
    love.graphics.push()
    love.graphics.translate(0, ry * gp * size)
    self:_draw(gp)
    love.graphics.pop()
  end
  if rx ~= 0 and ry ~= 0 then
    love.graphics.push()
    love.graphics.translate(rx * gp * size, ry * gp * size)
    self:_draw(gp)
    love.graphics.pop()
  end
end
function Player:update(dt, size)
  if self._move_tw and self.busy then
    self.busy = not self._move_tw:update(dt)
  else
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

