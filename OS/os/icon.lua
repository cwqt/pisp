local class = require('libs.middleclass.middleclass')

local icon = class('icon')
function icon:initialize(clients)
	self.client = clients[1]
	self.name = clients[2]
	self.image = clients[3]
end

function icon:draw(x, y)
	love.graphics.draw(self.image, x, y)
	love.graphics.printf(self.name, x-10, y+self.image:getHeight()+10, self.image:getWidth()+20, "center")
end

return icon