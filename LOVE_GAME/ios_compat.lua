if not MOBILE then return end

local orig = love.draw
love.draw = function()
    love.graphics.rotate(math.pi/2)
    orig()
end

local orig = love.graphics.newFont
love.graphics.newFont = function(x)
    return orig(x*2)
end

local orig = love.graphics.print
love.graphics.print = function(x, y, z)
    return orig(x, y/2, z/2)
end

local function tmp(x)
    local orig = love.graphics['get'..x]
    love.graphics['get'..x] = function()
        return orig()*2
    end
end

tmp('Width')
tmp('Height')
