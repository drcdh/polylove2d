local ordtab = require("ordtab")

local my_ot = ordtab.new({ abc = 123, xyz = 987, efg = "asdf" })

for i, k, v in my_ot:iter() do print(i, k, v) end

print(my_ot:len())

local empty = ordtab.new()
for i, k, v in empty:iter() do print(i, k, v) end
print(empty:len())

