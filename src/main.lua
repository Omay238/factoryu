-- helper functions for managing world state

function get_world_elem(mx, my)
    for idx, machine in ipairs(world) do
        if machine.x == mx and machine.y == my then
            return { idx, machine }
        end
    end
    return nil
end

function get_conveyor_neighbors(mx, my)
    local neighbors = {}
    for idx, machine in ipairs(world) do
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

    world = {}

    imgs = {
        miner = love.graphics.newImage("assets/miner.png"),
        conveyor = love.graphics.newImage("assets/conveyor.png"),
        ironore = love.graphics.newImage("assets/ironore.png")
    }

    -- aw man i don't know lua enough to fix this xd
    machines = {
        "miner",
        "conveyor"
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
        -- elseif love.keyboard.isDown("3") then
        --     cur_machine = machines[3]
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
        for _, machine in ipairs(world) do
            if machine.machine == "conveyor" and machine.item ~= "" then
                if machine.rot == 0 then
                    local machine2 = get_world_elem(machine.x, machine.y - 1)
                    if machine2 ~= nil then
                        if machine2[2].item == "" then
                            machine2[2].item = machine.item
                            machine.item = ""
                            machine.ticks = machine.ticks + 1
                        end
                    end
                elseif machine.rot == 1 then
                    local machine2 = get_world_elem(machine.x + 1, machine.y)
                    if machine2 ~= nil then
                        if machine2[2].item == "" then
                            machine2[2].item = machine.item
                            machine.item = ""
                            machine.ticks = machine.ticks + 1
                        end
                    end
                elseif machine.rot == 2 then
                    local machine2 = get_world_elem(machine.x, machine.y + 1)
                    if machine2 ~= nil then
                        if machine2[2].item == "" then
                            machine2[2].item = machine.item
                            machine.item = ""
                            machine.ticks = machine.ticks + 1
                        end
                    end
                elseif machine.rot == 3 then
                    local machine2 = get_world_elem(machine.x + 1, machine.y)
                    if machine2 ~= nil then
                        if machine2[2].item == "" then
                            machine2[2].item = machine.item
                            machine.item = ""
                            machine.ticks = machine.ticks + 1
                        end
                    end
                end
            elseif machine.machine == "miner" then
                local neighbors = get_conveyor_neighbors(machine.x, machine.y)

                if #neighbors > 0 then
                    neighbors[(machine.ticks % #neighbors) + 1][2].item = machine.item
                    machine.item = ""
                end

                machine.item = "ironore"

                machine.ticks = machine.ticks + 1
            end
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

        if machine.item ~= "" then
            love.graphics.draw(
                imgs[machine.item],
                (machine.x * s) + s / 2,
                (machine.y * s) + s / 2,
                machine.rot * math.pi / 2,
                s / 256,
                s / 256,
                128,
                128
            );
        end
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

    local elem = get_world_elem(coordx, coordy)
    if love.mouse.isDown(1) then
        if elem ~= nil then
            table.remove(world, elem[1])
        end
        table.insert(world, {
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
            table.remove(world, elem[1])
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
