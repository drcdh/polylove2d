local TIMER = require("timer")

local SPEED = 2 -- cells/second

local T_AI = .1 -- seconds
local T_AI_PAUSE = 1 -- seconds

local function _init_ai(pp)
  pp.ai_state = "start"
  pp.timers.ai = TIMER.new(T_AI)
  pp.timers.ai_pause = TIMER.new(T_AI_PAUSE)
end

local function is_empty(self, i, j)
  if i == 0 then
    i = self.state.size.w - 1
  end
  if i == self.state.size.w then
    i = 0
  end
  if j == 0 then
    j = self.state.size.h - 1
  end
  if j == self.state.size.h then
    j = 0
  end

  local l = i + j * self.state.size.w + 1
  if self.state.walls[l] then
    return false
  end
  for _, pp in pairs(self.private.players) do
    if i == pp.i and j == pp.j then
      return false
    end
  end
  return true
end

local function get_empty_adjacent(self, i, j)
  local cells = {}
  for _, _c in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
    if is_empty(self, i + _c[1], j + _c[2]) then
      cells[#cells + 1] = _c
    end
  end
  return cells
end

local function _step_ai(self, p, pp)
  if pp.ai_state then
    -- """AI"""
    if pp.timers.ai:status() then
      pp.timers.ai:reset()
      if pp.ai_state == "start" then
        pp.timers.ai_pause:reset()
        pp.ai_state = "move"
      elseif pp.ai_state == "move" then
        -- pick a random direction to move (will be done by _try_move)
        local empty_adjacent = get_empty_adjacent(self, pp.i, pp.j)
        if empty_adjacent then
          local d = empty_adjacent[math.random(1, #empty_adjacent)]
          pp.di, pp.dj = d[1], d[2]
          pp.ai_state = "moving"
        else
          pp.timers.ai_pause:reset()
          pp.ai_state = "pause"
        end -- not evenly distributed
      elseif pp.ai_state == "moving" then
        pp.di, pp.dj = 0, 0
        pp.timers.ai_pause:reset()
        pp.ai_state = "pause"
      elseif pp.ai_state == "pause" then
        if pp.timers.ai_pause:status() then
          -- done waiting
          pp.ai_state = "move"
        end
      else
        print("WHAT?!?")
      end
    end
  end
end

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
        pp.i = p.i + pp.di
        pp.tw_mv = TWEEN.new(1 / SPEED, p, { i = pp.i })
      elseif dj ~= 0 then
        pp.j = p.j + pp.dj
        pp.tw_mv = TWEEN.new(1 / SPEED, p, { j = pp.j })
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
    for j = 0, data.h - 1 do
      local row = data.walls[j + 1]
      for i = 0, data.w - 1 do
        local c = row:sub(i + 1, i + 1)
        if c == "x" then
          state.pits[#state.pits + 1] = false
          state.walls[#state.walls + 1] = true
        else
          state.walls[#state.walls + 1] = false
          if c == "p" and _p < #cids then
            _p = _p + 1
            state.players[cids[_p]] = { i = i, j = j, f = FACE.RIGHT, visual = string.format("P%d", _p), score = 0 }
            private.players[cids[_p]] = { i = i, j = j, di = 0, dj = 0, timers = {} }
            state.pits[#state.pits + 1] = false
          elseif c == "b" then
            _b = _b + 1
            state.players[_b] = { i = i, j = j, f = FACE.RIGHT, visual = string.format("B%d", _b) }
            private.players[_b] = { i = i, j = j, di = 0, dj = 0, timers = {} }
            _init_ai(private.players[_b])
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

      for _, timer in pairs(pp.timers) do
        timer:update(dt)
      end

      _step_ai(self, p, pp)

      if not pp.tw_mv then
        _try_move(self, cid)
      end
      if pp.tw_mv and pp.tw_mv:update(dt) then
        _check_wrap(self, cid)
        if type(cid) == "string" then
          -- client (player)
          _try_eat_pit(self, cid, p.i, p.j)
        end
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

