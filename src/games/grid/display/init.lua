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
  if self.macrostate then
    STATE[self.macrostate].draw(self)
  else
    print("draw called but no macrostate")
  end
end

function GridClient:update(update, param)
  if update == "state" then
    local server_state = util.decode(param)
    self.macrostate = server_state.macrostate
    self.state = STATE[self.macrostate].initialize(server_state)
    return true
  elseif self.macrostate then -- if self.playing then
    return STATE[self.macrostate].update(self, update, param)
  else
    print("update other than state but no macrostate")
  end
end

function GridClient:love_update(dt)
  if self.macrostate then
    STATE[self.macrostate].love_update(self, dt)
  else
    print("love_update called but no macrostate")
  end
end

function grid.new(cid)
  return GridClient:new(cid)
end

return grid
