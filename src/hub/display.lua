local hub = {}

local games = { grid = require("games.grid.display"), smash = require("games.smash.display") }

local ordtab = require("ordtab")
local util = require("util")

local active_games = nil
local available_games = ordtab.new()
local client_state = nil

local current_game = nil

function hub.init()
  for k, v in pairs(games) do
    available_games:add(v.name, k)
  end
end

local function __draw(love, my_cid)
  -- List games
  local my_selection
  if client_state and client_state:get(my_cid) then
    my_selection = client_state:get(my_cid).selection
  end
  if available_games then
    for i, name, _ in available_games:iter() do
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
      love.graphics.setColor(.5, .3, .2)
      love.graphics.print("~ ~ ~ ~ ~", 100, 100 + 20 * (1 + available_games:len()))
    end
  end
  if active_games then
    for i, gid, g in active_games:iter() do
      i = i + 1 + available_games:len()
      if i - 1 == my_selection then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(string.format("> %s [%s] (%d) <", g.name, gid or "NEW", g.num_players), 100, 100 + 20 * i)
      else
        love.graphics.setColor(.5, .5, .5)
        love.graphics.print(string.format("%s [%s] (%d)", g.name, gid or "NEW", g.num_players), 100, 100 + 20 * i)
      end
    end
  end
  -- List players
  if client_state then
    for i, cid, _ in client_state:iter() do
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
    current_game:draw()
  else
    __draw(love, my_cid)
  end
  -- debug info
  if current_game then
    love.graphics.print("Current game is " .. current_game.name, 600, 600)
  else
    love.graphics.print("Current game is nil", 600, 600)
  end
end

function hub.update(my_cid, data)
  local update, param = data:match("^(%S-):(%S*)")
  if update == "hub-activegames" then
    active_games = ordtab.new(util.decode(param))
  elseif update == "hub-state" then
    client_state = ordtab.new(util.decode(param))
  elseif update == "hub-select" then
    local cid, selection = param:match("^(%S-),(%S+)")
    client_state:add(cid, { selection = tonumber(selection) })
  elseif update == "hub-switchgame" then
    local cid, gid = param:match("^(%S-),(%S+)")
    client_state:add(cid, { gid = gid })
    if cid == my_cid then
      current_game = games[active_games:get(gid).mod].new(my_cid)
    end
  elseif update == "hub-leave" then
    local cid = param
    client_state:remove(cid)
  elseif current_game and current_game.playing and current_game:update(update, param) then
    if not current_game.playing then
      current_game = nil
    end
  else
    print(string.format("Didn't recognize update '%s'", update))
  end
end

function hub.love_update(dt)
  if current_game then
    current_game:love_update(dt)
  end
end

return hub

