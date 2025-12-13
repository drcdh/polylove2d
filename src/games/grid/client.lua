local grid = {}

grid.common = require "games.grid.common"

function grid.process_input(keyboard, player_state, dt)
    local dx, dy = 0, 0
    if love.keyboard.isDown('up') then dy = dy - 1 end
    if love.keyboard.isDown('down') then dy = dy + 1 end
    if love.keyboard.isDown('left') then dx = dx - 1 end
    if love.keyboard.isDown('right') then dx = dx + 1 end
    if dx ~= 0 or dy ~= 0 then
        return string.format("move:%s,%d,%d", player_state.name, dx, dy)
    end
    return nil
end

function grid.draw(game_state, player_state)
    local grid_size = game_state.size
    local h, w = love.graphics.getHeight(), love.graphics.getWidth()
    local dh, dw = h / grid_size, w / grid_size
    for _x = dw, w, dw do love.graphics.line(_x, 0, _x, h) end
    for _y = dh, h, dh do love.graphics.line(0, _y, w, _y) end
    for n, p in pairs(game_state.players) do
        love.graphics.print(n, dw * (p.x + 0.5), dh * (p.y + 0.5))
    end
end

return grid
