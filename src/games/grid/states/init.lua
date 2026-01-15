local GAME = require("games.grid.states.game")
local STAGES = require("games.grid.states.stage_data")

local util = require("util")

GridStage = {}
GridStage.__index = GridStage

function GridStage:new(cids, send, send_all)
  local o = { state = { state = "__STAGE__", players = {} }, selection = nil, send=send, send_all=send_all }

  for cid, _ in pairs(cids) do o.state.players[cid] = { selection = 1 } end

  print("new GridStage: " .. util.encode(o.state))
  setmetatable(o, self)
  return o
end

function GridStage:join(cid)
  self.send(cid, "state:" .. util.encode(self.state))
  self.send_all(string.format("setplayer:%s,%s", cid, self.state.players[cid]))
  self.state.players[cid] = 1
end

function GridStage:leave(cid)
  self.state.players[cid] = nil
  self.send_all(string.format("leave:%s", cid))
end

function GridStage:process_input(cid, button, button_state)
  self.selection = STAGES.LIST[self.state.players[cid].selection]
end

function GridStage:update(dt)
  if self.selection then
    print("selecting stage " .. self.selection)
    return GAME(self.state.players, self.selection)
  end
end

return function(cids) return GridStage:new(cids) end

