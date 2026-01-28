local objects = require("games.grid.display.objects")

local M = 0 -- -.5

return {
  initialize = function(server_state)
    SIZE = server_state.size
    WALLS = server_state.walls
    if SIZE.w / SIZE.h > WINDOW_W / WINDOW_H then
      FRAME_W = WINDOW_W
      FRAME_H = FRAME_W * SIZE.h / SIZE.w
    else
      FRAME_H = WINDOW_H
      FRAME_W = FRAME_H * SIZE.w / SIZE.h
    end
    print(
        string.format(
            "Window %dx%d || Stage %dx%d || Frame %dx%d", WINDOW_W, WINDOW_H, SIZE.w, SIZE.h, FRAME_W, FRAME_H
        )
    )

    STAGE_X0 = (WINDOW_W - FRAME_W) / 2
    STAGE_Y0 = (WINDOW_H - FRAME_H) / 2

    CELL_W = FRAME_W / (SIZE.w + 2 * M)
    CELL_H = FRAME_H / (SIZE.h + 2 * M)
    print(string.format("Stage @ (%d, %d) || Cell %dx%d", STAGE_X0, STAGE_Y0, CELL_W, CELL_H))
    assert(CELL_W == CELL_H, string.format("Cell sizes don't match: CELL_W = %f, CELL_H = %f", CELL_W, CELL_H))
    CELL_PIXELS = CELL_W

    WALLS_CANVAS = love.graphics.newCanvas(FRAME_W, FRAME_H)
    STAGE_CANVAS = love.graphics.newCanvas(FRAME_W, FRAME_H)

    love.graphics.setCanvas(WALLS_CANVAS)
    love.graphics.setColor(0, .1, .6)
    for j = 1, SIZE.h do
      for i = 1, SIZE.w do
        if WALLS[i + SIZE.w * (j - 1)] then
          love.graphics.rectangle("fill", (i + M - 1) * CELL_W, (j + M - 1) * CELL_H, CELL_W, CELL_H)
        end
      end
    end
    for _x = CELL_W, FRAME_W, CELL_W do
      love.graphics.line(_x, 0, _x, FRAME_H)
    end
    for _y = CELL_H, FRAME_H, CELL_H do
      love.graphics.line(0, _y, FRAME_W, _y)
    end
    love.graphics.setCanvas()

    NUM_PLAYERS, PLAYERS = 0, {}
    for cid, player in pairs(server_state.players) do
      local type, n = player.visual:match("^(%a)(%d)")
      if type == "P" then
        PLAYERS[cid] = objects.Player:new(player.i, player.j, n)
        NUM_PLAYERS = NUM_PLAYERS + 1
      elseif type == "B" then
        PLAYERS[cid] = objects.Baddy:new(player.i, player.j)
      end
    end

    EATEN_PITS, PITS = {}, {}
    for i = 0, SIZE.w - 1 do
      for j = 0, SIZE.h - 1 do
        local l = i + SIZE.w * j + 1
        if server_state.pits[l] then
          PITS[l] = objects.Pit:new(i, j)
        end
      end
    end
  end,

  draw = function()
    -- DRAW WALLS, ETC. TO STAGE
    love.graphics.setCanvas({ STAGE_CANVAS, stencil = true })
    love.graphics.setColor(1, 1, 1)
    love.graphics.clear()
    love.graphics.draw(WALLS_CANVAS, 0, 0)
    for _, pit in pairs(PITS) do
      pit:draw()
    end
    do
      love.graphics.setColor(0, .1, .3)
      love.graphics.rectangle("fill", 10, 10, 100, 20 * (1 + NUM_PLAYERS))
      local ys = 20 -- pixel position for score
      love.graphics.setColor(1, 1, 1)
      for cid, player in pairs(PLAYERS) do
        player:draw()
        if player.score then
          love.graphics.setColor(1, 1, 1)
          love.graphics.print(string.format("%s: %d   (%.2f, %.2f)", cid, player.score, player.i, player.j), 20, ys)
          ys = ys + 20
        end
      end
    end
    for _, ep in ipairs(EATEN_PITS) do
      ep:draw()
    end
    -- DRAW STAGE TO WINDOW
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(STAGE_CANVAS, STAGE_X0, STAGE_Y0)
  end,

  update = function(update, param)
    if update == "setplayer" then
      local cid, attr = param:match("^(%S-),(%S*)")
      for k, v in pairs(UTIL.decode(attr)) do
        PLAYERS[cid][k] = v
      end
    elseif update == "moveplayer" then
      local cid, numbers = param:match("^(%S-),(%S*)")
      local i, j, i_, j_, t = UTIL.tonumbers(unpack{numbers:match("^(%d+),(%d+),(%-?%d+),(%-?%d+),([%d.e]+)")})
      PLAYERS[cid]:move(i, j, i_, j_, t)
    elseif update == "removepit" then
      local i, j = param:match("^(%-?[%d.e]+),(%-?[%d.e]+)")
      local l = i + SIZE.w * j + 1
      PITS[l] = nil
      EATEN_PITS[#EATEN_PITS + 1] = objects.EatenPit:new(i, j)
    elseif update == "removeplayer" then
      local cid = param
      PLAYERS[cid] = nil
    elseif update == "score" then
      local cid = param
      PLAYERS[cid].score = PLAYERS[cid].score + 1
    else
      return false
    end
    return true
  end,

  love_update = function(dt)
    local ep = {}
    for _, eaten_pit in ipairs(EATEN_PITS) do
      if not eaten_pit:update(dt) then
        ep[#ep + 1] = eaten_pit
      end
    end
    EATEN_PITS = ep
    for _, pit in pairs(PITS) do
      pit:update(dt)
    end
    for _, player in pairs(PLAYERS) do
      player:update(dt)
    end
  end,
}
