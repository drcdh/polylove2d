local hub = {}

local ordtab = require("ordtab")

UTIL = require("util")

local NEWGAME = require("display.game")

local available_games = ordtab.new()
for k, v in pairs({ grid = { name = "Grid" }, smash = { name = "Smash" } }) do
  available_games:add(v.name, k)
end

local active_games = nil
local client_state = nil
local current_game = nil

local function __draw()
  -- List games
  local my_selection
  if client_state and client_state:get(CID) then
    my_selection = client_state:get(CID).selection
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
      if cid == CID then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(cid, 400, 100 + 20 * i)
      else
        love.graphics.setColor(.8, .8, .8)
        love.graphics.print(cid, 400, 100 + 20 * i)
      end
    end
  end
end

function hub.draw()
  if current_game then
    current_game:draw()
  else
    __draw()
  end
end

function hub.update(data)
  local update, param = data:match("^(%S-):(%S*)")
  if update == "hub-activegames" then
    active_games = ordtab.new(UTIL.decode(param))
  elseif update == "hub-state" then
    client_state = ordtab.new(UTIL.decode(param))
  elseif update == "hub-select" then
    local cid, selection = param:match("^(%S-),(%S+)")
    client_state:add(cid, { selection = tonumber(selection) })
  elseif update == "hub-switchgame" then
    local cid, gid = param:match("^(%S-),(%S+)")
    client_state:add(cid, { gid = gid })
    if cid == CID then
      current_game = NEWGAME(active_games:get(gid).mod)
    end
  elseif update == "hub-return" then
    local cid = param
    if cid == CID then
      current_game = nil
    else
      print("hub display got hub-return with different cid")
    end
  elseif update == "hub-leave" then
    local cid = param
    client_state:remove(cid)
  elseif current_game and current_game:update(update, param) then
    -- update handled by game
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

