local INPUT = require("inputs")

return {
  __START__ = {
    new = function(cids)
      local state = { macrostate = "__START__", players = {}, time = 10 }
      if cids then for cid, _ in pairs(cids) do state.players[cid] = { selection = 1 } end end
      return state
    end,

    join = function(self, cid)
      self.state.players[cid] = true
      self:send_all(string.format("addplayer:%s", cid))
    end,

    leave = function(self, cid)
      self:send_all(string.format("removeplayer:%s", cid))
      self.state.players[cid] = nil
    end,

    process_input = function(self, cid, button, button_state)
      if button == INPUT.UP and button_state == "pressed" then
        self.state.time = self.state.time + 1
        self:send_all(string.format("settime:%d", self.state.time))
      elseif button == INPUT.DOWN and button_state == "pressed" then
        if self.state.time > 1 then self.state.time = self.state.time - 1 end
        self:send_all(string.format("settime:%d", self.state.time))
      elseif button == INPUT.ENTER and button_state == "pressed" then
        self.state.next = true
      elseif button == INPUT.BACK and button_state == "released" then
        self:leave(cid)
      end

    end,

    update = function(self) if self.state.next then self.next_macrostate = "__PLAY__" end end,
  },
  __PLAY__ = {
    new = function(prev)
      local state = { macrostate = "__PLAY__", players = {}, time = prev.time }
      for cid, _ in pairs(prev.players) do state.players[cid] = { score = 0 } end
      return state
    end,

    join = function(self, cid) end,
    leave = function(self, cid)
      self:send_all(string.format("removeplayer:%s", cid))
      self.state.players[cid] = nil
    end,

    process_input = function(self, cid, button, button_state)
      if button == INPUT.ENTER and button_state == "pressed" then
        self.state.players[cid].score = self.state.players[cid].score + 1
        self:send_all(string.format("setscore:%s,%d", cid, self.state.players[cid].score))
      end
    end,

    update = function(self, dt)
      self.state.time = self.state.time - dt
      self:send_all(string.format("settime:%.2f", self.state.time))
      if self.state.time <= 0 then self.next_macrostate = "__END__" end
    end,
  },
  __END__ = {
    new = function(prev) return { macrostate = "__END__", players = prev.players } end,

    join = function(cid) end,
    leave = function(cid) end,

    process_input = function(self, cid, button, button_state)
      if button == INPUT.ENTER and button_state == "pressed" then self.state.next = true end
    end,

    update = function(self) if self.state.next then self.next_macrostate = "__START__" end end,
  },
}
