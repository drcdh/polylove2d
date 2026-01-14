rockspec_format = "3.0"
package = "polylove2d"
version = "dev-1"
source = {
  url = "git+https://github.com/drcdh/polylove2d.git"
}
description = {
  homepage = "https://github.com/drcdh/polylove2d",
  license = "*** please specify a license ***"
}
dependencies = {
  "dkjson ~> 2.8",
  "lua ~> 5.1",
  "luasocket ~> 3.1",
  "tween ~> 2.1",
}
build = {
  type = "builtin",
  modules = {
    ["client.display.main"] = "src/client/display/main.lua",
    ["client.input.conf"] = "src/client/input/conf.lua",
    ["client.input.keyboard.main"] = "src/client/input/keyboard/main.lua",
    ["client.input.main"] = "src/client/input/main.lua",
    ["games.grid.client"] = "src/games/grid/client.lua",
    ["games.grid.face"] = "src/games/grid/face.lua",
    ["games.grid.objects"] = "src/games/grid/objects.lua",
    ["games.grid.server"] = "src/games/grid/server.lua",
    ["games.smash.client"] = "src/games/smash/client.lua",
    ["games.smash.server"] = "src/games/smash/server.lua",
    ["hub.client"] = "src/hub/client.lua",
    ["hub.server"] = "src/hub/server.lua",
    inputs = "src/inputs.lua",
    ordtab = "src/ordtab.lua",
    ordtab_test = "src/ordtab_test.lua",
    ["server.main"] = "src/server/main.lua",
    util = "src/util.lua",
    util_test = "src/util_test.lua"
  }
}
