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
    function ccw(x1, y1, x2, y2, x3, y3)
        return (y3 - y1) * (x2 - x1) > (y2 - y1) * (x3 - x1)
    end
    function cast(x1, y1, x2, y2, x3, y3, x4, y4)
        local x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
        local y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
        if ccw(x1, y1, x3, y3, x4, y4) ~= ccw(x2, y2, x3, y3, x4, y4) and ccw(x1, y1, x2, y2, x3, y3) ~= ccw(x1, y1, x2, y2, x4, y4) then
            return x, y
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

    mousex, mousey = love.mouse.getPosition()
    rays = {}
    reflections = {}

    for i = 0, 360 do
    local record = 1001
        for j = 1, #walls do

            ang = i * 1
            local x1, y1, x2, y2 = unpack(walls[j])
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
                    local reflength = raydistance - dist
                    insert(rays, {mousex, mousey, endx, endy})
                    insert(reflections, {endx, endy, endx - cos(rad(-ang)) * reflength, endy - sin(rad(-ang)) * reflength})
                end
            --else
            --insert(rays, {mousex, mousey, mousex + cos(rad(ang)) * 1000, mousey + sin(rad(ang)) * 1000})
            end
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
