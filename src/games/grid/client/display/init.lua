local grid = { mod = "grid", name = "Grid" }

local STATE = require("games.grid.client.display._states")

local util = require("util")

local W, H

GridClient = {}
GridClient.__index = GridClient

function GridClient:new()
  local o = { mod = grid.mod, name = grid.name, playing = true }
  setmetatable(o, self)
  return o
end

function GridClient:draw() if self.state then STATE[self.state.macrostate].draw(self) end end

function GridClient:update(my_cid, update, param)
  if update == "state" then
    local server_state = util.decode(param)
    self.state = STATE[server_state.macrostate].initialize(server_state)
  else -- if self.playing then
    STATE[self.state.macrostate].update(self, my_cid, update, param)
  end
end

function GridClient:love_update(dt) if self.state then STATE[self.state.macrostate].love_update(self, dt) end end

function grid.new() return GridClient:new() end

return grid
