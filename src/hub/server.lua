local hub = {}

local INPUT = require("inputs")

local games = { grid = require("games.grid.server") }

local ordtab = require("ordtab")
local util = require("util")

local active_games = ordtab.new()
local available_games = ordtab.new()
local client_state = {}

hub.send = nil -- defined in server.main

local function send_all(msg)
  for cid, cs in pairs(client_state) do if not cs.in_game then hub.send(cid, msg) end end
end

local function get_active_games_info()
  print(active_games:len())
  local info = {}
  for _, gid, g in active_games:iter() do info[gid] = { mod = g.mod, name = g.name } end
  return info
end

local function __change_selection(cid, ds)
  local s = client_state[cid].selection + ds
  if s == 0 then s = available_games:len() + active_games:len() end
  if s >= available_games:len() + active_games:len() then s = 1 end
  client_state[cid].selection = s
  hub.send(cid, string.format("select:%d", s))
end

local function __process_input(cid, button, button_state)
  if button == INPUT.UP then
    __change_selection(cid, -1)
  elseif button == INPUT.DOWN then
    __change_selection(cid, 1)
  elseif button == INPUT.ENTER then
    local s = client_state[cid].selection
    if s <= available_games:len() then
      __start_game(cid, available_games:ikey(s))
    else
      __join_game(cid, active_games:ikey(s - active_games:len()))
    end
  end
end

function hub.init() for k, v in pairs(games) do available_games:add(v.name, k) end end

function hub.join(cid)
  hub.send(cid, string.format("state:%s", util.encode({
    client_state = client_state,
    available_games = available_games._t,
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
      local g = active_games.get(s.in_game)
      g:process_input(cid, button, button_state)
    else
      __process_input(cid, button, button_state)
    end
  else
    print(string.format("Got input from unrecognized client %s", cid))
  end
end

return hub

