local FACE = require("games.grid.face")
local STAGES = require("games.grid.stages")

local INPUT = require("inputs")
local util = require("util")

local tween = require("tween")

local SPEED = 2 -- cells/second

local function _try_eat_pit(self, cid, i, j)
  local l = i + self.state.size.w * j + 1
  if self.state.pits[l] then
    self.state.pits[l] = false
    self:send_all(string.format("removepit:%d,%d", i, j))
    self.state.players[cid].score = self.state.players[cid].score + 1
    self:send_all(string.format("setplayer:%s,%s", cid, util.encode({ score = self.state.players[cid].score })))
  end
end

local function _try_move(self, cid)
  local p = self.state.players[cid]
  local pp = self.state.players[cid]
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
        pp._tw = tween.new(1 / SPEED, p, { i = p.i + pp.di })
      elseif dj ~= 0 then
        pp._tw = tween.new(1 / SPEED, p, { j = p.j + pp.dj })
      end
    end
    p.f = FACE.calc(di, dj)
    self:send_all(string.format("setplayer:%s,%s", cid, util.encode({ f = p.f })))
  end
end

local function _check_wrap(self, cid)
  local p = self.state.players[cid]
  p.i = p.i % self.state.size.w
  p.j = p.j % self.state.size.h
end

return {
  __START__ = {
    new = function(cids)
      local state = { macrostate = "__START__", players = {} }
      if cids then
        for cid, _ in pairs(cids) do
          state.players[cid] = { selection = 1 }
        end
      end
      return state
    end,
    join = function(self, cid)
      self.state.players[cid] = { selection = 1 }
      self:send_all(string.format("addplayer:%s", cid))
    end,

    leave = function(self, cid)
      self:send_all(string.format("removeplayer:%s", cid))
      self.state.players[cid] = nil
    end,

    process_input = function(self, cid, button, button_state)
      if button == INPUT.UP and button_state == "pressed" then
        self.state.players[cid].selection = util.wrap_dec(self.state.players[cid].selection, #STAGES.LIST)
        self:send_all(string.format("setselection:%s,%d", cid, self.state.players[cid].selection))
      elseif button == INPUT.DOWN and button_state == "pressed" then
        self.state.players[cid].selection = util.wrap_inc(self.state.players[cid].selection, #STAGES.LIST)
        self:send_all(string.format("setselection:%s,%d", cid, self.state.players[cid].selection))
      elseif button == INPUT.ENTER and button_state == "pressed" then
        self.state.chosen_stage = STAGES.LIST[self.state.players[cid].selection]
        self.state.next = true
      elseif button == INPUT.BACK and button_state == "released" then
        self:leave(cid)
      end
    end,
    update = function(self)
      if self.state.next then
        self.next_macrostate = "__PLAY__"
      end
    end,
  },
  __PLAY__ = {
    new = function(prev)
      local data = STAGES.DATA[prev.chosen_stage]
      local state = { macrostate = "__PLAY__", size = { w = data.w, h = data.h }, players = {}, pits = {}, walls = {} }
      local cids = {}
      for cid, _ in pairs(prev.players) do
        cids[#cids + 1] = cid
      end

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
              state.players[cids[_p]] = { i = i - 1, j = j - 1, f = FACE.RIGHT, score = 0, di = 0, dj = 0 }
              state.pits[#state.pits + 1] = false
            else
              state.pits[#state.pits + 1] = true
            end
          end
        end
      end
      return state
    end,
    join = function(self, cid)
    end,
    leave = function(self, cid)
      self:send_all(string.format("removeplayer:%s", cid))
      self.state.players[cid] = nil
    end,
    process_input = function(self, cid, button, button_state)
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
        -- self:leave(cid)
      end
    end,
    update = function(self, dt)
      for cid, p in pairs(self.state.players) do
        local prev_i, prev_j = p.i, p.j
        local pp = self.state.players[cid]
        if not pp._tw then
          _try_move(self, cid)
        end
        if pp._tw and pp._tw:update(dt) then
          _check_wrap(self, cid)
          _try_eat_pit(self, cid, p.i, p.j)
          _try_move(self, cid)
        end
        if p.i ~= prev_i or p.j ~= prev_j then
          self:send_all(string.format("setplayer:%s,%s", cid, util.encode({ i = p.i, j = p.j })))
        end
      end
      if self.state.num_pits == 0 then
        self.next_macrostate = "__END__"
      end
    end,
  },
  __END__ = {
    new = function(prev)
      return { macrostate = "__END__", players = prev.players }
    end,
    join = function(self, cid)
    end,
    leave = function(self, cid)
    end,
    process_input = function(self, cid, button, button_state)
      if button == INPUT.ENTER and button_state == "pressed" then
        self.state.next = true
      end
    end,
    update = function(self)
      if self.state.next then
        self.next_macrostate = "__START__"
      end
    end,
  },
}
