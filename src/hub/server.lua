local hub = {}

local constants = require("constants")
local games = { grid = require("games.grid.server") }

local util = require("util")

local active_games = {}
local available_games = {}
local client_state = {}

hub.send = nil -- defined in server.main

local function send_all(msg)
  for cid, cs in pairs(client_state) do if not cs.in_game then hub.send(cid, msg) end end
end

local function get_active_games_info()
  local info = {}
  for gid, g in pairs(active_games) do info[gid] = { mod = g.mod, name = g.name } end
  return info
end

local function __process_input(cid, button, button_state)
  local s = client_state[cid].selection
  if button == constants.UP then
    s = s - 1
    if s == 0 then s = #available_games + #active_games end
  elseif button == constants.DOWN then
    s = s + 1
    if s == #available_games + #active_games then s = 1 end
  end
  client_state[cid].selection = s
  hub.send(cid, string.format("select:%d", s))
end

function hub.init() for k, v in pairs(games) do available_games[v.name] = k end end

function hub.join(cid)
  hub.send(cid, string.format("state:%s", util.encode({
    client_state = client_state,
    available_games = available_games,
    active_games = get_active_games_info(),
  })))
  client_state[cid] = { selection = 1 }
  send_all(string.format("join:%s", cid))
end

function hub.leave(cid)
  client_state[cid] = nil
  send_all(string.format("leave:%s", cid))
end

function hub.process_input(cid, button, button_state)
  local s = client_state[cid]
  if s then
    if s.in_game then
      local g = active_games[s.in_game]
      g:process_input(cid, button, button_state)
    else
      __process_input(cid, button, button_state)
    end
  else
    print(string.format("Got input from unrecognized client %s", cid))
  end
end

return hub

