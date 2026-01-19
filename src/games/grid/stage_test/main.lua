M = -.5

p = { i = -.4, j = -.2 }

function _wrap()
  local rx, ry = 0, 0
  if p.i < -2 * M then rx = 1 end
  if p.i > S.w - 1 + 2 * M then rx = -1 end
  if p.j < -2 * M then ry = 1 end
  if p.j > S.h - 1 + 2 * M then ry = -1 end
  return rx, ry
end
function _draw_player() love.graphics.circle("fill", CELL_W * (p.i + .5), CELL_H * (p.j + .5), CELL_W * 1 / 2) end
function draw_player()
  _draw_player()
  local rx, ry = _wrap()
  if rx ~= 0 then
    love.graphics.push()
    love.graphics.translate(rx * FRAME_W, 0)
    _draw_player()
    love.graphics.pop()
  end
  if ry ~= 0 then
    love.graphics.push()
    love.graphics.translate(0, ry * FRAME_H)
    _draw_player()
    love.graphics.pop()
  end
  if rx ~= 0 and ry ~= 0 then
    love.graphics.push()
    love.graphics.translate(rx * FRAME_W, ry * FRAME_H)
    _draw_player()
    love.graphics.pop()
  end
end

function wall_at(i, j)
  local c = S.walls[j]:sub(i, i)
  if c == "x" then return true end
end

function draw_wall(i, j)
  if wall_at(i, j) then
    love.graphics.setColor(i / 10, j / 10, 0)
    love.graphics.rectangle("fill", (i + M - 1) * CELL_W, (j + M - 1) * CELL_H, CELL_W, CELL_H)
  end
end

function get_frame_dims()
  if S.w / S.h > DESKTOP_W / DESKTOP_H then
    FRAME_W = DESKTOP_W
    FRAME_H = FRAME_W * S.h / S.w
  else
    FRAME_H = DESKTOP_H
    FRAME_W = FRAME_H * S.w / S.h
  end
end

function love.load(args)
  S = require("games.grid.stages").DATA[args[1] or "Humdrum"]

  DESKTOP_W, DESKTOP_H = love.window.getDesktopDimensions(1)
  love.window.setMode(DESKTOP_W, DESKTOP_H, { fullscreen = true })

  get_frame_dims()
  print(string.format("Desktop %dx%d || Stage %dx%d || Frame %dx%d", DESKTOP_W, DESKTOP_H, S.w, S.h, FRAME_W, FRAME_H))

  STAGE_X0 = (DESKTOP_W - FRAME_W) / 2
  STAGE_Y0 = (DESKTOP_H - FRAME_H) / 2

  CELL_W = FRAME_W / (S.w + 2 * M)
  CELL_H = FRAME_H / (S.h + 2 * M)

  WALLS_CANVAS = love.graphics.newCanvas(FRAME_W, FRAME_H)
  STAGE_CANVAS = love.graphics.newCanvas(FRAME_W, FRAME_H)

  love.graphics.setCanvas(WALLS_CANVAS)
  for j = 1, S.h do for i = 1, S.w do draw_wall(i, j) end end
  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas()
end

function love.draw()
  love.graphics.setCanvas(STAGE_CANVAS)
  love.graphics.clear()
  love.graphics.draw(WALLS_CANVAS)
  draw_player()
  love.graphics.setCanvas()
  love.graphics.draw(STAGE_CANVAS, STAGE_X0, STAGE_Y0)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit", 0)
  elseif key == "left" then
    p.i = p.i - .1
  elseif key == "right" then
    p.i = p.i + .1
  elseif key == "up" then
    p.j = p.j - .1
  elseif key == "down" then
    p.j = p.j + .1
  end
end

function love.update(dt)
  -- p.i = p.i + 3 * dt / 2
  -- p.j = p.j + 2 * dt
  p.i = p.i % (S.w + 2 * M)
  p.j = p.j % (S.h + 2 * M)
end
