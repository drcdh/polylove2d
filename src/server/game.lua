GameServer = {}
GameServer.__index = GameServer

function GameServer:new(mod, gid)
  local o = { cids = {}, mod = mod, gid = gid or string.format("G%04d", math.random(9999)), t = UTIL.clock() }
  o.__macrostate_func = require("games." .. mod .. ".server.state")
  o.__macrostate_func["__START__"].initialize(o)
  setmetatable(o, self)
  return o
end

function GameServer:STATE(macrostate)
  return self.__macrostate_func[macrostate or self.state.macrostate]
end

function GameServer:has_player(cid)
  return self.cids[cid] ~= nil
end

function GameServer:is_playing(cid)
  if self:STATE().is_playing(cid) then
    return true -- player is in-game
  elseif self.cids[cid] then
    return false -- player is spectating
  end
  return nil -- player is in hub or in another game
end

function GameServer:num_players()
  local n = 0
  for _, _ in pairs(self.cids) do
    n = n + 1
  end
  return n
end

function GameServer:active()
  return self:num_players() > 0
end

function GameServer:send_all(msg)
  for cid, _ in pairs(self.cids) do
    SEND(cid, msg)
  end
end

function GameServer:join(cid)
  self.cids[cid] = true
  SEND(cid, "state:" .. UTIL.encode(self.state))
  self:STATE().join(self, cid)
end

function GameServer:leave(cid)
  SEND(cid, string.format("hub-return:%s", cid))
  self:STATE().leave(self, cid)
  self.cids[cid] = nil
end

function GameServer:process_input(cid, button, button_state)
  self:STATE().process_input(self, cid, button, button_state)
end

function GameServer:update()
  local dt = UTIL.clock() - self.t
  self.t = UTIL.clock()
  self:STATE().update(self, dt)
  if self.next_macrostate then
    print(string.format("%s switching state from %s to %s", self.gid, self.state.macrostate, self.next_macrostate))
    self:STATE(self.next_macrostate).initialize(self)
    self:send_all("state:" .. UTIL.encode(self.state))
    self.next_macrostate = nil
  end
end

return function(mod)
  return GameServer:new(mod, gid)
end

