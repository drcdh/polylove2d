local FACE = require("games.grid.face")
local STAGES = require("games.grid.states.stages")

GridGame = {}
GridGame.__index = GridGame

function GridGame:new(cids, stage_name)

  local o = {
    state = { state="__GAME__", players = {}, pits = {}, size = data.w, walls = {} },
    private = { players = {} },
  }

  local data = STAGES.DATA[stage_name]
  local _p = 0
  for j = 1, data.h do
    local row = data.walls[j]
    for i = 1, data.w do
      local c = row:sub(i, i)
      if c == "x" then
        o.state.walls[#o.state.walls + 1] = true
      else
        o.state.walls[#o.state.walls + 1] = false
        if c == "p" and _p < #cids then
          _p = _p + 1
          o.state.players[cids[_p]] = { i = i, j = j, f = FACE.RIGHT, score = 0 }
          o.state.private.players[cids[_p]] = { di = 0, dj = 0 }
        end
      end
    end
  end

  setmetatable(o, self)
  return o
end

function GridGame:join(cid)
  self.send(cid, "state:" .. util.encode(self.state))
  -- self:send_all(string.format("setspectator:%s", cid))
end

function GridGame:leave(cid)
  if self.state.players[cid] then
    self.state.players[cid] = nil
    self:send_all(string.format("leave:%s", cid))
  end
end

function GridGame:process_input(cid, button, button_state)
  local p = self.private.players[cid]
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

function GridGame:update()
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
      self:send_all(string.format("setplayer:%s,%s", cid, util.encode({ i = p.i, j = p.j })))
    end
  end
end

function GridGame:_check_wrap(cid)
  local p = self.state.players[cid]
  p.i = p.i % self.state.size
  p.j = p.j % self.state.size
end

function GridGame:_try_eat_pit(cid, i, j)
  local l = i + self.state.size * j + 1
  if self.state.pits[l] then
    self.state.pits[l] = false
    self:send_all(string.format("removepit:%d,%d", i, j))
    self.state.players[cid].score = self.state.players[cid].score + 1
    self:send_all(string.format("setplayer:%s,%s", cid,
                                util.encode({ score = self.state.players[cid].score })))
  end
end

function GridGame:_try_move(cid)
  local p = self.state.players[cid]
  local pp = self.private.players[cid]
  local i, j = p.i, p.j
  local i1, j1 = p.i, p.j
  local di, dj = pp.di, pp.dj

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
      -- bonk
    else
      if di ~= 0 then
        pp._tw = tween.new(1 / SPEED, p, { i = p.i + pp.di })
      elseif dj ~= 0 then
        pp._tw = tween.new(1 / SPEED, p, { j = p.j + pp.dj })
      end
    end
    p.f = FACE.calc(di, dj)
    self:send_all(string.format("setplayer:%s,%s", cid, util.encode({ f = p.f })))
  end
end

return function(cids, stage_name) return GridGame:new(cids, stage_name) end

