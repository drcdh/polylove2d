FACE = require("games.grid.face")
TWEEN = require("tween")
UTIL = require("util")

local OBJECTS = require("games.grid.display.objects")

local objects = {}

local TWEEN_REPEAT = true

local fullscreen = false

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

  CELL_PIXELS = WINDOW_H / 5
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
  objects[#objects + 1] = OBJECTS.Baddy:new(0, row)

end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit", 0)
  elseif key == "space" then
    TWEEN_REPEAT = not TWEEN_REPEAT
  end
end

function love.draw()
  for _, _obj in pairs(objects) do
    _obj:draw()
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
    end
  end

end

