local smash = { mod = "smash", name = "Smash" }

local STATE = require("games.smash.client.display._states")

local util = require("util")

SmashClient = {}
SmashClient.__index = SmashClient

function SmashClient:new()
  local o = { mod = smash.mod, name = smash.name, playing = true }
  setmetatable(o, self)
  return o
end

function SmashClient:draw() if self.state then STATE[self.state.macrostate].draw(self) end end

function SmashClient:update(my_cid, update, param)
  if update == "state" then
    self.state = util.decode(param)
  else -- if self.playing then
    STATE[self.state.macrostate].update(self, my_cid, update, param)
  end
end

function SmashClient:love_update(dt) if self.state then STATE[self.state.macrostate].love_update(self, dt) end end

function smash.new() return SmashClient:new() end

return smash

