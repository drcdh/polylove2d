local STAGES = require("games.grid.stages")

return {
  initialize = function(server_state)
    return server_state
  end,
  draw = function(self)
    for i, s in ipairs(STAGES.LIST) do
      if i == self.state.players[self.cid].selection then
        s = ">> " .. s .. " <<"
      end
      love.graphics.print(s, 300, 300 + 20 * i)
    end
  end,
  update = function(self, update, param)
    if update == "addplayer" then
      local cid = param
      self.state.players[cid] = { selection = 1 }
    elseif update == "removeplayer" then
      local cid = param
      self.state.players[cid] = nil
      if cid == self.cid then
        self.playing = false
      end
    elseif update == "setselection" then
      local cid, selection = param:match("^(%S-),(%S+)")
      self.state.players[cid].selection = tonumber(selection)
    else
      return false
    end
    return true
  end,

  love_update = function(self, dt)
  end,
}
