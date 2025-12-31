local grid = { mod = "grid", name = "Grid", description = "Eat dots!" }

local tween = require("tween")

local INPUT = require("inputs")

local util = require("util")

local SPEED = 2 -- cells/second

GridServer = {}
GridServer.__index = GridServer

function GridServer:new(gid, send)
  local o = {
    state = {
      -- GAME PARAMETERS
      size = 5,
      -- GAME STATE
      players = {},
      pits = {},
      walls = {},
    },
    private = { players = {} },
    gid = gid or string.format("G%04d", math.random(9999)),
    mod = grid.mod,
    name = grid.name,
    send = send,
    t = util.clock(),
  }
  -- for l = 1, o.state.size * o.state.size do o.state.walls[l] = false end
  o.state.walls = {
    true,
    true,
    false,
    true,
    true,
    true,
    false,
    false,
    false,
    true,
    false,
    false,
    true,
    false,
    false,
    true,
    false,
    false,
    false,
    true,
    true,
    true,
    false,
    true,
    true,
  }
  for i = 1, #o.state.walls do o.state.pits[i] = not o.state.walls[i] end
  setmetatable(o, self)
  return o
end

function GridServer:_try_eat_pit(cid, i, j)
  local l = i + self.state.size * j + 1
  if self.state.pits[l] then
    self.state.pits[l] = false
    self:send_all(string.format("removepit:%d,%d", i, j))
    self.state.players[cid].score = self.state.players[cid].score + 1
    self:send_all(string.format("setplayer:%s,%d,%d,%d", cid, self.state.players[cid].i,
                                self.state.players[cid].j, self.state.players[cid].score))
  end
end

function GridServer:has_player(cid) if self.state.players[cid] then return true end end

function GridServer:num_players()
  local n = 0
  for _, _ in pairs(self.state.players) do n = n + 1 end
  return n
end

function GridServer:active() return self:num_players() > 0 end

function GridServer:send_all(msg) for cid, _ in pairs(self.state.players) do self.send(cid, msg) end end

function GridServer:join(cid)
  self.send(cid, "state:" .. util.encode(self.state))
  self.state.players[cid] = { i = 1, j = 1, score = 0, di = 0, dj = 0 } -- todo: face
  self.private.players[cid] = {}
  self:send_all(string.format("setplayer:%s,%d,%d,%d", cid, self.state.players[cid].i,
                              self.state.players[cid].j, self.state.players[cid].score))
end

function GridServer:leave(cid)
  self:send_all(string.format("leave:%s", cid))
  self.state.players[cid] = nil
  self.private.players[cid] = nil
end

function GridServer:process_input(cid, button, button_state)
  local p = self.state.players[cid]
  if button == INPUT.LEFT and button_state == "pressed" then
    p.di = p.di - 1
  elseif button == INPUT.LEFT and button_state == "released" then
    p.di = p.di + 1
  elseif button == INPUT.RIGHT and button_state == "pressed" then
    p.di = p.di + 1
  elseif button == INPUT.RIGHT and button_state == "released" then
    p.di = p.di - 1
  elseif button == INPUT.UP and button_state == "pressed" then
    p.dj = p.dj - 1
  elseif button == INPUT.UP and button_state == "released" then
    p.dj = p.dj + 1
  elseif button == INPUT.DOWN and button_state == "pressed" then
    p.dj = p.dj + 1
  elseif button == INPUT.DOWN and button_state == "released" then
    p.dj = p.dj - 1
  elseif button == INPUT.BACK and button_state == "released" then
    self:leave(cid)
  end
end

function GridServer:_try_move(cid)
  local p = self.state.players[cid]
  local i, j = p.i, p.j
  local i1, j1 = p.i, p.j
  local di, dj = p.di, p.dj

  if i == 0 and di == -1 then
    i1 = self.state.size - 1
  elseif i == self.state.size - 1 and di == 1 then
    i1 = 0
  else
    i1 = i + di
  end
  if j == 0 and dj == -1 then
    j1 = self.state.size - 1
  elseif j == self.state.size - 1 and dj == 1 then
    j1 = 0
  else
    j1 = j + dj
  end

  if i ~= i1 or j ~= j1 then
    local l = i1 + self.state.size * j1 + 1
    if self.state.walls[l] then
      -- todo change face
      print("bonk", i1, j1, l)
    else
      local pp = self.private.players[cid]
      if di ~= 0 then
        pp._tw = tween.new(1 / SPEED, p, { i = p.i + p.di })
      elseif dj ~= 0 then
        pp._tw = tween.new(1 / SPEED, p, { j = p.j + p.dj })
      end
    end
  end
end

function GridServer:_check_wrap(cid)
  local p = self.state.players[cid]
  p.i = p.i % self.state.size
  p.j = p.j % self.state.size
end

function GridServer:update()
  local dt = util.clock() - self.t
  self.t = util.clock()
  for cid, p in pairs(self.state.players) do
    local prev_i, prev_j = p.i, p.j
    local pp = self.private.players[cid]
    if not pp._tw then self:_try_move(cid) end
    if pp._tw and pp._tw:update(dt) then
      self:_check_wrap(cid)
      self:_try_eat_pit(cid, p.i, p.j)
      self:_try_move(cid)
    end
    if p.i ~= prev_i or p.j ~= prev_j then
      self:send_all(string.format("setplayer:%s,%.6f,%.6f,%d", cid, self.state.players[cid].i,
                                  self.state.players[cid].j, self.state.players[cid].score))
    end
  end
end

function grid.new(gid, send) return GridServer:new(gid, send) end

return grid

