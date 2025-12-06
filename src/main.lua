function love.load()
    x, y = 0, 0
    s = 64
    m = 3
end

function love.update()
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        y = y - m
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        y = y + m
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        x = x - m
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        x = x + m
    end
end

function love.draw()
    love.graphics.translate(-x, -y)
    local min_scale = -1
    local max_scale = math.max(love.graphics.getHeight(), love.graphics.getWidth()) / s + 1
    for i = -1, max_scale do
        local xoff, yoff = math.floor(x / s) * s, math.floor(y / s) * s
        love.graphics.line(i * s + xoff, min_scale + yoff, i * s + xoff, max_scale * s + yoff)
        love.graphics.line(min_scale + xoff, i * s + yoff, max_scale * s + xoff, i * s + yoff)
    end
end
