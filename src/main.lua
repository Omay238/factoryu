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

function get_ore_from_pos(ox, oy)
    local noise_val = love.math.noise(ox * 0.1, oy * 0.1)
    if noise_val < 0.1 then
        return "iron"
    elseif noise_val > 0.45 and noise_val < 0.55 then
        return "coal"
    elseif noise_val > 0.9 then
        return "copper"
    else
        return nil
    end
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function is_animating(it)
    return it.animProgress and it.animProgress < 1.0
end

-- love stuff

function love.load()
    love.graphics.setBackgroundColor(0.45, 0.45, 0.5)

    x, y = 0, 0
    s = 64
    m = 3
    tick = 0

    money = 100
    power = 250

    cur_rot = 0
    cur_machine = "miner"

    world_machines = {}
    world_items = {}

    imgs = {
        miner = love.graphics.newImage("assets/miner.png"),
        smelter = love.graphics.newImage("assets/smelter.png"),
        presser = love.graphics.newImage("assets/presser.png"),
        power = love.graphics.newImage("assets/power.png"),
        conveyor = love.graphics.newImage("assets/conveyor.png"),
        crate = love.graphics.newImage("assets/crate.png"),
        ironore = love.graphics.newImage("assets/ironore.png"),
        ironbar = love.graphics.newImage("assets/ironbar.png"),
        ironplate = love.graphics.newImage("assets/ironplate.png"),
        copperore = love.graphics.newImage("assets/copperore.png"),
        copperbar = love.graphics.newImage("assets/copperbar.png"),
        coalore = love.graphics.newImage("assets/coalore.png")
    }

    machines = {
        "miner",
        "smelter",
        "presser",
        "power",
        "conveyor",
        "crate"
    }

    recipes = {
        smelter = {
            { inputs = { ironore = 1 },   output = { item = "ironbar", count = 1 },   time = 1, power = -8 },
            { inputs = { copperore = 1 }, output = { item = "copperbar", count = 1 }, time = 1, power = -8 }
        },
        presser = {
            { inputs = { ironbar = 1 }, output = { item = "ironplate", count = 1 }, time = 1, power = -2 }
        },
        power = {
            { inputs = { coalore = 1 }, output = { item = nil }, time = 1, power = 20 }
        }
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
    elseif love.keyboard.isDown("4") then
        cur_machine = machines[4]
    elseif love.keyboard.isDown("5") then
        cur_machine = machines[5]
    elseif love.keyboard.isDown("6") then
        cur_machine = machines[6]
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
                    if get_ore_from_pos(machine.x, machine.y) ~= nil then
                        table.insert(world_items, {
                            x = machine.x,
                            y = machine.y,
                            item = get_ore_from_pos(machine.x, machine.y) .. "ore",
                            age = 0,
                            startX = nil,
                            startY = nil,
                            animProgress = 1.0,
                            animDuration = 0.2
                        })
                    end
                    power = power - 4
                elseif machine.machine == "crate" then
                    local item = get_world_elem(world_items, machine.x, machine.y)
                    if item ~= nil and not is_animating(item[2]) then
                        if item[2].item == "ironore" then
                            money = money + 1
                            table.remove(world_items, item[1])
                        elseif item[2].item == "ironbar" then
                            money = money + 4
                            table.remove(world_items, item[1])
                        elseif item[2].item == "ironplate" then
                            money = money + 8
                            table.remove(world_items, item[1])
                        elseif item[2].item == "copperore" then
                            money = money + 1
                            table.remove(world_items, item[1])
                        elseif item[2].item == "copperbar" then
                            money = money + 4
                            table.remove(world_items, item[1])
                        elseif item[2].item == "coalore" then
                            money = money + 1
                            table.remove(world_items, item[1])
                        end
                    end
                elseif machine.machine ~= "conveyor" then
                    local recs = recipes[machine.machine]
                    if recs then
                        local item = get_world_elem(world_items, machine.x, machine.y)
                        if item ~= nil and not is_animating(item[2]) then
                            for _, rec in ipairs(recs) do
                                local needed = rec.inputs[item[2].item]
                                if needed and needed >= 1 then
                                    if machine.ticks % rec.time == 0 then
                                        if rec.output.item then
                                            item[2].item = rec.output.item
                                            item[2].age = 0
                                        else
                                            table.remove(world_items, item[1])
                                        end
                                    end
                                    power = power + rec.power
                                    break
                                end
                            end
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
                            item[2].startX = item[2].x
                            item[2].startY = item[2].y
                            item[2].animProgress = 0.0
                            item[2].x = to_x
                            item[2].y = to_y
                        end
                    end
                    power = power - 1
                end
            end

            if machine.machine ~= "conveyor" then
                local item = get_world_elem(world_items, machine.x, machine.y)

                if item ~= nil and not is_animating(item[2]) then
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

        for idx = #world_items, 1, -1 do
            local item = world_items[idx]
            item.age = item.age + 1
            if item.age > 16 and not is_animating(item) then
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

    local dt = love.timer.getDelta()
    for _, item in ipairs(world_items) do
        if item.animProgress < 1.0 then
            item.animProgress = math.min(item.animProgress + dt / item.animDuration, 1.0)
            if item.animProgress >= 1.0 then
                item.startX, item.startY = nil, nil
            end
        end
    end

    local min_scale = -1
    local max_scale = math.max(
        love.graphics.getHeight(),
        love.graphics.getWidth()
    ) / s + 1

    for xoff = -1, max_scale do
        for yoff = -1, max_scale do
            local xcoord, ycoord = math.floor(x / s) + xoff, math.floor(y / s) + yoff
            local ore = get_ore_from_pos(xcoord, ycoord)

            if ore == "iron" then
                love.graphics.setColor(0.91, 0.78, 0.69) -- iron
            elseif ore == "coal" then
                love.graphics.setColor(0.25, 0.2, 0.2)   -- coal
            elseif ore == "copper" then
                love.graphics.setColor(0.73, 0.4, 0.13)  -- copper
            else
                love.graphics.setColor(0.45, 0.45, 0.5)  -- floor
            end

            love.graphics.rectangle(
                "fill",
                xcoord * s,
                ycoord * s,
                s,
                s
            )
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

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
        local drawX, drawY
        if item.animProgress < 1.0 and item.startX and item.startY then
            drawX = lerp(item.startX, item.x, item.animProgress) * s
            drawY = lerp(item.startY, item.y, item.animProgress) * s
        else
            drawX = item.x * s
            drawY = item.y * s
        end

        love.graphics.draw(
            imgs[item.item],
            drawX,
            drawY,
            0,
            s / 256
        )
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
        local pmoney = money
        if elem ~= nil then
            if elem[2].machine == "miner" then
                money = money + 25
            elseif elem[2].machine == "smelter" then
                money = money + 15
            elseif elem[2].machine == "presser" then
                money = money + 10
            elseif elem[2].machine == "power" then
                money = money + 20
            elseif elem[2].machine == "conveyor" then
                money = money + 2
            elseif elem[2].machine == "crate" then
                money = money + 5
            end
        end
        if cur_machine == "miner" then
            money = money - 25
        elseif cur_machine == "smelter" then
            money = money - 15
        elseif cur_machine == "presser" then
            money = money - 10
        elseif cur_machine == "power" then
            money = money - 20
        elseif cur_machine == "conveyor" then
            money = money - 2
        elseif cur_machine == "crate" then
            money = money - 5
        end
        if money < 0 then
            money = pmoney
        else
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
    end
    if love.mouse.isDown(2) then
        if elem ~= nil then
            if elem[2].machine == "miner" then
                money = money + 25
            elseif elem[2].machine == "smelter" then
                money = money + 15
            elseif elem[2].machine == "presser" then
                money = money + 10
            elseif elem[2].machine == "power" then
                money = money + 20
            elseif elem[2].machine == "conveyor" then
                money = money + 2
            elseif elem[2].machine == "crate" then
                money = money + 5
            end

            table.remove(world_machines, elem[1])
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.print("$" .. money, x, y)
    love.graphics.print(power .. "MW", x, y + 12)

    for idx, machine in ipairs(machines) do
        if machine == cur_machine then
            love.graphics.setColor(1, 1, 1, 0.8)
        else
            love.graphics.setColor(1, 1, 1, 0.4)
        end

        love.graphics.draw(
            imgs[machine],
            s * 0.5 + idx * s + x,
            s * 7.5 + y,
            cur_rot * math.pi / 2,
            s / 256,
            s / 256,
            128,
            128
        )
    end
end
