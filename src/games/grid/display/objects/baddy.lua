local T_WALK = 1

local EYE_COLOR = { .9, .9, .8 }
local MOUTH_COLOR = { .6, .4, .4 }
local PUPIL_COLOR = { .3, 0, .1 }
local SPOTS_COLOR = { .3, .1, .2 }
local COLORS = { { 0, .6, 0 }, { 0, .3, .3 }, { .2, .2, .2 }, { .7, .7, .7 } }

local function init(o, n)
  UTIL.update_table(o, { c = COLORS[n or 1], f = FACE.RIGHT, l = FACE.RIGHT })
  o._walk = 0
  o.repeated_tweens.walk = TWEEN.new(T_WALK, o, { _walk = 1 })
end

local function hflip_x(x, s)
  if s then
    return s - x
  else
    return x
  end
end
local function hflip_rect(x, y, w, h, s)
  if s then
    return s - x, y, -w, h
  else
    return x, y, w, h
  end
end

local function draw(self)
  local C = CELL_PIXELS -- short alias of global
  love.graphics.push()
  love.graphics.translate(CELL_TO_TOP_LEFT_PIXEL(self.i, self.j))
  love.graphics.scale(C)

  local s = self.f == FACE.LEFT and 1 or nil

  love.graphics.setColor(self.c)
  love.graphics.rectangle("fill", .1, .1, .8, .4) -- symmetric
  -- love.graphics.rectangle("fill", .2, .5, .3, .3)
  love.graphics.rectangle("fill", unpack { hflip_rect(.2, .5, .3, .3, s) })

  local w = 2 * math.abs(self._walk - .5)
  love.graphics.rectangle("fill", unpack { hflip_rect(.25, .8, .1, .1 * w, s) })
  love.graphics.rectangle("fill", unpack { hflip_rect(.4, .8, .1, .1 * (1 - w), s) })

  -- love.graphics.setColor(MOUTH_COLOR)
  -- love.graphics.rectangle("fill", .45, .44, .3, .01)

  -- love.graphics.setColor(SPOTS_COLOR)
  -- love.graphics.circle("fill", .25, .35, .03)

  local di, dj = FACE.inv_calc(self.l)

  love.graphics.setColor(EYE_COLOR)
  love.graphics.circle("fill", hflip_x(.6, s), .25, .15)
  love.graphics.circle("fill", hflip_x(.8, s), .15, .1)
  love.graphics.setColor(PUPIL_COLOR)
  love.graphics.circle("fill", hflip_x(.6, s) + di * .02, .25 + dj * .02, .1)
  love.graphics.circle("fill", hflip_x(.8, s) + di * .02, .15 + dj * .02, .08)

  love.graphics.pop()
end

local function face(self, f)
  self.l = f
  if f == FACE.RIGHT or f == FACE.LEFT then
    self.f = f
  end
end

local function move(self, t)
end

return OBJECT(init, draw, face, move)

