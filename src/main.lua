print(_VERSION)

local socket = require("socket")

local constants = require("constants")
local util = require("util")

local games = { grid = require("games.grid.client") }

local WINDOW_SIZE = 600

local address, port = "127.0.0.1", 23114
local ping
local udp

local time_since_update = 0
local update_rate = 0.1

local menu_selection = 0
local menu = nil
local menu_busy = nil

local current_game = nil
local player_name = nil

local function send(name, cmd, gid, param)
  local msg = string.format("%s:%s:%s:%s", name or "", cmd or "", gid or "", param or "")
  print(string.format("Sending %s", msg))
  udp:send(msg)
end

local function generate_game_list(stuff)
  menu = {}
  for gmod, g in pairs(games) do menu[#menu + 1] = { gmod = gmod, gname = g.name, gid = "NEW" } end
  for _, g in ipairs(util.decode(stuff)) do
    menu[#menu + 1] = { gmod = g.mod, gname = g.name, gid = g.gid }
  end
end

function love.load(args)
  -- love.window.setMode(WINDOW_SIZE, WINDOW_SIZE)
  math.randomseed(os.time())
  player_name = args[1] or ("Player" .. tostring(math.random(1000, 9999)))
  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address, port)
  send(player_name, "connect")
end

function love.keypressed(key) if key == "escape" then love.event.push("quit", 0) end end

function love.update(dt)
  if ping then ping = ping + dt end

  if current_game then
    time_since_update = time_since_update + dt
    if time_since_update >= update_rate then
      current_game:process_input(dt)
      time_since_update = 0
    end
    current_game:update(dt)
  else
    if menu and not menu_busy then
      if love.keyboard.isDown("up") or love.keyboard.isDown("left") then
        menu_selection = (menu_selection - 1) % #menu
        menu_busy = 1
      end
      if love.keyboard.isDown("down") or love.keyboard.isDown("right") then
        menu_selection = (menu_selection + 1) % #menu
        menu_busy = 1
      end
      if love.keyboard.isDown("return") then
        print(menu_selection, #menu, util.encode(menu))
        local m = menu[menu_selection + 1]
        local gid, gmod = m.gid, m.gmod
        if gid == "NEW" then gid = nil end
        current_game = games[gmod].new(gid, player_name, send)
        send(player_name, "join", current_game.gid, gmod)
        menu_busy = 1
      end
    elseif menu_busy then
      menu_busy = menu_busy - dt
      if menu_busy <= 0 then menu_busy = nil end
    end
  end

  repeat
    local data, msg = udp:receive()
    if data then
      local update, stuff = data:match("^(%S-):(%S*)")
      print(string.format("Got %s: %s", update, stuff))
      if update == "ping" then
        ping = 0
      elseif update == "list" then
        generate_game_list(stuff)
      elseif current_game then
        current_game:process_update(update, stuff)
      end
    elseif msg == "connection refused" then
      udp = nil
      current_game = nil
    elseif msg ~= "timeout" then
      error("Network error: " .. tostring(msg))
    end
  until not data
end

function love.draw()
  if current_game then
    current_game:draw()
  else
    if menu then
      for _i, m in ipairs(menu) do
        if _i == menu_selection + 1 then
          love.graphics.setColor(1, 1, 1)
          love.graphics.print(string.format("> %s [%s] <", m.gname, m.gid), 100, 100 + 20 * _i)
        else
          love.graphics.setColor(.5, .5, .5)
          love.graphics.print(string.format("%s [%s]", m.gname, m.gid), 100, 100 + 20 * _i)
        end
      end
    end
  end
  if not ping then
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("No connection", 0, 0)
  else
    if ping <= constants.PING then
      love.graphics.setColor(0, 1, 0)
    else
      love.graphics.setColor(.5, .5, 0)
    end
    love.graphics.print(string.format("Ping %.2f", ping), 0, 0)
  end
end

function love.quit()
  if current_game then send(player_name, "leave", current_game.gid) end
  send(player_name, "disconnect")
end
