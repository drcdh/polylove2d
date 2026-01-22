local INPUT = require("inputs")

return {
  __START__ = {
    initialize = function(self)
      local state = { macrostate = "__START__", players = {}, time = 10 }
      if cids then
        for cid, _ in pairs(self.cids) do
          state.players[cid] = { selection = 1 }
        end
      end
      self.state = state
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
        if self.state.time > 1 then
          self.state.time = self.state.time - 1
        end
        self:send_all(string.format("settime:%d", self.state.time))
      elseif button == INPUT.ENTER and button_state == "pressed" then
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
    initialize = function(self)
      local state = { macrostate = "__PLAY__", players = {}, time = self.state.time }
      for cid, _ in pairs(self.state.players) do
        state.players[cid] = { score = 0 }
      end
      self.state = state
    end,

    join = function(self, cid)
    end,
    leave = function(self, cid)
      self:send_all(string.format("removeplayer:%s", cid))
      self.state.players[cid] = nil
    end,

    process_input = function(self, cid, button, button_state)
      if self.state.players[cid] then
        if button == INPUT.ENTER and button_state == "pressed" then
          self.state.players[cid].score = self.state.players[cid].score + 1
          self:send_all(string.format("setscore:%s,%d", cid, self.state.players[cid].score))
        end
      else
        print("Ignoring input from spectator " .. cid)
      end
    end,

    update = function(self, dt)
      self.state.time = self.state.time - dt
      self:send_all(string.format("settime:%.2f", self.state.time))
      if self.state.time <= 0 then
        self.next_macrostate = "__END__"
      end
    end,
  },
  __END__ = {
    initialize = function(self)
      self.state = { macrostate = "__END__", players = self.state.players }
    end,

    join = function(cid)
    end,
    leave = function(cid)
    end,

    process_input = function(self, cid, button, button_state)
      if self.state.players[cid] then
        if button == INPUT.ENTER and button_state == "pressed" then
          self.state.next = true
        end
      else
        print("Ignoring input from spectator " .. cid)
      end
    end,

    update = function(self)
      if self.state.next then
        self.next_macrostate = "__START__"
      end
    end,
  },
}
