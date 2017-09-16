local class = require('libs.middleclass.middleclass')

local client = class('client')
function client:initialize(windowTitle)
	self.windowTitle = windowTitle
	self.drawing = false
end

function client:draw()
	imgui.Text(tostring(self.windowTitle))
end

return client