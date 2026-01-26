local timer = {}

local Timer = {}
local Timer_mt = { __index = Timer }

function Timer:status()
  return self.check
end

function Timer:set(clock)
  assert(type(clock) == "number", "clock must be a positive number")

  self.clock = clock

  if self.clock >= self.duration then
    self.check = (self.check or -1) + 1
  end

  return self:status()
end

function Timer:reset()
  self.check = nil
  self.clock = 0
end

function Timer:update(dt)
  assert(type(dt) == "number", "dt must be a number")
  return self:set(self.clock + dt)
end

function timer.new(duration)
  return setmetatable({ clock = 0, duration = duration }, Timer_mt)
end

return timer

