local tween = require "tween"

local object = require("games.grid.display.objects.gen")

local RADIUS = .4 -- relative to CELL_PIXELS
local T_WAKKA = .5 -- seconds

local function init(i, j, n, c)
  local o = { i = i, j = j, c = c or { .6, 0, 0 }, n = n, score = 0, f = FACE.RIGHT, _mouth = 0 }
  o._tw = tween.new(T_WAKKA, o, { _mouth = 1 })
  return o
end

local function __draw_mouth(self)
  local x, y = CELL_TO_CENTER_PIXEL(self.i, self.j)
  local di, dj = FACE.inv_calc(self.f)
  local m = 2 * math.abs(self._mouth - .5)
  local r = RADIUS * CELL_PIXELS
  if di ~= 0 then
    love.graphics.polygon("fill", x, y, x + di * r, y + r * m, x + di * r, y - r * m)
  else
    love.graphics.polygon("fill", x, y, x + r * m, y + dj * r, x - r * m, y + dj * r)
  end
end

local function draw(self)
  local x, y = CELL_TO_CENTER_PIXEL(self.i, self.j)
  love.graphics.setColor(unpack(self.c))
  love.graphics.stencil(
      function()
        return __draw_mouth(self)
      end, "increment"
  )
  love.graphics.setStencilTest("less", 1)
  love.graphics.circle("fill", x, y, RADIUS * CELL_PIXELS)
  love.graphics.setStencilTest()
end

return object(init, draw)

