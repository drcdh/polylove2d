local smash = { mod = "smash", name = "Smash", description = "Smash button!" }

local INPUT = require("inputs")

local util = require("util")

SmashServer = {}
SmashServer.__index = SmashServer

function SmashServer:new(gid, send)
  local o = {
    state = { scores = {} },
    gid = gid or string.format("G%04d", math.random(9999)),
    mod = smash.mod,
    name = smash.name,
    send = send,
  }
  setmetatable(o, self)
  return o
end

function SmashServer:has_player(cid) if self.state.scores[cid] then return true end end

function SmashServer:num_players()
  local n = 0
  for _, _ in pairs(self.state.scores) do n = n + 1 end
  return n
end

function SmashServer:active() return self:num_players() > 0 end

function SmashServer:send_all(msg) for cid, _ in pairs(self.state.scores) do self.send(cid, msg) end end

function SmashServer:join(cid)
  self.state.scores[cid] = 0
  self:send_all(string.format("setscore:%s,%d", cid, 0))
end

function SmashServer:leave(cid)
  self:send_all(string.format("leave:%s", cid))
  self.state.scores[cid] = nil
end

function SmashServer:process_input(cid, button, button_state)
  if button == INPUT.ENTER and button_state == "pressed" then
    self.state.scores[cid] = self.state.scores[cid] + 1
    self:send_all(string.format("setscore:%s,%d", cid, self.state.scores[cid]))
  elseif button == INPUT.BACK and button_state == "released" then
    self:leave(cid)
  end
end

smash.new = function(gid, send) return SmashServer:new(gid, send) end
return smash

