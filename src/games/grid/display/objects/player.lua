local RADIUS = .4 -- relative to CELL_PIXELS
local T_WAKKA = .5 -- seconds
local THETA_WAKKA = math.pi/4 -- radians, from middle to edge of mouth

local COLORS = { { .6, 0, 0 }, { .6, .6, 1 }, { 1, 1, .6 }, { .6, 0, .6 } }

local function init(i, j, n)
  local o = { i = i, j = j, c = COLORS[tonumber(n)], score = 0, f = FACE.RIGHT, _mouth = 0 }
  o._tw = TWEEN.new(T_WAKKA, o, { _mouth = 1 })
  return o
end

local function __stencil_mouth(self)
  local di, dj = FACE.inv_calc(self.f)
  local r = RADIUS * CELL_PIXELS
  if di ~= 0 then
    love.graphics.polygon("fill", 0, 0, di * r, r * m, di * r, -r * m)
  else
    love.graphics.polygon("fill", 0, 0, r * m, dj * r, -r * m, dj * r)
  end
end

local function _draw_beak(self, th)
  local r = RADIUS * CELL_PIXELS
  local x, y = r*math.cos(th), r*math.sin(th)
  love.graphics.circle("fill", x, y, r*.1)
end

local function _draw(self)
  local th = THETA_WAKKA * (1 - 2 * math.abs(self._mouth - .5))
  love.graphics.setColor(unpack(self.c))
  love.graphics.stencil(
      function()
        return __stencil_mouth(self)
      end, "increment"
  )
  love.graphics.setStencilTest("less", 1)
  love.graphics.circle("fill", 0, 0, RADIUS * CELL_PIXELS)
  _draw_beak(self, th)
  love.graphics.setStencilTest()
end

local function draw(self)
  -- center on cell
  local x, y = CELL_TO_CENTER_PIXEL(self.i, self.j)
  love.graphics.push()
  love.graphics.translate(x, y)

  _draw(self)

  love.graphics.pop()
end

return OBJECT(init, draw)

