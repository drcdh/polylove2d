print(_VERSION)

local socket = require "socket"

local games = require "games"

local udp = socket.udp()

udp:settimeout(0)
udp:setsockname('*', 23114)

local player_ip_ports = {}
local world = {}

print "Starting server loop"
local running = true
while running do
    data, msg_or_ip, port_or_nil = udp:receivefrom()
    if data then
        print("DATA: ", data)
        cmd, stuff = data:match("^(%S-):(%S*)")
        if cmd == 'connect' then
            local name = stuff
            player_ip_ports[name] = {msg_or_ip, port_or_nil}
            print(string.format("%s connected from %s:%d", name,
                                tostring(msg_or_ip), port_or_nil))
        elseif cmd == 'leave' then
            local name = stuff
            games.current_game.player_leave(name)
        elseif cmd == 'disconnect' then
            local name = stuff
            player_ip_ports[name] = nil
            print(string.format("%s disconnected", name))
        else
            games.current_game.update(cmd, stuff)
        end
    elseif msg_or_ip ~= 'timeout' then
        error("Unknown network error:" .. tostring(msg_or_ip))
    end

    for _name, _ipp in pairs(player_ip_ports) do
        -- print(string.format("Sending update to %s and %s:%d", _name, _ipp[1],
        --                     _ipp[2]))
        udp:sendto(string.format("update:%s", games.current_game.get_state()),
                   _ipp[1], _ipp[2])
    end

    socket.sleep(0.1)
end

