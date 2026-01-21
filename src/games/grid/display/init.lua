local grid = { mod = "grid", name = "Grid" }

local STATE = require("games.grid.display.states")

local util = require("util")

GridClient = {}
GridClient.__index = GridClient

function GridClient:new(cid)
  local o = { mod = grid.mod, name = grid.name, cid = cid, playing = true }
  setmetatable(o, self)
  return o
end

function GridClient:draw()
  if self.state then
    STATE[self.state.macrostate].draw(self)
  end
end

function GridClient:update(update, param)
  if update == "state" then
    local server_state = util.decode(param)
    self.state = STATE[server_state.macrostate].initialize(server_state)
  else -- if self.playing then
    STATE[self.state.macrostate].update(self, update, param)
  end
end

function GridClient:love_update(dt)
  if self.state then
    STATE[self.state.macrostate].love_update(self, dt)
  end
end

function grid.new(cid)
  return GridClient:new(cid)
end

return grid
