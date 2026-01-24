return {
  initialize = function(self)
    local state = { macrostate = "__START__", players = {} }
    if self and self.cids then
      for cid, _ in pairs(self.cids) do
        state.players[cid] = { selection = 1 }
      end
    end
    self.state = state
  end,

  join = function(self, cid)
    self.state.players[cid] = { selection = 1 }
    self:send_all(string.format("addplayer:%s", cid))
  end,

  leave = function(self, cid)
    self:send_all(string.format("removeplayer:%s", cid))
    self.state.players[cid] = nil
  end,

  is_playing = function(self, cid)
    return self.state.players[cid] ~= nil
  end,

  process_input = function(self, cid, button, button_state)
    if button == INPUT.UP and button_state == "pressed" then
      self.state.players[cid].selection = UTIL.wrap_dec(self.state.players[cid].selection, #STAGES.LIST)
      self:send_all(string.format("setselection:%s,%d", cid, self.state.players[cid].selection))
    elseif button == INPUT.DOWN and button_state == "pressed" then
      self.state.players[cid].selection = UTIL.wrap_inc(self.state.players[cid].selection, #STAGES.LIST)
      self:send_all(string.format("setselection:%s,%d", cid, self.state.players[cid].selection))
    elseif button == INPUT.ENTER and button_state == "pressed" then
      self.state.chosen_stage = STAGES.LIST[self.state.players[cid].selection]
    elseif button == INPUT.BACK and button_state == "released" then
      self:leave(cid)
    end
  end,

  update = function(self)
    if self.state.chosen_stage then
      self.next_macrostate = "__PLAY__"
    end
  end,
}

