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

