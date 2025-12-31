local hub = {}

local INPUT = require("inputs")

local games = { grid = require("games.grid.server"), smash = require("games.smash.server") }

local ordtab = require("ordtab")
local util = require("util")

local active_games = ordtab.new()
local available_games = ordtab.new()
local client_state = {}

hub.send = nil -- defined in server.main

function hub.init() for k, v in pairs(games) do available_games:add(v.name, k) end end

local function send_all(msg)
  for cid, s in pairs(client_state) do if not s.gid then hub.send(cid, msg) end end
end

local function get_active_games_info()
  local info = {}
  for _, gid, g in active_games:iter() do
    info[gid] = { mod = g.mod, name = g.name, num_players = g:num_players() }
  end
  return info
end

local function __change_selection(cid, ds)
  local s = client_state[cid].selection + ds
  if s == 0 then s = available_games:len() + active_games:len() end
  if s > available_games:len() + active_games:len() then s = 1 end
  client_state[cid].selection = s
  send_all(string.format("select:%s,%d", cid, s))
end

local function __start_game(cid, mod)
  local newgame = games[mod].new(nil, hub.send)
  active_games:add(newgame.gid, newgame)
  send_all(string.format("activegames:%s", util.encode(get_active_games_info()))) -- update clients that game exists
  send_all(string.format("switchgame:%s,%s", cid, newgame.gid))
  newgame:join(cid)
  client_state[cid].gid = newgame.gid
  send_all(string.format("activegames:%s", util.encode(get_active_games_info()))) -- update clients that client has joined new active game
  -- print(string.format("%s started %s [%s]", cid, mod, newgame.gid))
end

local function __join_game(cid, gid)
  send_all(string.format("switchgame:%s,%s", cid, gid))
  active_games:get(gid):join(cid)
  client_state[cid].gid = gid
  send_all(string.format("activegames:%s", util.encode(get_active_games_info())))
  -- print(string.format("%s joined %s", cid, gid))
end

local function __process_input(cid, button, button_state)
  if button == INPUT.UP and button_state == "pressed" then
    __change_selection(cid, -1)
  elseif button == INPUT.DOWN and button_state == "pressed" then
    __change_selection(cid, 1)
  elseif button == INPUT.ENTER and button_state == "released" then
    local s = client_state[cid].selection
    if s <= available_games:len() then
      local _, mod = available_games:iget(s)
      __start_game(cid, mod)
    else
      s = s - available_games:len()
      __join_game(cid, active_games:ikey(s))
    end
  end
end

function hub.join(cid)
  hub.send(cid, string.format("activegames:%s", util.encode(get_active_games_info())))
  hub.send(cid, string.format("state:%s", util.encode(client_state)))
  local s = 1
  client_state[cid] = { selection = s }
  send_all(string.format("select:%s,%d", cid, s))
end

function hub.leave(cid)
  client_state[cid] = nil
  send_all(string.format("leave:%s", cid))
end

function hub.process_input(cid, button, button_state)
  local s = client_state[cid]
  if s then
    if s.gid then
      local g = active_games:get(s.gid)
      g:process_input(cid, button, button_state)
    else
      __process_input(cid, button, button_state)
    end
  else
    print(string.format("Got input from unrecognized client %s", cid))
  end
end

function hub.update(dt)
  -- bring players back to hub if not in game
  for cid, s in pairs(client_state) do
    if s.gid then
      local g = active_games:get(s.gid)
      if not g or not g:has_player(cid) then
        hub.join(cid) -- rejoin hub
        s.gid = nil
      end
    end
  end
  -- remove inactive games
  local np, nf = active_games:filter(function(g) return g:active() end)
  if nf > 0 then send_all(string.format("activegames:%s", util.encode(get_active_games_info()))) end

  for _, _, g in active_games:iter() do g:update() end
end

return hub

