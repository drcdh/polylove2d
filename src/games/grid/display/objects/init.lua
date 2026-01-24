local tween = require "tween"

FACE = require("games.grid.face")

function CELL_TO_CENTER_PIXEL(i, j)
  local x = CELL_PIXELS * (i + .5)
  local y = CELL_PIXELS * (j + .5)
  return x, y
end

function CELL_TO_TOP_LEFT_PIXEL(i, j)
  local x = CELL_PIXELS * i
  local y = CELL_PIXELS * j
  return x, y
end

Pit = {}
Pit.__index = Pit
Pit.COLOR = { .5, .5, 0 }
Pit.RADIUS = .1 -- relative to CELL_PIXELS
Pit.RADIUS_OSC = .2 -- relative to RADIUS
Pit.T_OSC = 1 -- seconds
function Pit:new(i, j)
  local o = { i = i, j = j, osc = 0 }
  o._tw = tween.new(1, o, { osc = math.pi })
  setmetatable(o, self)
  return o
end
function Pit:draw()
  local x, y = CELL_TO_CENTER_PIXEL(self.i, self.j)
  local r = self.RADIUS * CELL_PIXELS * (1 + self.RADIUS_OSC * math.sin(self.osc))
  love.graphics.setColor(unpack(self.COLOR))
  love.graphics.circle("fill", x, y, r)
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
EatenPit.RADIUS = Pit.RADIUS
EatenPit.RADIUS_GROWTH = .5 -- relative to RADIUS
EatenPit.DJ = -1 -- relative to CELL_PIXELS
EatenPit.T_GROW = 1 -- seconds
function EatenPit:new(i, j)
  local o = { i = i, j = j, grow = 0 }
  o._tw = tween.new(self.T_GROW, o, { grow = 1 })
  setmetatable(o, self)
  return o
end
function EatenPit:_set_color()
  local r, g, b = unpack(self.COLOR)
  love.graphics.setColor(r, g, b, 1 - self.grow)
end
function EatenPit:draw()
  local x, y = CELL_TO_CENTER_PIXEL(self.i, self.j)
  y = y + self.DJ * CELL_PIXELS * self.grow
  local r = self.RADIUS * CELL_PIXELS * (self.grow * self.RADIUS_GROWTH + 1)
  self:_set_color()
  love.graphics.circle("fill", x, y, r)
end
function EatenPit:update(dt)
  if self._tw:update(dt) then
    self.complete = true
  end
end

return {
  EatenPit = EatenPit,
  Pit = Pit,
  Player = require("games.grid.display.objects.player"),
  Baddy = require("games.grid.display.objects.baddy"),
}

