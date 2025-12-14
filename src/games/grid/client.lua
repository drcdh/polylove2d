local grid = {}

grid.common = require "games.grid.common"

function grid.process_input(keyboard, player_state, dt)
    local di, dj = 0, 0
    if love.keyboard.isDown('up') then dj = dj - 1 end
    if love.keyboard.isDown('down') then dj = dj + 1 end
    if love.keyboard.isDown('left') then di = di - 1 end
    if love.keyboard.isDown('right') then di = di + 1 end
    if di ~= 0 or dj ~= 0 then
        return string.format("move:%s,%d,%d", player_state.name, di, dj)
    end
    return nil
end

function grid.draw(game_state, player_state)
    local grid_size = game_state.size
    local h, w = love.graphics.getHeight(), love.graphics.getWidth()
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
                love.graphics.rectangle("fill", _x - .9 * dw / 2,
                                        _y - .9 * dh / 2, .9 * dw, .9 * dh)
            elseif game_state.pits[_i + 1] then
                -- print(string.format("drawing pit at %d", _i))
                love.graphics.setColor(.8, .8, .8)
                love.graphics.circle("fill", _x, _y, .2 * dw)
            end
        end
    end
    love.graphics.setColor(1, 1, 1)
    for n, player in pairs(game_state.players) do
        love.graphics.print(n, dw * (player.i + 0.5), dh * (player.j + 0.5))
    end
end

return grid
