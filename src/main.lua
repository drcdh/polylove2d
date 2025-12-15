print(_VERSION)

local socket = require("socket")

-- local games = require "games"
local util = require "util"

local PING_GOOD = 0.1 -- seconds

local address, port = "127.0.0.1", 23114
local ping
local udp

local time_since_update = 0
local update_rate = 0.1

local games = { grid = require("games.grid.client") }

local current_game = nil
local player_name = nil

function love.load(args)
  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address, port)
  current_game = games.grid
  player_name = args[1] or ("Player" .. tostring(math.random(1000, 9999)))
  udp:send(string.format("connect:%s", player_name))
  udp:send(string.format("join:%s", player_name))
end

function love.keypressed(key) if key == "escape" then love.event.push("quit", 0) end end

function love.update(dt)
  if ping then ping = ping + dt end

  if current_game then
    time_since_update = time_since_update + dt
    if time_since_update >= update_rate then
      data = current_game.process_input(love.keyboard, player_name, dt)
      if data then
        udp:send(data)
        time_since_update = 0
      end
    end
  end

  repeat
    local data, msg = udp:receive()
    if data then
      local update, stuff = data:match("^(%S-):(%S*)")
      print(string.format("Got %s: %s", update, stuff))
      if update == "ping" then ping = 0 end
      current_game.process_update(update, stuff)
    elseif msg ~= "timeout" then
      error("Network error: " .. tostring(msg))
    end
  until not data
end

function love.draw()
  if current_game then current_game.draw() end
  if not ping then
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("No connection", 0, 0)
  else
    if ping <= PING_GOOD then
      love.graphics.setColor(0, 1, 0)
    else
      love.graphics.setColor(.5, .5, 0)
    end
    love.graphics.print(string.format("Ping %.2f", ping), 0, 0)
  end
end

function love.quit()
  if current_game then
    udp:send(string.format("leave:%s", player_name))
    udp:send(string.format("disconnect:%s", player_name))
  end
end
