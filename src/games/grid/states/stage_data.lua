local HUMDRUM = "Humdrum"

return {
  LIST = { HUMDRUM },
  DATA = {
    [HUMDRUM] = {
      w = 10,
      h = 10,
      -- LuaFormatter off
    walls = "xx xxxx xx" .. --  1
            "x   xx   x" .. --  2
            "x  xxxx  x" .. --  3
            "    pp    " .. --  4
            "x  xxxx  x" .. --  5
            "x  xxxx  x" .. --  6
            "    pp    " .. --  7
            "x  xxxx  x" .. --  8
            "x   xx   x" .. --  9
            "xx xxxx xx"    -- 10
    -- LuaFormatter on
    },
  },
}

