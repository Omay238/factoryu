function love.load()
    x, y = 0, 0
    s = 64
    m = 3

    world = {
        {
            x = 0,
            y = 0,
            machine = "miner"
        }
    }

    imgs = {
        miner = love.graphics.newImage("assets/miner.png")
    }
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
    love.graphics.setBackgroundColor(0.45, 0.45, 0.5)
    love.graphics.setColor(1, 1, 1, 1)

    local min_scale = -1
    local max_scale = math.max(love.graphics.getHeight(), love.graphics.getWidth()) / s + 1
    for i = -1, max_scale do
        local xoff, yoff = math.floor(x / s) * s, math.floor(y / s) * s
        love.graphics.line(i * s + xoff, min_scale + yoff, i * s + xoff, max_scale * s + yoff)
        love.graphics.line(min_scale + xoff, i * s + yoff, max_scale * s + xoff, i * s + yoff)
    end

    for _, machine in ipairs(world) do
        love.graphics.draw(imgs[machine["machine"]], machine["x"] * s, machine["y"] * s, 0, s / 256);
    end

    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle("fill", math.floor((love.mouse.getX() + x) / s) * s,
        math.floor((love.mouse.getY() + y) / s) * s, s, s)
end
