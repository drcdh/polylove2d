local face = { UP = "up", LEFT = "left", DOWN = "down", RIGHT = "right" }

function face.calc(di, dj, f)
  if di == 0 and dj == 0 then
    return f
  end
  if di < 0 and dj == 0 then
    return face.LEFT
  end
  if di > 0 and dj == 0 then
    return face.RIGHT
  end
  if di == 0 and dj < 0 then
    return face.UP
  end
  if di == 0 and dj > 0 then
    return face.DOWN
  end
  return f
end

function face.inv_calc(f)
  if f == face.UP then
    return 0, -1
  end
  if f == face.LEFT then
    return -1, 0
  end
  if f == face.DOWN then
    return 0, 1
  end
  if f == face.RIGHT then
    return 1, 0
  end
end

function face.rot(f)
  if f == face.RIGHT then
    return 0
  elseif f == face.UP then
    return math.pi / 2
  elseif f == face.LEFT then
    return math.pi
  elseif f == face.DOWN then
    return 3 * math.pi / 2
  end
end

return face

