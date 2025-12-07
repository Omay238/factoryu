-- helper functions for managing world state

function get_world_elem(tbl, mx, my)
    for idx, machine in ipairs(tbl) do
        if machine.x == mx and machine.y == my then
            return { idx, machine }
        end
    end
    return nil
end

function get_conveyor_neighbors(tbl, mx, my)
    local neighbors = {}
    for idx, machine in ipairs(tbl) do
        if machine.x == mx and machine.y == my - 1 and machine.rot == 0 and machine.machine == "conveyor" then
            table.insert(neighbors, { idx, machine })
        end
        if machine.x == mx + 1 and machine.y == my and machine.rot == 1 and machine.machine == "conveyor" then
            table.insert(neighbors, { idx, machine })
        end
        if machine.x == mx and machine.y == my + 1 and machine.rot == 2 and machine.machine == "conveyor" then
            table.insert(neighbors, { idx, machine })
        end
        if machine.x == mx - 1 and machine.y == my and machine.rot == 3 and machine.machine == "conveyor" then
            table.insert(neighbors, { idx, machine })
        end
    end
    return neighbors
end

-- love stuff

function love.load()
    love.graphics.setBackgroundColor(0.45, 0.45, 0.5)

    x, y = 0, 0
    s = 64
    m = 3
    tick = 0

    cur_rot = 0
    cur_machine = "miner"

    world_machines = {}
    world_items = {}

    imgs = {
        miner = love.graphics.newImage("assets/miner.png"),
        conveyor = love.graphics.newImage("assets/conveyor.png"),
        smelter = love.graphics.newImage("assets/smelter.png"),
        ironore = love.graphics.newImage("assets/ironore.png"),
        ironbar = love.graphics.newImage("assets/ironbar.png")
    }

    -- aw man i don't know lua enough to fix this xd
    machines = {
        "miner",
        "conveyor",
        "smelter"
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

    if love.keyboard.isDown("1") then
        cur_machine = machines[1]
    elseif love.keyboard.isDown("2") then
        cur_machine = machines[2]
    elseif love.keyboard.isDown("3") then
        cur_machine = machines[3]
        -- elseif love.keyboard.isDown("4") then
        --     cur_machine = machines[4]
        -- elseif love.keyboard.isDown("5") then
        --     cur_machine = machines[5]
        -- elseif love.keyboard.isDown("6") then
        --     cur_machine = machines[6]
        -- elseif love.keyboard.isDown("7") then
        --     cur_machine = machines[7]
        -- elseif love.keyboard.isDown("8") then
        --     cur_machine = machines[8]
        -- elseif love.keyboard.isDown("9") then
        --     cur_machine = machines[9]
        -- elseif love.keyboard.isDown("0") then
        --     cur_machine = machines[10]
    end

    if tick % 20 == 0 then
        for idx, machine in ipairs(world_machines) do
            if machine.ticks < tick then
                if machine.machine == "miner" then
                    table.insert(world_items, {
                        x = machine.x,
                        y = machine.y,
                        item = "ironore",
                        age = 0
                    })
                elseif machine.machine == "smelter" then
                    local item = get_world_elem(world_items, machine.x, machine.y)
                    if item ~= nil then
                        if item[2].item == "ironore" and item[2].age > 0 then
                            item[2].item = "ironbar"
                            item[2].age = 0
                        end
                    end
                elseif machine.machine == "conveyor" then
                    local item = get_world_elem(world_items, machine.x, machine.y)
                    local to_x = machine.x
                    local to_y = machine.y
                    if machine.rot == 0 then
                        to_y = to_y - 1
                    elseif machine.rot == 1 then
                        to_x = to_x + 1
                    elseif machine.rot == 2 then
                        to_y = to_y + 1
                    elseif machine.rot == 3 then
                        to_x = to_x - 1
                    end
                    local to = get_world_elem(world_items, to_x, to_y)
                    if item ~= nil and to == nil then
                        if item[2].age > 0 then
                            item[2].age = 0
                            item[2].x = to_x
                            item[2].y = to_y
                        end
                    end
                end
            end

            if machine.machine ~= "conveyor" then
                local item = get_world_elem(world_items, machine.x, machine.y)

                if item ~= nil then
                    local neighbors = get_conveyor_neighbors(world_machines, machine.x, machine.y)
                    if #neighbors > 0 and item[2].age > 0 then
                        local pick = (machine.ticks % #neighbors) + 1
                        item[2].x = neighbors[pick][2].x
                        item[2].y = neighbors[pick][2].y
                        item[2].age = 0
                    end
                end
            end
        end

        for idx, item in ipairs(world_items) do
            item.age = item.age + 1
            if item.age > 16 then
                table.remove(world_items, idx)
            end
        end
        for idx, machine in ipairs(world_machines) do
            machine.ticks = machine.ticks + 1
        end
    end

    tick = tick + 1
end

function love.keypressed(key, _, isrepeat)
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

    for _, machine in ipairs(world_machines) do
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

    for _, item in ipairs(world_items) do
        love.graphics.draw(
            imgs[item.item],
            item.x * s,
            item.y * s,
            0,
            s / 256
        );
    end

    local coordx = math.floor((love.mouse.getX() + x) / s)
    local coordy = math.floor((love.mouse.getY() + y) / s)

    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.draw(
        imgs[cur_machine],
        coordx * s + s / 2,
        coordy * s + s / 2,
        cur_rot * math.pi / 2,
        s / 256,
        s / 256,
        128,
        128
    );

    local elem = get_world_elem(world_machines, coordx, coordy)
    if love.mouse.isDown(1) then
        if elem ~= nil then
            table.remove(world_machines, elem[1])
        end
        table.insert(world_machines, {
            x = math.floor((love.mouse.getX() + x) / s),
            y = math.floor((love.mouse.getY() + y) / s),
            rot = cur_rot,
            machine = cur_machine,
            ticks = 0,
            item = ""
        })
    end
    if love.mouse.isDown(2) then
        if elem ~= nil then
            table.remove(world_machines, elem[1])
        end
    end

    love.graphics.setColor(1, 1, 1, 0.4)

    for idx, machine in ipairs(machines) do
        love.graphics.draw(
            imgs[machine],
            s * -0.5 + idx * s * 2 + x,
            s * 7.5 + y,
            cur_rot * math.pi / 2,
            s / 256,
            s / 256,
            128,
            128
        )
    end
end
