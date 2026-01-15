local smash = { mod = "smash", name = "Smash" }

local util = require("util")

SmashClient = {}
SmashClient.__index = SmashClient

function SmashClient:new()
  local o = { mod = smash.mod, name = smash.name, state = { scores = {} }, playing = true }
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
  if update == "state" then
    self.state = util.decode(param)
  elseif update == "setscore" then
    local cid, score = param:match("^(%S-),(%S*)")
    self.state.scores[cid] = tonumber(score)
  elseif update == "leave" then
    local cid = param
    self.state.scores[cid] = nil
    if cid == my_cid then self.playing = false end
  end
end

function SmashClient:love_update(dt) end

function smash.new() return SmashClient:new() end

return smash

