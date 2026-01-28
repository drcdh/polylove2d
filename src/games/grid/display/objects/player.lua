local RADIUS = .4 -- relative to CELL_PIXELS
local T_WAKKA = .5 -- seconds
local THETA_WAKKA = math.pi / 4 -- radians, from middle to edge of mouth

local EYE_RX = .1 -- relative to RADIUS
local EYE_RY = .2 -- relative to RADIUS
local PUPIL_RX = .8 * EYE_RX -- relative to RADIUS
local PUPIL_RY = .8 * EYE_RY -- relative to RADIUS

local BEAK_COLOR = { .3, .2, .2 }
local BROW_COLOR = { .1, .1, .2 }
local EYE_COLOR = { 1, 1, 1 }
local PUPIL_COLOR = { 0, 0, .1 }
local WING_COLOR = { .1, .1, .2 }
local COLORS = { { .6, 0, 0 }, { .6, .6, 1 }, { 1, .6, 0 }, { .6, 0, .6 } }
local SUPER_COLOR = { .9, .9, .1 }

local function init(o, n)
  UTIL.update_table(o, { c = COLORS[tonumber(n)], score = 0, f = FACE.RIGHT, _mouth = 0 })
end

local function draw(self)
  -- center on cell
  local x, y = CELL_TO_CENTER_PIXEL(self.i, self.j)
  love.graphics.push()
  love.graphics.translate(x, y)

  local hflip = 1
  local r = RADIUS * CELL_PIXELS
  local th_mouth = THETA_WAKKA * (1 - 2 * math.abs(self._mouth - .5))

  if self.f == FACE.RIGHT then
    th_mouth = -th_mouth
  elseif self.f == FACE.LEFT then
    hflip = -1
  elseif self.f == FACE.UP then
    hflip = -1
    love.graphics.rotate(math.pi / 2)
  elseif self.f == FACE.DOWN then
    th_mouth = -th_mouth
    love.graphics.rotate(math.pi / 2)
  end

  -- draw top half
  love.graphics.push()
  love.graphics.rotate(th_mouth)
  love.graphics.stencil(
      function()
        love.graphics.rectangle("fill", -CELL_PIXELS / 2, 0, CELL_PIXELS, CELL_PIXELS / 2)
      end, "increment"
  )
  love.graphics.setStencilTest("less", 1)
  love.graphics.setColor(self.c)
  love.graphics.circle("fill", 0, 0, r)
  love.graphics.setColor(BEAK_COLOR)
  love.graphics.circle("fill", hflip * r, 0, .2 * r)
  love.graphics.setStencilTest()
  if self.super then
    love.graphics.setColor(SUPER_COLOR)
    love.graphics.polygon("fill", 0, -.2 * r, hflip * 1.0 * r, -.2 * r, -.2 * r, -1.4 * r)
  end
  love.graphics.setColor(BROW_COLOR)
  love.graphics.polygon("fill", 0, -.2 * r, hflip * 1.2 * r, -.2 * r, 0, -1.2 * r)
  love.graphics.setColor(EYE_COLOR)
  love.graphics.ellipse("fill", hflip * .3 * r, -.5 * r, EYE_RX * r, EYE_RY * r)
  if self.super then
    love.graphics.setColor(SUPER_COLOR)
  else
    love.graphics.setColor(PUPIL_COLOR)
  end
  love.graphics.ellipse("fill", hflip * .32 * r, -.5 * r, PUPIL_RX * r, PUPIL_RY * r)
  love.graphics.pop()
  --

  -- draw bottom half
  love.graphics.push()
  love.graphics.rotate(-th_mouth)
  love.graphics.stencil(
      function()
        love.graphics.rectangle("fill", -CELL_PIXELS / 2, -CELL_PIXELS / 2, CELL_PIXELS, CELL_PIXELS / 2)
      end, "increment"
  )
  love.graphics.setStencilTest("less", 1)
  love.graphics.setColor(self.c)
  love.graphics.circle("fill", 0, 0, RADIUS * CELL_PIXELS)
  love.graphics.setColor(BEAK_COLOR)
  love.graphics.circle("fill", hflip * r, 0, .2 * r)
  love.graphics.setStencilTest()
  love.graphics.setColor(WING_COLOR)
  love.graphics.polygon("fill", -hflip * 1.2 * r, -.1 * r, 0, 0, 0, .6 * r)
  love.graphics.polygon("fill", -hflip * 1.1 * r, .3 * r, 0, .2 * r, 0, .8 * r)
  love.graphics.polygon("fill", -hflip * 0.9 * r, .6 * r, 0, .3 * r, 0, .9 * r)
  love.graphics.pop()
  --

  love.graphics.pop()
end

local function face(self, f)
  self.f = f
end

local function move(self, t)
  self._mouth = 0
  self.tweens.wakka = TWEEN.new(t, self, { _mouth = 1 })
end

return OBJECT(init, draw, face, move)

