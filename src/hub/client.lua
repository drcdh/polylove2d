local hub = {}

local games = { grid = require("games.grid.client") }

local ordtab = require("ordtab")
local util = require("util")

local active_games = nil
local available_games = nil
local client_state = nil

function hub.draw(love, my_cid)
  -- List games
  if client_state and client_state:get(my_cid) then
    my_selection = client_state:get(my_cid).selection
  end
  if available_games then
    for i, name, k in available_games:iter() do
      if i == my_selection then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("> %s [%s] <", name, "NEW"), 100, 100 + 20 * i)
      else
        love.graphics.setColor(.5, .5, .5)
        love.graphics.print(string.format("%s [%s]", name, "NEW"), 100, 100 + 20 * i)
      end
    end
  end
  if available_games and active_games then
    if active_games:len() > 0 then
      love.graphics.print("~ ~ ~ ~ ~", 100, 100 + 20 * available_games:len())
    end
  end
  if active_games then
    for i, gid, g in active_games:iter() do
      local i = i + 1 + available_games:len()
      if i == my_selection then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("> %s [%s] <", g.name, gid or "NEW"), 100, 100 + 20 * i)
      else
        love.graphics.setColor(.5, .5, .5)
        love.graphics.print(string.format("%s [%s]", g.name, gid or "NEW"), 100, 100 + 20 * i)
      end
    end
  end
  -- List players
  if client_state then
    for i, cid, cs in client_state:iter() do
      if cid == my_cid then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(cid, 400, 100 + 20 * i)
      else
        love.graphics.setColor(.8, .8, .8)
        love.graphics.print(cid, 400, 100 + 20 * i)
      end
    end
  end
end

function hub.update(my_cid, data)
  local update, param = data:match("^(%S-):(%S*)")
  if update == "join" then
    local cid = param
    client_state:add(cid, { selection = 1 })
  elseif update == "state" then
    local state = util.decode(param)
    active_games = ordtab.new(state.active_games)
    available_games = ordtab.new(state.available_games)
    client_state = ordtab.new(state.client_state)
  elseif update == "select" then
    local selection = param
    client_state._t[my_cid].selection = tonumber(selection)
  elseif update == "leave" then
    local cid = param
    client_state:remove(cid)
  else
    print(string.format("Didn't recognize update '%s'", update))
  end
end

return hub

