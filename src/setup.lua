local version = _VERSION:match("%d+%.%d+")

print("Running setup.lua with _VERSION=".. version)

package.path = 'lua_modules/share/lua/' .. version ..
  '/?.lua;lua_modules/share/lua/' .. version ..
  '/?/init.lua;' .. package.path

package.cpath = 'lua_modules/lib/lua/' .. version ..
  '/?.so;' .. package.cpath

