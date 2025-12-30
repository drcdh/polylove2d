local hub = {}

local games = { grid = require("games.grid.client"), smash = require("games.smash.client") }

local ordtab = require("ordtab")
local util = require("util")

local active_games = nil
local available_games = nil
local client_state = nil

local current_game = nil

local function __draw(love, my_cid)
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

function hub.draw(love, my_cid)
  if current_game then
    current_game:draw(love, my_cid)
  else
    __draw(love, my_cid)
  end
end

local function __update(my_cid, update, param)
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
  elseif update == "joingame" then
    local mod = param
    current_game = games[mod].new()
  elseif update == "leave" then
    local cid = param
    client_state:remove(cid)
  else
    print(string.format("Didn't recognize update '%s'", update))
  end
end

function hub.update(my_cid, data)
  local update, param = data:match("^(%S-):(%S*)")
  if current_game then
    if update == "leave" and param == my_cid then -- FIXME
      current_game = nil
    else
      current_game:update(my_cid, update, param)
    end
  else
    __update(my_cid, update, param)
  end
end

return hub

