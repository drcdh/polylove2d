print(_VERSION)

local socket = require "socket"

local games = require "games"
local util = require "util"

local udp = socket.udp()

udp:settimeout(0)
udp:setsockname("*", 23114)

local player_ip_ports = {}
local world = {}

local function send_to_players(prefix, msg)
  local msg = string.format("%s:%s", prefix, msg)
  -- print(string.format("Sending to all players: %s", msg))
  for _name, _ipp in pairs(player_ip_ports) do
    -- print(string.format("Sending %s to %s and %s:%d", prefix, _name, _ipp[1], _ipp[2]))
    udp:sendto(msg, _ipp[1], _ipp[2])
  end
end

-- todo: setting these callbacks should happen when a game is started, which will be controlled by a player
function games.current_game.state_callback(s) send_to_players("state", util.encode(s)) end
function games.current_game.update_callback(u) send_to_players("update", util.encode(u)) end

print "Starting server loop"
local running = true
while running do
  local data, msg_or_ip, port_or_nil = udp:receivefrom()
  if data then
    print("DATA: ", data)
    local cmd, stuff = data:match("^(%S-):(%S*)")
    if cmd == "connect" then
      local name = stuff
      player_ip_ports[name] = { msg_or_ip, port_or_nil }
      print(string.format("%s connected from %s:%d", name, tostring(msg_or_ip), port_or_nil))
    elseif cmd == "join" then
      local name = stuff
      games.current_game.player_join(name)
      print(string.format("%s joined %s", name, games.current_game.name))
    elseif cmd == "leave" then
      games.current_game.player_leave(stuff)
    elseif cmd == "disconnect" then
      local name = stuff
      player_ip_ports[name] = nil
      print(string.format("%s disconnected", name))
    else
      games.current_game.update(cmd, stuff)
    end
  elseif msg_or_ip ~= "timeout" then
    error("Unknown network error:" .. tostring(msg_or_ip))
  end

  socket.sleep(0.1)
end

