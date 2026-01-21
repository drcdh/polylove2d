return {
  __START__ = {
    initialize = function(server_state)
      TIME = server_state.time
    end,
    draw = function()
      love.graphics.print(string.format("TIME: % 2d seconds", TIME), 300, 300)
    end,
    update = function(update, param)
      if update == "settime" then
        local time = tonumber(param)
        TIME = time
      elseif update == "removeplayer" then
        local cid = param
        PLAYERS[cid] = nil
        if cid == CID then
          print("ARGLEBARGLE")
        end
      else
        return false
      end
      return true
    end,
    love_update = function(dt)
    end,
  },
  __PLAY__ = {
    initialize = function(server_state)
      PLAYERS = {}
      for cid, _ in pairs(server_state.players) do
        PLAYERS[cid] = { score = 0 }
      end
      TIME = server_state.time
    end,
    draw = function()
      love.graphics.print(string.format("TIME LEFT: %.2f", TIME), 300, 250)
      local i = 0
      for cid, p in pairs(PLAYERS) do
        love.graphics.print(string.format("%d  -  %s", p.score, cid), 300, 300 + 20 * i)
        i = i + 1
      end
    end,
    update = function(update, param)
      if update == "setscore" then
        local cid, score = param:match("^(%S-),(%S*)")
        PLAYERS[cid].score = tonumber(score)
      elseif update == "settime" then
        local time = tonumber(param)
        TIME = time
      elseif update == "removeplayer" then
        -- do nothing
      else
        return false
      end
      return true
    end,
    love_update = function(dt)
    end,
  },
  __END__ = {
    initialize = function(server_state)
    end,
    draw = function()
      love.graphics.print("FINAL SCORES", 300, 250)
      local i = 0
      for cid, p in pairs(PLAYERS) do
        love.graphics.print(string.format("%d  -  %s", p.score, cid), 300, 300 + 20 * i)
        i = i + 1
      end
    end,
    update = function(update, param)
    end,
    love_update = function(dt)
    end,
  },
}
