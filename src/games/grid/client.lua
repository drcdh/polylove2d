local grid = {}

local util = require("util")

local game_state = nil

function grid.process_input(keyboard, player_name, dt)
  local di, dj = 0, 0
  if love.keyboard.isDown("up") then dj = dj - 1 end
  if love.keyboard.isDown("down") then dj = dj + 1 end
  if love.keyboard.isDown("left") then di = di - 1 end
  if love.keyboard.isDown("right") then di = di + 1 end
  if di ~= 0 or dj ~= 0 then return string.format("trymove:%s,%d,%d", player_name, di, dj) end
  return nil
end

function grid.process_update(update, data)
  print(string.format("Processing %s:%s", update, data))
  if update == "state" then
    game_state = util.decode(data)
  elseif update == "move" then
    local player_name, i, j = data:match("^(%S-),(%-?[%d.e]+),(%-?[%d.e]+)")
    game_state.players[player_name].i = i
    game_state.players[player_name].j = j
  elseif update == "newplayer" then
    local player_name, i, j = data:match("^(%S-),(%-?[%d.e]+),(%-?[%d.e]+)")
    game_state.players[player_name] = { i = i, j = j }
    game_state.player_scores[player_name] = 0
  elseif update == "removepit" then
    local i, j = data:match("^(%-?[%d.e]+),(%-?[%d.e]+)")
    local l = i + game_state.size * j + 1
    game_state.pits[l] = false
  elseif update == "removeplayer" then
    local player_name = data
    game_state.players[player_name] = nil
    game_state.player_scores[player_name] = nil
  elseif update == "score" then
    local player_name = data
    game_state.player_scores[player_name] = game_state.player_scores[player_name] + 1
  else
    print(string.format("Unrecognized update '%s'", update))
  end
  print("games/grid/client.lua -- State is", util.encode(game_state))
end

function grid.draw()
  local h, w = love.graphics.getHeight(), love.graphics.getWidth()
  if game_state then
    local grid_size = game_state.size
    local dh, dw = h / grid_size, w / grid_size
    for _x = dw, w, dw do love.graphics.line(_x, 0, _x, h) end
    for _y = dh, h, dh do love.graphics.line(0, _y, w, _y) end
    do
      local _x, _y = dw / 2, dh / 2
      for _i = 0, grid_size * grid_size - 1 do
        if _i > 0 then
          if _i % grid_size == 0 then
            _x = dw / 2
            _y = _y + dh
          else
            _x = _x + dw
          end
        end
        if game_state.walls[_i + 1] then
          -- print(string.format("drawing wall at %d", _i))
          love.graphics.setColor(.3, .4, .5)
          love.graphics.rectangle("fill", _x - .9 * dw / 2, _y - .9 * dh / 2, .9 * dw, .9 * dh)
        elseif game_state.pits[_i + 1] then
          -- print(string.format("drawing pit at %d", _i))
          love.graphics.setColor(.8, .8, .8)
          love.graphics.circle("fill", _x, _y, .2 * dw)
        end
      end
    end
    do
      love.graphics.setColor(0, .1, .3)
      love.graphics.rectangle("fill", 10, 10, 100, 20 * (1 + game_state.num_players))
      local _y = 20 -- pixel position for score
      love.graphics.setColor(1, 1, 1)
      for player_name, player in pairs(game_state.players) do
        love.graphics.print(player_name, dw * (player.i + 0.5), dh * (player.j + 0.5))
        love.graphics.print(string.format("%s: %d", player_name,
                                          game_state.player_scores[player_name]), 20, _y)
        _y = _y + 20
      end
    end
  else
    love.graphics.print("NO GAME_STATE", w / 2, h / 2)
  end
end

return grid
