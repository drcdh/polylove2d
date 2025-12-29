local hub = {}

local games = { grid = require("games.grid.client") }

local util = require "util"

local state = { active_games = {}, available_games = {}, client_state = {} }

function hub.draw(love, my_cid)
  -- List games
  if state.client_state[my_cid] then my_selection = state.client_state[my_cid].selection end
  local i = 1
  for name, k in pairs(state.available_games) do
    if i == my_selection then
      love.graphics.setColor(1, 1, 1)
      love.graphics.print(string.format("> %s [%s] <", name, "NEW"), 100, 100 + 20 * i)
    else
      love.graphics.setColor(.5, .5, .5)
      love.graphics.print(string.format("%s [%s]", name, "NEW"), 100, 100 + 20 * i)
    end
    i = i + 1
  end
  for gid, g in pairs(state.active_games) do
    if i + #state.available_games == my_selection then
      love.graphics.setColor(1, 1, 1)
      love.graphics.print(string.format("> %s [%s] <", g.name, gid or "NEW"), 100, 100 + 20 * i)
    else
      love.graphics.setColor(.5, .5, .5)
      love.graphics.print(string.format("%s [%s]", g.name, gid or "NEW"), 100, 100 + 20 * i)
    end
    i = i + 1
  end
  -- List players
  i = 1
  for cid, cs in pairs(state.client_state) do
    if cid == my_cid then
      love.graphics.setColor(1, 1, 1)
      love.graphics.print(cid, 400, 100 + 20 * i)
    else
      love.graphics.setColor(.8, .8, .8)
      love.graphics.print(cid, 400, 100 + 20 * i)
    end
    i = i + 1
  end
end

function hub.update(my_cid, data)
  local update, param = data:match("^(%S-):(%S*)")
  if update == "join" then
    local cid = param
    state.client_state[cid] = { selection = 1 }
  elseif update == "state" then
    state = util.decode(param)
  elseif update == "select" then
    local selection = param
    state.client_state[my_cid].selection = tonumber(selection)
  elseif update == "leave" then
    local cid = param
    state.client_state[cid] = nil
  else
    print(string.format("Didn't recognize update '%s'", update))
  end
end

return hub

