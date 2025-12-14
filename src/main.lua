print(_VERSION)

local socket = require("socket")

-- local games = require "games"
local util = require "util"

local address, port = "127.0.0.1", 23114
local udp

local time_since_update = 0
local update_rate = 0.1

local games = { grid = require("games.grid.client") }

local current_game = nil
local game_state = nil
local player_state = {}

function love.load(args)
  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address, port)
  current_game = "grid"
  player_state.name = args[1] or ("Player" .. tostring(math.random(1000, 9999)))
  udp:send(string.format("connect:%s", player_state.name))
  udp:send(string.format("join:%s", player_state.name))
end

function love.keypressed(key) if key == "escape" then love.event.push("quit", 0) end end

function love.update(dt)
  if current_game then
    time_since_update = time_since_update + dt
    if time_since_update >= update_rate then
      data = games[current_game].process_input(love.keyboard, player_state, dt)
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
      if update == "state" then
        game_state = util.decode(stuff)
      elseif update == "update" then
        util.update_table(game_state, util.decode(stuff))
      else
        print(string.format("Unrecognized update '%s'", update))
      end
    elseif msg ~= "timeout" then
      error("Network error: " .. tostring(msg))
    end
  until not data
end

function love.draw()
  if current_game and game_state then games[current_game].draw(game_state, player_state) end
end

function love.quit()
  if current_game then
    udp:send(string.format("leave:%s", player_state.name))
    udp:send(string.format("disconnect:%s", player_state.name))
  end
end
