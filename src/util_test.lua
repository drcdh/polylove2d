local util = require("util")

local dkjson = require("dkjson")

local t = { a = 123, b = { b1 = "xyz", b2 = 987 } }

local u = { a = 321 }

local expected = { a = 321, b = { b1 = "xyz", b2 = 987 } }

print(dkjson.encode(t))

util.update_table(t, u)

print(dkjson.encode(t))

util.update_table(t, { b = { b1 = "aaaaaaaaa" } })

print(dkjson.encode(t))

util.update_table(t, {})

print(dkjson.encode(t))

local l = 10
local v = 1
assert(util.wrap_dec(v, l) == l)
assert(util.wrap_dec(v - 1, l, 0) == l - 1)
assert(util.wrap_inc(v, l) == v + 1)
assert(util.wrap_inc(v, l, 0) == v + 1)
v = l
assert(util.wrap_dec(v, l) == v - 1)
assert(util.wrap_dec(v - 1, l, 0) == v - 2)
assert(util.wrap_inc(v, l) == 1)
assert(util.wrap_inc(v - 1, l, 0) == 0)
