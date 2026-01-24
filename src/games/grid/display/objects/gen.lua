return function(_init, _draw)
  local Object = {}
  Object.__index = Object
  function Object:new(...)
    local o = _init(...)
    setmetatable(o, self)
    return o
  end
  function Object:_wrap()
    local rx, ry = 0, 0
    if self.i < 0 then
      rx = 1
    end
    if self.i > SIZE.w - 1 then
      rx = -1
    end
    if self.j < 0 then
      ry = 1
    end
    if self.j > SIZE.h - 1 then
      ry = -1
    end
    return rx, ry
  end
  Object._draw = _draw
  function Object:draw()
    self:_draw()
    local rx, ry = self:_wrap()
    if rx ~= 0 then
      love.graphics.push()
      love.graphics.translate(rx * FRAME_W, 0)
      self:_draw()
      love.graphics.pop()
    end
    if ry ~= 0 then
      love.graphics.push()
      love.graphics.translate(0, ry * FRAME_H)
      self:_draw()
      love.graphics.pop()
    end
    if rx ~= 0 and ry ~= 0 then
      love.graphics.push()
      love.graphics.translate(rx * FRAME_W, ry * FRAME_H)
      self:_draw()
      love.graphics.pop()
    end
  end
  function Object:update(dt)
    -- if self._tw and self._tw:update(dt) then self._mouth, self._tw = 0, nil end
    if self._tw and self._tw:update(dt) then
      self._tw:reset()
    end
  end
  return Object
end

