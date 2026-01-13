local KEYBOARD = "keyboard"
local F710 = "Logitech Gamepad F710"
local F310 = "Logitech Gamepad F310"

local type = KEYBOARD

local joystick

function love.load(args)
  local joysticks = love.joystick.getJoysticks()
  for _, j in ipairs(joysticks) do
    print(j:getName())
    print(j:getGamepadMappingString())
  end

  if args[1] then 

  love.window.setPosition(100, 10, 2)
  love.window.setFullscreen(true)
  end
end

-- function love.focus(f)
--   if f then print("Got focus") else
--   print("Lost focus") end
-- end

function love.gamepadpressed(j, b)
  print(j:getName(), b)
end

function love.keypressed(key) if key == "escape" then love.event.push("quit", 0) else print(key) end end

-- function love.draw()
-- end

-- function love.update(dt) end
