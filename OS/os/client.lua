local class = require('libs.middleclass.middleclass')

local client = class('client')
function client:initialize(name)
	self.draw = false
end

function client:draw()
	if self.draw == true then
		imgui.Text("test")
	end
end

return client