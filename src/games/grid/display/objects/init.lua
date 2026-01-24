local tween = require "tween"

local FACE = require("games.grid.face")

local function cell_to_center_pixel(i, j)
  local x = CELL_PIXELS * (i + .5)
  local y = CELL_PIXELS * (j + .5)
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
  local x, y = cell_to_center_pixel(self.i, self.j)
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
  local x, y = cell_to_center_pixel(self.i, self.j)
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

Player = {}
Player.__index = Player
Player.RADIUS = .4 -- relative to CELL_PIXELS
Player.T_WAKKA = .5 -- seconds
function Player:new(i, j, n, c)
  local o = { i = i, j = j, c = c or { .6, 0, 0 }, n = n, score = 0, f = FACE.RIGHT }
  -- o._mouth, o._tw = 0, nil
  o._mouth = 0
  o._tw = tween.new(self.T_WAKKA, o, { _mouth = 1 })
  setmetatable(o, self)
  return o
end
function Player:__draw_mouth()
  local x, y = cell_to_center_pixel(self.i, self.j)
  local di, dj = FACE.inv_calc(self.f)
  local m = 2 * math.abs(self._mouth - .5)
  local r = self.RADIUS * CELL_PIXELS
  if di ~= 0 then
    love.graphics.polygon("fill", x, y, x + di * r, y + r * m, x + di * r, y - r * m)
  else
    love.graphics.polygon("fill", x, y, x + r * m, y + dj * r, x - r * m, y + dj * r)
  end
end
function Player:_draw()
  local x, y = cell_to_center_pixel(self.i, self.j)
  love.graphics.setColor(unpack(self.c))
  love.graphics.stencil(
      function()
        return self:__draw_mouth()
      end, "increment"
  )
  love.graphics.setStencilTest("less", 1)
  love.graphics.circle("fill", x, y, self.RADIUS * CELL_PIXELS)
  love.graphics.setStencilTest()
end
function Player:_wrap()
  local rx, ry = 0, 0
  if self.i < 0 then
    rx = 1
  end
  if self.i > SIZE.w - 1 then
    rx = -1
  end
  if self.j < 0 then
    ry = 1
  end
  if self.j > SIZE.h - 1 then
    ry = -1
  end
  return rx, ry
end
function Player:draw()
  self:_draw()
  local rx, ry = self:_wrap()
  if rx ~= 0 then
    love.graphics.push()
    love.graphics.translate(rx * FRAME_W, 0)
    self:_draw()
    love.graphics.pop()
  end
  if ry ~= 0 then
    love.graphics.push()
    love.graphics.translate(0, ry * FRAME_H)
    self:_draw()
    love.graphics.pop()
  end
  if rx ~= 0 and ry ~= 0 then
    love.graphics.push()
    love.graphics.translate(rx * FRAME_W, ry * FRAME_H)
    self:_draw()
    love.graphics.pop()
  end
end
function Player:update(dt)
  -- if self._tw and self._tw:update(dt) then self._mouth, self._tw = 0, nil end
  if self._tw and self._tw:update(dt) then
    self._tw:reset()
  end
end

return { EatenPit = EatenPit, Pit = Pit, Player = Player }

