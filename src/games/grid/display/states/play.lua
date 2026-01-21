local util = require("util")

local objects = require("games.grid.display.objects")

local M = 0 -- -.5

function blah(w, h)

  DESKTOP_W, DESKTOP_H = love.graphics.getDimensions()

  if w / h > DESKTOP_W / DESKTOP_H then
    FRAME_W = DESKTOP_W
    FRAME_H = FRAME_W * h / w
  else
    FRAME_H = DESKTOP_H
    FRAME_W = FRAME_H * w / h
  end
  print(string.format("Desktop %dx%d || Stage %dx%d || Frame %dx%d", DESKTOP_W, DESKTOP_H, w, h, FRAME_W, FRAME_H))

  STAGE_X0 = (DESKTOP_W - FRAME_W) / 2
  STAGE_Y0 = (DESKTOP_H - FRAME_H) / 2

  CELL_W = FRAME_W / (w + 2 * M)
  CELL_H = FRAME_H / (h + 2 * M)
  print(string.format("Stage @ (%d, %d) || Cell %dx%d", STAGE_X0, STAGE_Y0, CELL_W, CELL_H))
  assert(CELL_W == CELL_H, string.format("Cell sizes don't match: CELL_W = %f, CELL_H = %f", CELL_W, CELL_H))

  WALLS_CANVAS = love.graphics.newCanvas(FRAME_W, FRAME_H)
  STAGE_CANVAS = love.graphics.newCanvas(FRAME_W, FRAME_H)

  draw_walls(w, h)
end

function wall_at(i, j, w)
  return WALLS[i + w * (j - 1)]
  -- local c = WALLS[j]:sub(i, i)
  -- if c == "x" then return true end
end

function draw_wall(i, j, w)
  if wall_at(i, j, w) then
    love.graphics.rectangle("fill", (i + M - 1) * CELL_W, (j + M - 1) * CELL_H, CELL_W, CELL_H)
  end
end

function draw_walls(w, h)
  love.graphics.setCanvas(WALLS_CANVAS)
  love.graphics.setColor(0, .1, .6)
  for j = 1, h do
    for i = 1, w do
      draw_wall(i, j, w)
    end
  end
  for _x = CELL_W, FRAME_W, CELL_W do
    love.graphics.line(_x, 0, _x, FRAME_H)
  end
  for _y = CELL_H, FRAME_H, CELL_H do
    love.graphics.line(0, _y, FRAME_W, _y)
  end
  love.graphics.setCanvas()
end

return {
  initialize = function(server_state)
    WALLS = server_state.walls
    local state = { macrostate = server_state.macrostate, eaten_pits = {}, pits = {}, players = {}, num_players = 0 }
    state.size = server_state.size
    blah(state.size.w, state.size.h)
    state.dH = FRAME_H / state.size.h
    state.dW = FRAME_W / state.size.w
    for cid, player in pairs(server_state.players) do
      state.players[cid] = objects.Player:new(player.i, player.j, cid)
      state.num_players = state.num_players + 1
    end
    for i = 0, state.size.w - 1 do
      for j = 0, state.size.h - 1 do
        local l = i + state.size.w * j + 1
        if server_state.pits[l] then
          state.pits[l] = objects.Pit:new(i, j)
        end
      end
    end
    return state
  end,

  draw = function(self)
    -- DRAW WALLS, ETC. TO STAGE
    love.graphics.setCanvas({ STAGE_CANVAS, stencil = true })
    love.graphics.setColor(1, 1, 1)
    love.graphics.clear()
    love.graphics.draw(WALLS_CANVAS, 0, 0)
    for _, pit in pairs(self.state.pits) do
      pit:draw(CELL_W)
    end
    do
      love.graphics.setColor(0, .1, .3)
      love.graphics.rectangle("fill", 10, 10, 100, 20 * (1 + self.state.num_players))
      local ys = 20 -- pixel position for score
      love.graphics.setColor(1, 1, 1)
      for cid, player in pairs(self.state.players) do
        player:draw(self.state.dH, self.state.size)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("%s: %d   (%.2f, %.2f)", cid, player.score, player.i, player.j), 20, ys)
        ys = ys + 20
      end
    end
    for _, ep in ipairs(self.state.eaten_pits) do
      ep:draw(self.state.dW)
    end
    -- DRAW STAGE TO WINDOW
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(STAGE_CANVAS, STAGE_X0, STAGE_Y0)
  end,

  update = function(self, update, param)
    if update == "setplayer" then
      local cid, attr = param:match("^(%S-),(%S*)")
      for k, v in pairs(util.decode(attr)) do
        self.state.players[cid][k] = v
      end
    elseif update == "removepit" then
      local i, j = param:match("^(%-?[%d.e]+),(%-?[%d.e]+)")
      local l = i + self.state.size.w * j + 1
      self.state.pits[l] = nil
      self.state.eaten_pits[#self.state.eaten_pits + 1] = objects.EatenPit:new(i, j)
    elseif update == "leave" then
      local cid = param
      self.state.players[cid] = nil
      if cid == self.cid then
        self.playing = false
      end
    elseif update == "score" then
      local cid = param
      self.state.players[cid].score = self.state.players[cid].score + 1
    else
      print(string.format("Unrecognized update '%s'", update))
    end
  end,

  love_update = function(self, dt)
    local ep = {}
    for _, eaten_pit in ipairs(self.state.eaten_pits) do
      if not eaten_pit:update(dt) then
        ep[#ep + 1] = eaten_pit
      end
    end
    self.state.eaten_pits = ep
    for _, pit in pairs(self.state.pits) do
      pit:update(dt)
    end
    for _, player in pairs(self.state.players) do
      player:update(dt)
    end
  end,
}
