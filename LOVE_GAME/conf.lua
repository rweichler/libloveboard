require 'globals'
function love.conf(t)
    if MOBILE then
        t.window.highdpi = true
    else
        t.window.width = 640/2
        t.window.height = 1136/2
    end
end
