local util = require("util")

SmashClient = {}
SmashClient.__index = SmashClient

function SmashClient:new()
  local o = { state = { scores = {} } }
  setmetatable(o, self)
  return o
end

function SmashClient:draw(love, my_cid)
  local i = 0
  for name, score in pairs(self.state.scores) do
    love.graphics.print(string.format("%d  -  %s", score, name), 300, 300 + 20 * i)
    i = i + 1
  end
end

function SmashClient:update(my_cid, update, param)
  if update == "join" then
    local cid = param
    self.state.scores[cid] = 0
  elseif update == "state" then
    self.state = util.decode(param)
  elseif update == "setscore" then
    local cid, score = param:match("^(%S-),(%S*)")
    self.state.scores[cid] = tonumber(score)
  elseif update == "leave" then
    local cid = param
    self.state.scores[cid] = nil
  end
end

return { new = function() return SmashClient:new() end }

