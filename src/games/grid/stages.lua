local HUMDRUM = "Humdrum"
local ASDF = "16x12"
local BLAH = "16x9"
local TINY = "tiny"

return {
  LIST = { HUMDRUM, ASDF, BLAH, TINY },
  DATA = {
    [HUMDRUM] = {
      w = 10,
      h = 10,
      walls = {
        "xx xxxx xx", --  1
        "x   xx   x", --  2
        "x  xxxx  x", --  3
        "    pp    ", --  4
        "x  xxxx  x", --  5
        "x  xxxx  x", --  6
        "    pp    ", --  7
        "x  xxxx  x", --  8
        "x   xx   x", --  9
        "xx xxxx xx", -- 10
      },
    },
    [ASDF] = {
      w = 16,
      h = 12,
      walls = {
        --      vv      --
        "xxx xxxxxxxx xxx", --  1
        "x  p   xx   p  x", --  2
        "xxx xx xx xx xxx", --  3
        "x      xx      x", --  4
        "  xxxx    xxxx  ", --  5
        "x      xx      x", --  6
        "x      xx      x", --  7
        "  xxxx    xxxx  ", --  8
        "x      xx      x", --  9
        "xxx xx xx xx xxx", -- 10
        "x  p   xx   p  x", -- 11
        "xxx xxxxxxxx xxx", -- 12
        --      ^^      --
      },
    },
    [BLAH] = {
      w = 16,
      h = 9,
      walls = {
        --      vv      --
        "xxx xxxxxxxx xxx", --  1
        "x  p   xx   p  x", --  2
        "xxx xx xx xx xxx", --  3
        "x      xx      x", --  4
        "  xxxx    xxxx  ", --  5
        "x      xx      x", --  6
        "xxx xx xx xx xxx", --  7
        "x  p   xx   p  x", --  8
        "xxx xxxxxxxx xxx", --  9
        --      ^^      --
      },
    },
    [TINY] = {
      w = 5,
      h = 5,
      walls = {
        "xx xx", -- 1
        "xp px", -- 2
        "     ", -- 3
        "xp px", -- 4
        "xx xx", -- 5
      },
    },
  },
}

