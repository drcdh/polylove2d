GameDisplay = {}
GameDisplay.__index = GameDisplay

function GameDisplay:new(mod)
  local o = { state = require("games." .. mod .. ".display.state") }
  setmetatable(o, self)
  return o
end

function GameDisplay:draw()
  if self.macrostate then
    self.state[self.macrostate].draw()
  else
    print("draw called but no macrostate")
  end
end

function GameDisplay:update(update, param)
  if update == "state" then
    local server_state = UTIL.decode(param)
    self.macrostate = server_state.macrostate
    self.state[self.macrostate].initialize(server_state)
    return true
  elseif self.macrostate then -- if self.playing then
    return self.state[self.macrostate].update(update, param)
  else
    print("update other than state but no macrostate")
  end
end

function GameDisplay:love_update(dt)
  if self.macrostate then
    self.state[self.macrostate].love_update(dt)
  else
    print("love_update called but no macrostate")
  end
end

return function(mod)
  return GameDisplay:new(mod)
end

