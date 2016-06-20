local width, height = 30, 30
function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
end


function love.touchreleased( id, x, y, dx, dy, pressure)
    --love.system.openURL("cydia://package/loveboard")
    love.event.quit()
end

function love.mousereleased( x, y, button, istouch )
    if istouch then return end
    love.touchreleased(nil, x, y)
end

local big = love.graphics.newFont(80)
local small = love.graphics.newFont(40)

function love.draw()
    love.graphics.setFont(big)
    love.graphics.setColor(255, 0, 0, 255)
    for i=1,50 do
        love.graphics.print("<3", math.random(-100, width), math.random(-100, height), math.pi/2)
    end
    love.graphics.setColor(30, 130, 255, 255)
    if not opened_cydia then
        love.graphics.print("LöveBoard", width - 50, 60, math.pi/2)
    end
    love.graphics.setFont(small)
    love.graphics.setColor(255, 255, 255, 255)
    local txt
    if not opened_cydia then
        txt = "So yeah this example sucks.\n\n"..
        "Tap to return to SpringBoard\n\n"..
        "Game is stored in\n/var/mobile/LOVE_GAME\n\n"..
        "Type `relove` in terminal\nto relaunch this\n\n"..
        "width: "..width.."\nheight:"..height
    else
        txt = "Opening Cydia... sit tight."
    end
    love.graphics.print(txt, width - 150, 10, math.pi/2)
end
