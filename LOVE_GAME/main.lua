local width, height = 30, 30
function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
end

local opened_cydia = false
local time = 0

function love.update(dt)
    if not opened_cydia then return end
    time = time + dt
    if time > 3 then
        time = 0
        opened_cydia = false
    end
end

function love.touchreleased( id, x, y, dx, dy, pressure)
    love.system.openURL("cydia://package/loveboard")
    opened_cydia = true
end


function love.draw()
    love.graphics.setColor(30, 130, 255, 255)
    if not opened_cydia then
        love.graphics.print("LoveBoard", width - 50, 30, math.pi/2, 4, 4)
    end
    love.graphics.setColor(255, 255, 255, 255)
    local txt
    if not opened_cydia then
        txt = "So yeah this example sucks.\n\nTap to open Cydia and\nuninstall this garbage\n\nGame is stored in\n/var/mobile/LOVE_GAME\n\nwidth: "..width.."\nheight:"..height
    else
        txt = "Opening Cydia... sit tight."
    end
    love.graphics.print(txt, width - 150, 10, math.pi/2, 2, 2)
end
