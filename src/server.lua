print(_VERSION)

local socket = require "socket"

local constants = require "constants"
local util = require "util"

local ping = os.clock()
local udp = socket.udp()

udp:settimeout(0)
udp:setsockname("*", 23114)

local games = { grid = require("games.grid.server") }

local current_games = {}
local player_ip_ports = {}

local function update_all_players(prefix, msg, sync_id)
  local msg = string.format("%s:%s:%s", prefix, msg or "", sync_id or "")
  print(string.format("<< %s", msg))
  for _name, _ipp in pairs(player_ip_ports) do
    print(string.format("Sending %s to %s at %s:%d", prefix, _name, _ipp[1], _ipp[2]))
    udp:sendto(msg, _ipp[1], _ipp[2])
  end
end

local function update_player(player_name, prefix, msg, sync_id)
  local msg = string.format("%s:%s:%s", prefix, msg or "", sync_id or "")
  print(string.format("%s < %s", player_name, msg))
  local _ipp = player_ip_ports[player_name]
  udp:sendto(msg, _ipp[1], _ipp[2])
end

local function current_games_list()
  local l = {}
  for k, v in pairs(current_games) do l[#l + 1] = { gid = k, mod = v.mod, name = v.name } end
  return l
end

print "Starting server loop"
local running = true
while running do
  local data, msg_or_ip, port_or_nil = udp:receivefrom()
  if data then
    print(string.format("> %s", data))
    local name, cmd, gid, param, sync_id = data:match("^(%S-):(%S-):(%S-):(%S-):(%S*)")
    if cmd == "refreshlist" then
      update_player(name, "list", current_games_list())
    elseif cmd == "connect" then
      player_ip_ports[name] = { msg_or_ip, port_or_nil }
      print(string.format("%s connected from %s:%d", name, tostring(msg_or_ip), port_or_nil))
      update_player(name, "list", util.encode(current_games_list()))
    elseif cmd == "join" then
      if not current_games[gid] then -- new game with gid created client-side
        local mod = param
        current_games[gid] = games[mod].new(gid, update_player, update_all_players)
      end
      current_games[gid]:initialize_player(name)
      current_games[gid]:player_join(name)
      print(string.format("%s joined %s", name, gid))
    elseif cmd == "leave" then
      current_games[gid]:player_leave(name)
    elseif cmd == "disconnect" then
      player_ip_ports[name] = nil
      print(string.format("%s disconnected", name))
    else
      current_games[gid]:update(name, cmd, param, sync_id)
    end
  elseif msg_or_ip ~= "timeout" then
    error("Unknown network error:" .. tostring(msg_or_ip))
  end

  if os.time() - ping >= constants.PING then
    -- update_all_players("ping")
    ping = os.time()
  end

  socket.sleep(0.1)
end

