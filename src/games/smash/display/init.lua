local smash = { mod = "smash", name = "Smash" }

local STATE = require("games.smash.display.states")

local util = require("util")

SmashClient = {}
SmashClient.__index = SmashClient

function SmashClient:new()
  local o = { mod = smash.mod, name = smash.name }
  setmetatable(o, self)
  return o
end

function SmashClient:draw()
  if self.macrostate then
    STATE[self.macrostate].draw()
  else
    print("draw called but no macrostate")
  end
end

function SmashClient:update(update, param)
  if update == "state" then
    local server_state = util.decode(param)
    self.macrostate = server_state.macrostate
    STATE[self.macrostate].initialize(server_state)
    return true
  elseif self.macrostate then -- if self.playing then
    return STATE[self.macrostate].update(update, param)
  else
    print("update other than state but no macrostate")
  end
end

function SmashClient:love_update(dt)
  if self.macrostate then
    STATE[self.macrostate].love_update(dt)
  else
    print("love_update called but no macrostate")
  end
end

function smash.new()
  return SmashClient:new()
end

return smash

