FACE = require("games.grid.face")
INPUT = require("inputs")
TWEEN = require("tween")
UTIL = require("util")

local OBJECTS = require("games.grid.display.objects")

local objects = {}

local BG_COLOR = { .9, .8, .8 }

local OVERLAY = false
local TWEEN_REPEAT = true

local fullscreen = false

local function set_all_face(f)
  for _, _obj in pairs(objects) do
    _obj:face(f)
  end
end

function love.load(args)
  local display = tonumber(args[1]) or 1
  local desktop_w, desktop_h = love.window.getDesktopDimensions(display)
  print(
      string.format(
          "Using display %d (of %d) with dimensions %d x %d", display, love.window.getDisplayCount(), desktop_w,
          desktop_h
      )
  )
  if fullscreen then
    WINDOW_W, WINDOW_H = desktop_w, desktop_h
    love.window.setMode(WINDOW_W, WINDOW_H, { fullscreen = true, display = display })
    print("Starting fullscreen")
  else
    WINDOW_W, WINDOW_H = desktop_w / 2, desktop_h / 2
    love.window.setMode(WINDOW_W, WINDOW_H, { fullscreen = false })
    print(string.format("Starting window with dimensions %d x %d", WINDOW_W, WINDOW_H))
  end

  CELL_PIXELS = WINDOW_H / 3
  print("CELL_PIXELS = ", CELL_PIXELS)

  SIZE = { w = 100, h = 100 }

  local row = 0
  for n = 1, 4 do
    objects[#objects + 1] = OBJECTS.Player:new(n - 1, row, n)
  end

  row = row + 1
  for n = 1, 4 do
    objects[#objects + 1] = OBJECTS.Player:new(n - 1, row, n)
    objects[#objects].super = true
  end

  row = row + 1
  for n = 1, 4 do
    objects[#objects + 1] = OBJECTS.Baddy:new(n - 1, row, n)
  end

  for _, _obj in pairs(objects) do
    if _obj._move then
      _obj:_move(1)
    end
  end

  CELL_W, CELL_H = CELL_PIXELS, CELL_PIXELS
  FRAME_W, FRAME_H = WINDOW_W, WINDOW_H
  GRID_CANVAS = love.graphics.newCanvas(FRAME_W, FRAME_H)
  love.graphics.setCanvas(GRID_CANVAS)
  love.graphics.setColor(1, 1, 1)
  for _x = CELL_W / 10, FRAME_W, CELL_W / 10 do
    love.graphics.line(_x, 0, _x, FRAME_H)
  end
  for _y = CELL_H / 10, FRAME_H, CELL_H / 10 do
    love.graphics.line(0, _y, FRAME_W, _y)
  end
  love.graphics.setCanvas()
end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit", 0)
  elseif key == "space" then
    TWEEN_REPEAT = not TWEEN_REPEAT
  elseif key == "g" then
    OVERLAY = not OVERLAY
  elseif key == INPUT.LEFT then
    set_all_face(FACE.LEFT)
  elseif key == INPUT.UP then
    set_all_face(FACE.UP)
  elseif key == INPUT.RIGHT then
    set_all_face(FACE.RIGHT)
  elseif key == INPUT.DOWN then
    set_all_face(FACE.DOWN)
  end
end

function love.draw()
  love.graphics.clear(BG_COLOR)
  for _, _obj in pairs(objects) do
    _obj:draw()
  end
  if OVERLAY then
    love.graphics.setColor(.5, .5, .5)
    love.graphics.draw(GRID_CANVAS)
  end
end

function love.update(dt)
  for _, _obj in pairs(objects) do
    if _obj.tweens then
      for _, _tw in pairs(_obj.tweens) do
        if _tw:update(dt) and TWEEN_REPEAT then
          _tw:reset()
        end
      end
      for _, _tw in pairs(_obj.repeated_tweens) do
        if _tw:update(dt) and TWEEN_REPEAT then
          _tw:reset()
        end
      end
    end
  end
end

