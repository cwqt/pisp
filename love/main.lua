Gamestate = require "libs.hump.gamestate"

modules = {
	menu = {},
	inputTester = {},
	minigame = {}
}


function menu:draw()
	love.graphics.print("deatsssh", 10, 10)
end

function menu:keyreleased(key, code)
    if key == 'space' then
        Gamestate.switch(inputTester)
    end
end

function love.load()
    --Gamestate.registerEvents()
    --Gamestate.switch(menu)
end

function love.update()
end

function love.draw()
end
