return {
  initialize = function(self)
    local state = { macrostate = "__END__", players = {} }
    for cid, p in pairs(self.state.players) do
      state.players[cid] = { score = p.score }
    end
    self.state = state
  end,
  join = function(self, cid)
  end,
  leave = function(self, cid)
  end,
  is_playing = function(self, cid)
    return self.state.players[cid] ~= nil
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
}

