local srcdir = os.getenv("PWD")
local version = _VERSION:match("%d+%.%d+")

print(string.format("Running setup.lua with _VERSION=%s PWD=%s", version, srcdir))

-- LuaFormatter off
package.path  = string.format("%s/../lua_modules/share/lua/%s/?.lua;", srcdir, version)
             .. string.format("%s/../lua_modules/share/lua/%s/?/init.lua;", srcdir, version)
             .. package.path

package.cpath = string.format("%s/../lua_modules/lib/lua/%s/?.so;", srcdir, version)
             .. package.cpath
-- LuaFormatter on

