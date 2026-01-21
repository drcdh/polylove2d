local socket = require("socket")

local hub = require("display.hub")

local fullscreen = false

local address, port = "127.0.0.1", 23114
local udp

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
    WINDOW_W, WINDOW_H = desktop_w, desktop_h
    love.window.setMode(WINDOW_W, WINDOW_H, { fullscreen = true, display = display })
    print("Starting fullscreen")
  else
    WINDOW_W, WINDOW_H = desktop_w / 2, desktop_h / 2
    love.window.setMode(WINDOW_W, WINDOW_H, { fullscreen = false })
    print(string.format("Starting window with dimensions %d x %d", WINDOW_W, WINDOW_H))
  end
  math.randomseed(os.time())
  CID = args[2] or ("Player" .. tostring(math.random(1000, 9999)))
  udp = socket.udp()
  udp:settimeout(0)
  udp:setpeername(address, port)
  send("connect", CID)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit", 0)
  else
    send("input", string.format("%s,%s", key, "pressed"))
  end
end

function love.keyreleased(key)
  send("input", string.format("%s,%s", key, "released"))
end

function love.draw()
  hub.draw()
end

function love.update(dt)
  repeat
    local data, msg = udp:receive()
    if data then
      print(string.format("> %s", data))
      hub.update(data)
    elseif msg == "connection refused" then
      udp = nil
    elseif msg ~= "timeout" then
      error("Network error: " .. tostring(msg))
    end
  until not data

  hub.love_update(dt)
end

function love.quit()
  send("disconnect")
end

