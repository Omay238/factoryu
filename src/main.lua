function love.load()
    x, y = 0, 0
    s = 64
    m = 3

    cur_rot = 0
    cur_machine = "miner"

    world = {}

    imgs = {
        miner = love.graphics.newImage("assets/miner.png"),
        conveyor = love.graphics.newImage("assets/conveyor.png")
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

function love.keypressed(key, scancode, isrepeat)
    if key == "q" and isrepeat == false then
        cur_rot = cur_rot - 1
    end
    if key == "e" and isrepeat == false then
        cur_rot = cur_rot + 1
    end

    if cur_rot == -1 then cur_rot = 3 end
    if cur_rot == 4 then cur_rot = 0 end
end

function love.draw()
    love.graphics.translate(-x, -y)
    love.graphics.setBackgroundColor(0.45, 0.45, 0.5)
    love.graphics.setColor(1, 1, 1, 1)

    local min_scale = -1
    local max_scale = math.max(
        love.graphics.getHeight(),
        love.graphics.getWidth()
    ) / s + 1
    for i = -1, max_scale do
        local xoff, yoff = math.floor(x / s) * s, math.floor(y / s) * s
        love.graphics.line(
            i * s + xoff,
            min_scale + yoff,
            i * s + xoff,
            max_scale * s + yoff
        )
        love.graphics.line(
            min_scale + xoff,
            i * s + yoff,
            max_scale * s + xoff,
            i * s + yoff
        )
    end

    for _, machine in ipairs(world) do
        love.graphics.draw(
            imgs[machine.machine],
            (machine.x * s) + s / 2,
            (machine.y * s) + s / 2,
            machine.rot * math.pi / 2,
            s / 256,
            s / 256,
            128,
            128
        );
    end

    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.draw(
        imgs[cur_machine],
        math.floor((love.mouse.getX() + x) / s) * s + s / 2,
        math.floor((love.mouse.getY() + y) / s) * s + s / 2,
        cur_rot * math.pi / 2,
        s / 256,
        s / 256,
        128,
        128
    );

    if love.mouse.isDown(1) then
        table.insert(world, {
            x = math.floor((love.mouse.getX() + x) / s),
            y = math.floor((love.mouse.getY() + y) / s),
            rot = cur_rot,
            machine = cur_machine
        })
    end
    if love.mouse.isDown(2) then
        for idx, machine in ipairs(world) do
            if machine.x == math.floor((love.mouse.getX() + x) / s) and machine.y == math.floor((love.mouse.getY() + y) / s) then
                table.remove(world, idx)
            end
        end
    end
end
