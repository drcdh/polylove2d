local GAME = require("games.grid.states.game")
local STAGES = require("games.grid.states.stages")

GridStage = {}
GridStage.__index = GridStage

function GridStage:new(cids)
  local o = { state = { state = "__STAGE__", players = {} }, private = { selection = nil } }

  for _i, cid in ipairs(cids) do o.state.players[cid] = { selection = 1 } end

  setmetatable(o, self)
  return o
end

function GridStage:join(cid)
  self.send(cid, "state:" .. util.encode(self.state))
  self:send_all(string.format("setplayer:%s,%s", cid, util.encode(self.state.players[cid])))
  self.state.players[cid] = 1
end

function GridStage:leave(cid)
  self.state.players[cid] = nil
  self:send_all(string.format("leave:%s", cid))
end

function GridStage:process_input(cid, button, button_state)
  self.selection = STAGES.LIST[self.state.players[cid].selection]
end

function GridStage:update()
  if self.selection then return GAME(self.state.players, self.selection) end
end

return function() return GridStage:new() end

