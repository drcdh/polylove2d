local WIDTH = .8 -- relative to CELL_PIXELS

local function init(o, c)
  UTIL.update_table(o, { c = c or { 0, .6, .3 } })
end

local function draw(self)
  local x, y = CELL_TO_CENTER_PIXEL(self.i, self.j)
  local w = WIDTH * CELL_PIXELS
  x = x - w / 2
  y = y - w / 2
  love.graphics.setColor(unpack(self.c))
  love.graphics.rectangle("fill", x, y, w, w)
  local di, dj = FACE.inv_calc(self.f)
  love.graphics.setColor(.9, .9, .9)
  love.graphics.circle("fill", x + w * (.5 + .25 * di), y + w * (.5 + .25 * dj), .1 * w)
end

return OBJECT(init, draw)

