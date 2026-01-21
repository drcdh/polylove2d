local STAGES = require("games.grid.stages")

return {
  initialize = function(server_state)
    PLAYERS = {}
    for cid, _ in pairs(server_state.players) do
      PLAYERS[cid] = { selection = 1 }
    end
  end,
  draw = function()
    for i, s in ipairs(STAGES.LIST) do
      if i == PLAYERS[CID].selection then
        s = ">> " .. s .. " <<"
      end
      love.graphics.print(s, 300, 300 + 20 * i)
    end
  end,
  update = function(update, param)
    if update == "addplayer" then
      local cid = param
      PLAYERS[cid] = { selection = 1 }
    elseif update == "removeplayer" then
      local cid = param
      PLAYERS[cid] = nil
    elseif update == "setselection" then
      local cid, selection = param:match("^(%S-),(%S+)")
      PLAYERS[cid].selection = tonumber(selection)
    else
      return false
    end
    return true
  end,

  love_update = function(dt)
  end,
}
