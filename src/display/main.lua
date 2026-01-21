local socket = require("socket")

local hub = require("hub.display")

local fullscreen = false

local address, port = "127.0.0.1", 23114
local udp

local cid
local current_game
local games = {}

local function send(cmd, param)
  local msg = string.format("%s:%s", cmd or "", param or "")
  print(string.format("< %s", msg))
  udp:send(msg)
end

function love.load(args)
  local display = tonumber(args[1]) or 1
  local desktop_w, desktop_h = love.window.getDesktopDimensions(display)
  print(
      string.format(
          "Using display %d (of %d) with dimensions %d x %d", display, love.window.getDisplayCount(), desktop_w,
          desktop_h
      )
  )
  if fullscreen then
    window_w, window_h = desktop_w, desktop_h
    print("Starting fullscreen")
  else
    window_w, window_h = desktop_w / 2, desktop_h / 2
    print(string.format("Starting window with dimensions %d x %d", window_w, window_h))
  end
  love.window.setMode(window_w, window_h, { fullscreen = fullscreen, display = display })
  hub.init()
  math.randomseed(os.time())
  cid = args[2] or ("Player" .. tostring(math.random(1000, 9999)))
  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address, port)
  send("connect", cid)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit", 0)
  elseif key == "f" then
    fullscreen = not fullscreen
    assert(love.window.setFullscreen(fullscreen), "Borked trying to switch to/from fullscreen")
  else
    send("input", string.format("%s,%s", key, "pressed"))
  end
end

function love.keyreleased(key)
  send("input", string.format("%s,%s", key, "released"))
end

function love.draw()
  if current_game then
    games[current_game].draw(love, cid)
  else
    hub.draw(love, cid)
  end
end

function love.update(dt)
  repeat
    local data, msg = udp:receive()
    if data then
      print(string.format("> %s", data))
      hub.update(cid, data)
    elseif msg == "connection refused" then
      udp = nil
      current_game = nil
    elseif msg ~= "timeout" then
      error("Network error: " .. tostring(msg))
    end
  until not data

  hub.love_update(dt)
end

function love.quit()
  -- if current_game then send(player_name, "leave", current_game.gid) end
  send("disconnect")
end
