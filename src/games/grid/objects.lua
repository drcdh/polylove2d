local tween = require "tween"

Pit = {}
Pit.__index = Pit
Pit.COLOR = { .5, .5, 0 }
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
  love.graphics.setColor(unpack(self.COLOR))
  love.graphics.circle("fill", gp * (self.i + .5), gp * (self.j + .5),
                       gp * self.DIAMETER / 2 * (1 + self.DIAMETER_OSC * math.sin(self.osc)))
end
function Pit:update(dt)
  if self._tw:update(dt) then
    self._tw:reset()
    return true
  end
end

EatenPit = {}
EatenPit.__index = EatenPit
EatenPit.COLOR = Pit.COLOR
EatenPit.DIAMETER = Pit.DIAMETER
EatenPit.DIAMETER_GROWTH = .5 -- relative to DIAMETER
EatenPit.DJ = -1 -- relative to grid cell
EatenPit.T_GROW = 1 -- seconds
function EatenPit:new(i, j)
  local o = { i = i, j = j, grow = 0 }
  o._tw = tween.new(self.T_GROW, o, { grow = 1 })
  setmetatable(o, self)
  return o
end
function EatenPit:draw(gp)
  local r, g, b = unpack(self.COLOR)
  love.graphics.setColor(r, g, b, 1 - self.grow)
  love.graphics.circle("fill", gp * (self.i + .5), gp * (self.j + .5 + self.DJ * self.grow),
                       gp * self.DIAMETER * (self.grow * self.DIAMETER_GROWTH + 1))
end
function EatenPit:update(dt) if self._tw:update(dt) then self.complete = true end end

Player = {}
Player.__index = Player
Player.DIAMETER = .8 -- relative to grid cell
function Player:new(i, j, n, c)
  local o = { i = i, j = j, c = c or { .6, 0, 0 }, n = n }
  setmetatable(o, self)
  return o
end
function Player:setpos(i, j)
  self.i = tonumber(i)
  self.j = tonumber(j)
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

return { EatenPit = EatenPit, Pit = Pit, Player = Player }

