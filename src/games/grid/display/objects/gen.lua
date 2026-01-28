return function(_init, _draw, _move)
  local Object = {}
  Object.__index = Object
  function Object:new(i, j, ...)
    local o = { i = i, j = j, f = FACE.RIGHT, tweens = {}, repeated_tweens = {} }
    _init(o, ...)
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
  Object._move = _move
  function Object:move(i, j, i_, j_, t)
    self.i = i
    self.j = j
    self.tweens.mv = TWEEN.new(tonumber(t), self, { i = i_, j = j_ })
    if self._move then
      self:_move(t)
    end
  end
  function Object:update(dt)
    for _, _tw in pairs(self.tweens) do
      _tw:update(dt)
    end
    for _, _tw in pairs(self.repeated_tweens) do
      if _tw:update(dt) then
        _tw:reset()
      end
    end
  end
  return Object
end

