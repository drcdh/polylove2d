local smash = { mod = "smash", name = "Smash", description = "Smash button!" }

local INPUT = require("inputs")

local STATE = require("games.smash.server._states")

local util = require("util")

SmashServer = {}
SmashServer.__index = SmashServer

function SmashServer:new(gid, send)
  local o = {
    cids = {},
    state = STATE["__START__"].new(),
    gid = gid or string.format("G%04d", math.random(9999)),
    mod = smash.mod,
    name = smash.name,
    send = send,
    t = util.clock(),
  }
  setmetatable(o, self)
  return o
end

function SmashServer:has_player(cid) if self.cids[cid] then return true end end

function SmashServer:num_players()
  local n = 0
  for _, _ in pairs(self.cids) do n = n + 1 end
  return n
end

function SmashServer:active() return self:num_players() > 0 end

function SmashServer:send_all(msg) for cid, _ in pairs(self.cids) do self.send(cid, msg) end end

function SmashServer:join(cid)
  self.cids[cid] = true
  self.send(cid, "state:" .. util.encode(self.state))
  STATE[self.state.macrostate].join(self, cid)
end

function SmashServer:leave(cid)
  STATE[self.state.macrostate].leave(self, cid)
  self.cids[cid] = nil
end

function SmashServer:process_input(cid, button, button_state)
  STATE[self.state.macrostate].process_input(self, cid, button, button_state)
end

function SmashServer:update()
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

smash.new = function(gid, send) return SmashServer:new(gid, send) end
return smash

