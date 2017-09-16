local class = require('libs.middleclass.middleclass')

local icon = class('icon')
local padding = 10
local shadow = love.graphics.newImage("images/shadow.png")
function icon:initialize(clients)
	self.client = clients[1]
	self.name = clients[2]
	self.image = clients[3]
	self.focused = false
	self.r = 0
end

function icon:draw(x, y)
	if self.focused then
		love.graphics.draw(shadow, x, y+5)
	end
	-- Rotate an image around it's center, requires some offset math...
	love.graphics.draw(self.image, x+self.image:getWidth()/2, y+self.image:getHeight()/2, self.r, 1, 1, self.image:getWidth()/2, self.image:getHeight()/2)
	love.graphics.printf(self.name, x-padding, y+self.image:getHeight()+padding/2, self.image:getWidth()+(2*padding), "center")
end

return icon