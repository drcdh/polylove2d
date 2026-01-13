function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit", 0)
  else
    print(string.format("%s pressed", key))
  end
end

function love.keyreleased(key) print(string.format("%s released", key)) end

