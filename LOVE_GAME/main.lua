local width, height = 30, 30
function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
end


function love.touchreleased( id, x, y, dx, dy, pressure)
    --love.system.openURL("cydia://package/loveboard")
    love.event.quit()
end

local big = love.graphics.newFont(80)
local small = love.graphics.newFont(40)

function love.draw()
    love.graphics.setFont(big)
    love.graphics.setColor(30, 130, 255, 255)
    if not opened_cydia then
        love.graphics.print("LöveBoard", width - 50, 60, math.pi/2)
    end
    love.graphics.setFont(small)
    love.graphics.setColor(255, 255, 255, 255)
    local txt
    if not opened_cydia then
        txt = "So yeah this example sucks.\n\nTap to return to SpringBoard\n\nGame is stored in\n/var/mobile/LOVE_GAME\n\nwidth: "..width.."\nheight:"..height
    else
        txt = "Opening Cydia... sit tight."
    end
    love.graphics.print(txt, width - 150, 10, math.pi/2)

end
