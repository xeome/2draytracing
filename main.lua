lf = love.filesystem
lg = love.graphics
local insert = table.insert
local sin = math.sin
local cos = math.cos
local rad = math.rad
local root = math.sqrt
function love.load()
    function updatecode()
        if(lf.getInfo("main.lua").modtime ~= lastModified)then
            local testFunc = function()
                lf.load('main.lua')
            end
            local test, e = pcall(testFunc)
            if(test)then
                lf.load('main.lua')()
                love.run()
            else
                print(e)
            end
            lastModified = lf.getInfo("main.lua").modtime
        end
    end
    walls = {
        {400, 
        200, 
        400, 
        400},
        {500,200,500,500} 

    }
    raydistance = 500
    rays = {}
    reflections = {}
    function cast(x1, y1, x2, y2, x3, y3, x4, y4)
        local den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
        if den == 0 then
            return
        end
        local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
        local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den
        if (t > 0 and t < 1 and u > 0 and u < 1) then
            local x = x1 + t * (x2 - x1)
            local y = y1 + t * (y2 - y1)
            return x,y
        end
    end

    function distance(x1,y1,x2,y2)
        local a = x1 - x2
        local b = y1 - y2
        return root(a ^ 2 + b ^ 2)
    end

    settings = {debugging = false}
    light = love.graphics.newImage("assets/light.png")
    
end
function love.keypressed(key, unicode)
    if key == "f3" and settings.debugging == false then
        settings.debugging = true
    else
        settings.debugging = false
    end
end

function love.update(dt)
    updatecode()

    local closestx,closesty
    local reflength
    mousex, mousey = love.mouse.getPosition()
    rays = {}
    reflections = {}

    for i = 0, 360 do
    local record = raydistance + 1
        for j,wall in ipairs(walls) do
        	
            ang = i * 1
            local x1, y1, x2, y2 = unpack(wall)
            endx, endy =
                cast(
                mousex,
                mousey,
                mousex + cos(rad(ang)) * raydistance,
                mousey + sin(rad(ang)) * raydistance,
                x1,
                y1,
                x2,
                y2
            )

            if endy and endx then
                local dist = distance(mousex, mousey, endx, endy)
                if dist < record and dist < raydistance then
                    record = dist

                    reflength = raydistance - dist
                    closestx,closesty = endx,endy
                    insert(rays, {mousex, mousey, endx, endy})
                    
                end
            end
        end
        if closestx and closesty then
			insert(reflections, {closestx, closesty, closestx - cos(rad(-ang)) * reflength, closesty - sin(rad(-ang)) * reflength})
    	end
    end
end



function love.draw()
    love.graphics.setColor(1, 1, 1)

    for i = 1,#walls do
        lg.line(unpack(walls[i]))
    end
    
    if settings.debugging then
        for r = 1, #rays do
            lg.line(unpack(rays[r]))
        end
        love.graphics.setColor(1, 0, 0)
        for f = 1, #reflections do
            lg.line(unpack(reflections[f]))
        end
    else
        lg.draw(light,mousex-150,mousey-150)
    end
    love.graphics.setColor(1, 1, 1)
    lg.print("Current FPS: "..tostring(love.timer.getFPS()), 1, 5)
    
end
