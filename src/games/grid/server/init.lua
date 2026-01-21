local grid = { mod = "grid", name = "Grid", description = "Eat dots!" }

local STATE = require("games.grid.server.states")

local util = require("util")

GridServer = {}
GridServer.__index = GridServer

function GridServer:new(gid, send)
  local o = {
    cids = {},
    state = STATE["__START__"].new(),
    gid = gid or string.format("G%04d", math.random(9999)),
    mod = grid.mod,
    name = grid.name,
    send = send,
    t = util.clock(),
  }
  setmetatable(o, self)
  return o
end

function GridServer:has_player(cid)
  if self.state.players[cid] then
    return true
  end
end

function GridServer:num_players()
  local n = 0
  for _, _ in pairs(self.state.players) do
    n = n + 1
  end
  return n
end

function GridServer:active()
  return self:num_players() > 0
end

function GridServer:send_all(msg)
  for cid, _ in pairs(self.state.players) do
    self.send(cid, msg)
  end
end

function GridServer:join(cid)
  self.cids[cid] = true
  self.send(cid, "state:" .. util.encode(self.state))
  STATE[self.state.macrostate].join(self, cid)
end

function GridServer:leave(cid)
  STATE[self.state.macrostate].leave(self, cid)
  self.cids[cid] = nil
end

function GridServer:process_input(cid, button, button_state)
  STATE[self.state.macrostate].process_input(self, cid, button, button_state)
end

function GridServer:update()
  local dt = util.clock() - self.t
  self.t = util.clock()
  STATE[self.state.macrostate].update(self, dt)
  if self.next_macrostate then
    print(string.format("%s switching state from %s to %s", self.gid, self.state.macrostate, self.next_macrostate))
    self.state = STATE[self.next_macrostate].new(self.state)
    self:send_all("state:" .. util.encode(self.state))
    self.next_macrostate = nil
  end
end

function grid.new(gid, send)
  return GridServer:new(gid, send)
end

return grid

