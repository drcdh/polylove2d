local grid = { mod = "grid", name = "Grid", description = "Eat dots!" }

local STATE = require("games.grid.states")

local util = require("util")

GridServer = {}
GridServer.__index = GridServer

function GridServer:new(gid, send)
  local o = {
    cids = {}, -- {string: bool}
    gid = gid or string.format("G%04d", math.random(9999)),
    mod = grid.mod,
    name = grid.name,
    send = send,
    state = nil,
    t = util.clock(),
  }
  setmetatable(o, self)
  return o
end

function GridServer:has_player(cid) return self.cids[cid] end

function GridServer:num_players()
  local n = 0
  for _, _ in pairs(self.cids) do n = n + 1 end
  return n
end

function GridServer:active() return self:num_players() > 0 end

function GridServer:send_all(msg) for cid, _ in pairs(self.cids) do self.send(cid, msg) end end

function GridServer:start(cid)
  print("START GridServer " .. cid)
  self.cids[cid] = true
  self.state = STATE(self.cids)
  -- self.state:join(cid)
end

function GridServer:join(cid)
  self.cids[cid] = true
  self.state:join(cid)
end

function GridServer:leave(cid)
  self.state:leave(cid)
  self.cids[cid] = nil
end

function GridServer:process_input(cid, button, button_state)
  if self.state then self.state:process_input(cid, button, button_state) end
end

function GridServer:update()
  local dt = util.clock() - self.t
  self.t = util.clock()
  if self.state then
    local new_state = self.state:update(dt)
    if new_state ~= nil then
      print("got new state from update")
      self.state = new_state end
  else
    self.state = STATE(self.cids, self.send, self:send_all)
  end
end

function grid.new(gid, send) return GridServer:new(gid, send) end

return grid

