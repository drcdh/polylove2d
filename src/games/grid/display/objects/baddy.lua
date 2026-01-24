local tween = require "tween"

local object = require("games.grid.display.objects.gen")

local WIDTH = .8 -- relative to CELL_PIXELS

local function init(i, j, c)
  local o = { i = i, j = j, c = c or { 0, .6, .3 }, f = FACE.RIGHT }
  return o
end

local function draw(self)
  local x, y = CELL_TO_CENTER_PIXEL(self.i, self.j)
  x = x - WIDTH * CELL_PIXELS / 2
  y = y - WIDTH * CELL_PIXELS / 2
  love.graphics.setColor(unpack(self.c))
  love.graphics.rectangle("fill", x, y, WIDTH * CELL_PIXELS, WIDTH * CELL_PIXELS)
end

return object(init, draw)

