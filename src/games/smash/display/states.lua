return {
  __START__ = {
    draw = function(self)
      love.graphics.print(string.format("TIME: % 2d seconds", self.state.time), 300, 300)
    end,
    update = function(self, update, param)
      if update == "settime" then
        local time = tonumber(param)
        self.state.time = time
      elseif update == "removeplayer" then
        local cid = param
        self.state.players[cid] = nil
        if cid == self.cid then
          self.playing = false
        end
      else
        return false
      end
      return true
    end,
    love_update = function(self, dt)
    end,
  },
  __PLAY__ = {
    draw = function(self)
      love.graphics.print(string.format("TIME LEFT: %.2f", self.state.time), 300, 250)
      local i = 0
      for name, pstate in pairs(self.state.players) do
        love.graphics.print(string.format("%d  -  %s", pstate.score, name), 300, 300 + 20 * i)
        i = i + 1
      end
    end,
    update = function(self, update, param)
      if update == "setscore" then
        local cid, score = param:match("^(%S-),(%S*)")
        self.state.players[cid].score = tonumber(score)
      elseif update == "settime" then
        local time = tonumber(param)
        self.state.time = time
      else
        return false
      end
      return true
    end,
    love_update = function(self, dt)
    end,
  },
  __END__ = {
    draw = function(self)
      love.graphics.print("FINAL SCORES", 300, 250)
      local i = 0
      for name, pstate in pairs(self.state.players) do
        love.graphics.print(string.format("%d  -  %s", pstate.score, name), 300, 300 + 20 * i)
        i = i + 1
      end
    end,
    update = function(self, update, param)
    end,
    love_update = function(self, dt)
    end,
  },
}
