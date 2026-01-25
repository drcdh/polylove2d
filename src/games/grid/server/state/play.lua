local SPEED = 2 -- cells/second
local T_AI = 2 -- seconds

local function _try_eat_pit(self, cid, i, j)
  local l = i + self.state.size.w * j + 1
  if self.state.pits[l] then
    self.state.pits[l] = false
    self.state.num_pits = self.state.num_pits - 1
    self:send_all(string.format("removepit:%d,%d", i, j))
    self.state.players[cid].score = self.state.players[cid].score + 1
    self:send_all(string.format("setplayer:%s,%s", cid, UTIL.encode({ score = self.state.players[cid].score })))
  end
end

local function _try_move(self, cid)
  local p = self.state.players[cid]
  local pp = self.private.players[cid]
  local i, j = p.i, p.j
  local i1, j1 = p.i, p.j
  local di, dj = pp.di, pp.dj

  if i == 0 and di == -1 then
    i1 = self.state.size.w - 1
  elseif i == self.state.size.w - 1 and di == 1 then
    i1 = 0
  else
    i1 = i + di
  end
  if j == 0 and dj == -1 then
    j1 = self.state.size.h - 1
  elseif j == self.state.size.h - 1 and dj == 1 then
    j1 = 0
  else
    j1 = j + dj
  end

  if i ~= i1 or j ~= j1 then
    local l = i1 + self.state.size.w * j1 + 1
    if self.state.walls[l] then
      -- bonk
    else
      if di ~= 0 then
        pp.tw_mv = TWEEN.new(1 / SPEED, p, { i = p.i + pp.di })
      elseif dj ~= 0 then
        pp.tw_mv = TWEEN.new(1 / SPEED, p, { j = p.j + pp.dj })
      end
    end
    p.f = FACE.calc(di, dj)
    self:send_all(string.format("setplayer:%s,%s", cid, UTIL.encode({ f = p.f })))
  end
end

local function _check_wrap(self, cid)
  local p = self.state.players[cid]
  p.i = p.i % self.state.size.w
  p.j = p.j % self.state.size.h
end

return {
  initialize = function(self)
    local data = STAGES.DATA[self.state.chosen_stage]
    local private = { players = {} }
    local state = {
      macrostate = "__PLAY__",
      size = { w = data.w, h = data.h },
      num_pits = 0,
      players = {}, -- self.state.players,
      pits = {},
      walls = {},
    }
    local cids = {}
    for cid, _ in pairs(self.state.players) do
      cids[#cids + 1] = cid
    end

    local _b = 0
    local _p = 0
    for j = 1, data.h do
      local row = data.walls[j]
      for i = 1, data.w do
        local c = row:sub(i, i)
        if c == "x" then
          state.pits[#state.pits + 1] = false
          state.walls[#state.walls + 1] = true
        else
          state.walls[#state.walls + 1] = false
          if c == "p" and _p < #cids then
            _p = _p + 1
            state.players[cids[_p]] = {
              i = i - 1,
              j = j - 1,
              f = FACE.RIGHT,
              visual = string.format("P%d", _p),
              score = 0,
            }
            private.players[cids[_p]] = { di = 0, dj = 0 }
            state.pits[#state.pits + 1] = false
          elseif c == "b" then
            _b = _b + 1
            state.players[_b] = { i = i - 1, j = j - 1, f = FACE.RIGHT, visual = string.format("B%d", _b) }
            private.players[_b] = { di = 0, dj = 0, _t_ai = 1 }
            private.players[_b].tw_ai = TWEEN.new(T_AI, private.players[_b], { _t_ai = 0 })
            state.pits[#state.pits + 1] = false
          else
            state.pits[#state.pits + 1] = true
            state.num_pits = state.num_pits + 1
          end
        end
      end
    end
    self.private = private
    self.state = state
  end,
  join = function(self, cid)
  end,
  leave = function(self, cid)
    self:send_all(string.format("removeplayer:%s", cid))
    self.state.players[cid] = nil
  end,
  is_playing = function(self, cid)
    return self.state.players[cid] ~= nil
  end,

  process_input = function(self, cid, button, button_state)
    local p = self.private.players[cid]
    if p then
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
        -- self:leave(cid)
      end
    else
      print("Ignoring input from spectator " .. cid)
    end
  end,

  update = function(self, dt)
    for cid, p in pairs(self.state.players) do
      local prev_i, prev_j = p.i, p.j
      local pp = self.private.players[cid]
      if not pp.tw_mv then
        _try_move(self, cid)
      end
      if pp.tw_mv and pp.tw_mv:update(dt) then
        _check_wrap(self, cid)
        _try_eat_pit(self, cid, p.i, p.j)
        _try_move(self, cid)
      end
      if p.i ~= prev_i or p.j ~= prev_j then
        self:send_all(string.format("setplayer:%s,%s", cid, UTIL.encode({ i = p.i, j = p.j })))
      end
    end
    if self.state.num_pits == 0 then
      self.next_macrostate = "__END__"
    end
  end,
}

