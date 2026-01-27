local timer = require("timer")

local t = timer.new(10)

assert(nil == t:update(5), "expect status nil after partial clock. Got" .. (t:status() or "nil|false"))
assert(0 == t:update(5), "expect 0 after immediate time. Got " .. t:status())
assert(1 == t:update(5), "expect 1 after subsequent update. Got" .. t:status())
assert(2 == t:update(5), "expect 2 after second subsequent update. Got" .. t:status())

t:reset()
assert(nil == t:status(), "expect status nil after reset")

assert(nil == t:update(5), "expect status nil after partial clock. Got" .. (t:status() or "nil|false"))
assert(0 == t:update(5), "expect 0 after immediate time. Got " .. t:status())
assert(1 == t:update(5), "expect 1 after subsequent update. Got" .. t:status())
assert(2 == t:update(5), "expect 2 after second subsequent update. Got" .. t:status())

