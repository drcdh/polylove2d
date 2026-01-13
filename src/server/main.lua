local socket = require "socket"

local hub = require "hub.server"

local udp = socket.udp()

udp:settimeout(0)
udp:setsockname("*", 23114)

local clients = {} -- connection info
local clients_by_ipp = {}

hub.init()

hub.send = function(cid, msg)
  print(string.format("%s < %s", cid, msg))
  udp:sendto(msg, clients[cid].ip, clients[cid].port)
end

local function connect(ip, port, cid)
  clients[cid] = { cid = cid, ip = ip, port = port }
  if clients_by_ipp[ip] then
    clients_by_ipp[ip][port] = cid
  else
    clients_by_ipp[ip] = { [port] = cid }
  end
  print(string.format("%s connected", cid))
  hub.join(cid)
end

local function disconnect(cid)
  hub.leave(cid)
  clients[cid] = nil
  print(string.format("%s disconnected", cid))
end

local function get_cid(ip, port) if clients_by_ipp[ip] then return clients_by_ipp[ip][port] end end

local running = true
while running do
  local data, msg_or_ip, port_or_nil = udp:receivefrom()
  if data then
    local cid = get_cid(msg_or_ip, port_or_nil)
    print(string.format("%s > %s", cid or string.format("%s:%d", msg_or_ip, port_or_nil), data))
    local cmd, param = data:match("^(%S-):(%S*)")
    if cmd == "connect" then
      connect(msg_or_ip, port_or_nil, param)
    elseif cmd == "disconnect" then
      disconnect(cid)
    elseif cmd == "input" then
      local button, button_state = param:match("^(%S-),(%S*)")
      hub.process_input(cid, button, button_state)
    end
  elseif msg_or_ip ~= "timeout" then
    error("Unknown network error:" .. tostring(msg_or_ip))
  end

  hub.update()

  socket.sleep(0.01)
end
