local class = require('libs.middleclass.middleclass')

--[[
battery               time

    ICON   ICON   ICON

    ICON   ICON   ICON

power             settings
]]

local page = class('page')

pageNo = 0
function page:initialize(clients)
	self.slots = {}
	for i=1, 6 do
		if type(clients[i]) == "table" then
			table.insert(self.slots, icon:new({ clients[i][1], tostring(clients[i][2]), love.graphics.newImage(clients[i][3]) }))
		end
	end
end

function page:draw()
    for i, icon in ipairs(self.slots) do
    	if i <= 3 then
			icon:draw(50+((i-1)*80), 30)
		else
			-- -4 to account for current 3
			icon:draw(50+((i-4)*80), 110)
		end
    end
end

return page