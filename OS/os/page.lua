local class = require('libs.middleclass.middleclass')

local page = class('page')
function page:initialize(clients)
	self.slots = {}

	for i=1, 6 do
		if type(clients[i]) == "table" then
			if type(clients[i][3]) ~= "string" then
				clients[i][3] = "images/Luv/actions/22/close.png"
			end
			table.insert(self.slots, icon:new({ clients[i][1], tostring(clients[i][2]), love.graphics.newImage(clients[i][3]), PiSP.pageNo+1 }))
		end
	end
	PiSP.pageNo = PiSP.pageNo + 1
end

function page:draw(x, y)
    for i, icon in ipairs(self.slots) do
    	if i <= 3 then
			icon:draw(x+50+((i-1)*80), 35)
		else
			-- -4 to account for current 3
			icon:draw(x+50+((i-4)*80), 130)
		end
    end
end

return page