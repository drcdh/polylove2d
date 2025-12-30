local function _sort(t)
  local s = {}
  for k in pairs(t) do s[#s + 1] = k end
  table.sort(s)
  return s
end

OrderedTable = {}
OrderedTable.__index = OrderedTable

function OrderedTable:new(t)
  -- if not t then t = {} end
  local o = { _s = _sort(t or {}), _t = t or {} }
  setmetatable(o, self)
  return o
end

function OrderedTable:_sort() self._s = _sort(self._t) end

function OrderedTable:len() return #self._s end

function OrderedTable:add(k, v)
  self._t[k] = v
  self:_sort()
end

function OrderedTable:ikey(i)
  local k = self._s[i]
  return k
end

function OrderedTable:get(k)
  local v = self._t[k]
  return v
end

function OrderedTable:iget(i)
  local k = self._s[i]
  local v = self._t[k]
  return k, v
end

function OrderedTable:remove(k)
  local v = self._t[k]
  self._t[k] = nil
  self:_sort()
  return v
end

function OrderedTable:iremove(i)
  local v = self._t[self._s[i]]
  self._t[self._s[i]] = nil
  self:_sort()
  return v
end

local function _iter(ot, i)
  i = i + 1
  local k = ot._s[i]
  local v = ot._t[k]
  if k then return i, k, v end
end

function OrderedTable:iter() return _iter, self, 0 end

function OrderedTable:filter(pass_f)
  local np, nf = 0, 0
  local new_t = {}
  for _, k in ipairs(self._s) do
    if pass_f(self._t[k]) then
      new_t[k] = self._t[k]
      np = np + 1
    else
      nf = nf + 1
    end
  end
  self._t = new_t
  self:_sort()
  return np, nf
end

return { new = function(t) return OrderedTable:new(t) end }

