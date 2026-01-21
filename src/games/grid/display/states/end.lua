return {
  initialize = function(server_state)
    PLAYERS = server_state.players
  end,
  draw = function(self)
    love.graphics.print("FINAL SCORES", 300, 250)
    local i = 0
    for cid, p in pairs(PLAYERS) do
      love.graphics.print(string.format("%d  -  %s", p.score, cid), 300, 300 + 20 * i)
      i = i + 1
    end
  end,
  update = function(self, update, param)
  end,
  love_update = function(self, dt)
  end,
}
