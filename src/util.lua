local util = {}

local dkjson = require("dkjson")
local socket = require("socket")

local TABLE = "table"

local function _update_table(t, u)
  for k, v in pairs(u) do
    if type(v) ~= TABLE then
      t[k] = v
    else
      if not t[k] then t[k] = {} end
      util.update_table(t[k], v)
    end
  end
end

function util.update_table(t, u)
  if type(t) ~= TABLE or type(u) ~= TABLE then
    print("not tables")
  else
    _update_table(t, u)
  end
end

function util.decode(s) return dkjson.decode(s) end

function util.encode(s) return dkjson.encode(s, { indent = false }) end

function util.clock() return socket.gettime() end

function util.wrap_dec(v, l, index)
  index = index or 1
  v = v - 1 - index
  if v < 0 then v = l + v end
  return v + index
end

function util.wrap_inc(v, l, index)
  index = index or 1
  v = v + 1 - index
  if v >= l then v = 0 end
  return v + index
end

return util

